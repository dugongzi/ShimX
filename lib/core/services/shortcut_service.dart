import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:win32/win32.dart';

part 'shortcut_service.g.dart';

const _shortcutFlag = '--launch-codex';

@Riverpod(keepAlive: true)
ShortcutService shortcutService(Ref ref) {
  return ShortcutService();
}

class ShortcutPlatformUnsupportedException implements Exception {
  const ShortcutPlatformUnsupportedException();
  @override
  String toString() => 'unsupported platform';
}

/// 在桌面创建"CodexShim"快捷方式：双击 = 启动 shim 并附带 --launch-codex 参数
/// 让 shim 走"一键注入"流程。
class ShortcutService {
  Future<File> createDesktopShortcut() async {
    if (Platform.isWindows) return _createWindows();
    if (Platform.isMacOS) return _createMacOS();
    throw const ShortcutPlatformUnsupportedException();
  }

  // -------- Windows --------

  Future<File> _createWindows() async {
    final desktop = _desktopDir();
    final exePath = Platform.resolvedExecutable;
    final workingDir = p.dirname(exePath);
    final lnkPath = p.join(desktop, 'CodexShim.lnk');

    _writeWindowsShortcut(
      lnkPath: lnkPath,
      targetPath: exePath,
      arguments: _shortcutFlag,
      workingDir: workingDir,
      description: 'Launch Codex via Shim',
    );

    return File(lnkPath);
  }

  void _writeWindowsShortcut({
    required String lnkPath,
    required String targetPath,
    required String arguments,
    required String workingDir,
    required String description,
  }) {
    final hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    final shouldUninit = hr == S_OK;
    final isSuccess = hr == S_OK || hr == S_FALSE || hr == RPC_E_CHANGED_MODE;
    if (!isSuccess) {
      throw StateError('CoInitializeEx failed: 0x${hr.toRadixString(16)}');
    }

    try {
      final shellLink = ShellLink.createInstance();
      try {
        final targetPtr = targetPath.toNativeUtf16();
        final argsPtr = arguments.toNativeUtf16();
        final workDirPtr = workingDir.toNativeUtf16();
        final descPtr = description.toNativeUtf16();
        final lnkPtr = lnkPath.toNativeUtf16();
        try {
          var status = shellLink.setPath(targetPtr);
          if (FAILED(status)) {
            throw StateError('SetPath failed: 0x${status.toRadixString(16)}');
          }
          status = shellLink.setArguments(argsPtr);
          if (FAILED(status)) {
            throw StateError(
              'SetArguments failed: 0x${status.toRadixString(16)}',
            );
          }
          status = shellLink.setWorkingDirectory(workDirPtr);
          if (FAILED(status)) {
            throw StateError(
              'SetWorkingDirectory failed: 0x${status.toRadixString(16)}',
            );
          }
          status = shellLink.setDescription(descPtr);
          if (FAILED(status)) {
            throw StateError(
              'SetDescription failed: 0x${status.toRadixString(16)}',
            );
          }

          final persistFile = IPersistFile(
            shellLink.toInterface(IID_IPersistFile),
          );
          try {
            status = persistFile.save(lnkPtr, TRUE);
            if (FAILED(status)) {
              throw StateError(
                'IPersistFile.Save failed: 0x${status.toRadixString(16)}',
              );
            }
          } finally {
            persistFile.release();
          }
        } finally {
          calloc.free(targetPtr);
          calloc.free(argsPtr);
          calloc.free(workDirPtr);
          calloc.free(descPtr);
          calloc.free(lnkPtr);
        }
      } finally {
        shellLink.release();
      }
    } finally {
      if (shouldUninit) {
        CoUninitialize();
      }
    }
  }

  // -------- macOS --------

  Future<File> _createMacOS() async {
    final desktop = _desktopDir();
    final exePath = Platform.resolvedExecutable;
    // resolvedExecutable 在 .app bundle 中指向 Contents/MacOS/shim
    // 通过 open -a + --args 传参即可
    final appBundle = _macOSAppBundlePath(exePath);
    final commandPath = p.join(desktop, 'CodexShim.command');
    final script = '''#!/bin/sh
open -a "$appBundle" --args $_shortcutFlag
''';
    final file = File(commandPath);
    await file.writeAsString(script);
    await Process.run('chmod', ['+x', commandPath]);
    return file;
  }

  String _macOSAppBundlePath(String exePath) {
    // .../CodexShim.app/Contents/MacOS/shim → .../CodexShim.app
    final macosDir = p.dirname(exePath);
    final contentsDir = p.dirname(macosDir);
    return p.dirname(contentsDir);
  }

  // -------- shared --------

  String _desktopDir() {
    if (Platform.isWindows) return _desktopDirWindows();
    final home = Platform.environment['HOME'];
    if (home == null) {
      throw StateError('could not resolve user home directory');
    }
    return p.join(home, 'Desktop');
  }

  /// Windows 真实桌面路径（考虑 OneDrive 接管 / 重定向 / 本地化），用
  /// SHGetKnownFolderPath(FOLDERID_Desktop) 查。
  String _desktopDirWindows() {
    final rfidPtr = calloc<GUID>()..ref.setGUID(FOLDERID_Desktop);
    final pathPtr = calloc<Pointer<Utf16>>();
    try {
      final hr = SHGetKnownFolderPath(rfidPtr, 0, 0, pathPtr);
      if (FAILED(hr)) {
        throw StateError(
          'SHGetKnownFolderPath failed: 0x${hr.toRadixString(16)}',
        );
      }
      final path = pathPtr.value.toDartString();
      CoTaskMemFree(pathPtr.value.cast());
      return path;
    } finally {
      calloc.free(rfidPtr);
      calloc.free(pathPtr);
    }
  }

  /// 命令行参数里是否带有快捷方式触发 flag。
  static bool shouldAutoLaunchCodex(List<String> args) =>
      args.contains(_shortcutFlag);
}

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:win32/win32.dart';

part 'codex_launcher_service.g.dart';

@Riverpod(keepAlive: true)
CodexLauncherService codexLauncherService(Ref ref) {
  return CodexLauncherService();
}

class CodexNotInstalledException implements Exception {
  const CodexNotInstalledException();
  @override
  String toString() => 'Codex 未安装';
}

class CodexLaunchException implements Exception {
  final String message;
  const CodexLaunchException(this.message);
  @override
  String toString() => 'Codex 启动失败: $message';
}

/// 跨平台 Codex 启动 service：
/// - Windows: 用 Get-AppxPackage 找 UWP 包 → AUMID → ApplicationActivationManager 激活
/// - macOS: 扫 /Applications/Codex.app → open -a
/// - Linux: 暂不支持
class CodexLauncherService {
  Future<void> launchCodex({
    required int debugPort,
  }) async {
    final cdpArgs = [
      '--remote-debugging-port=$debugPort',
      '--remote-allow-origins=*',
    ];
    if (Platform.isWindows) {
      await _launchWindows(cdpArgs);
      return;
    }
    if (Platform.isMacOS) {
      await _launchMacOS(cdpArgs);
      return;
    }
    throw const CodexNotInstalledException();
  }

  // -------- Windows --------

  Future<void> _launchWindows(List<String> args) async {
    final aumid = await _findWindowsAumid();
    if (aumid == null) {
      throw const CodexNotInstalledException();
    }
    _activatePackagedApp(aumid, args.join(' '));
  }

  Future<String?> _findWindowsAumid() async {
    final result = await Process.run(
      'powershell',
      [
        '-NoProfile',
        '-Command',
        'Get-AppxPackage -Name OpenAI.Codex* | Select-Object -ExpandProperty PackageFamilyName',
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) return null;
    final pfn = (result.stdout as String).trim().split('\n').first.trim();
    if (pfn.isEmpty) return null;
    return '$pfn!App';
  }

  void _activatePackagedApp(String aumid, String arguments) {
    final hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    // S_OK = 0x0（首次初始化）；S_FALSE = 0x1（已初始化过）都算成功，
    // 只有 S_OK 时才由我们负责 CoUninitialize；RPC_E_CHANGED_MODE 表示当前线程
    // 已被以其他公寓模式初始化过，无害忽略。
    final shouldUninit = hr == S_OK;
    final isSuccess = hr == S_OK || hr == S_FALSE || hr == RPC_E_CHANGED_MODE;
    if (!isSuccess) {
      throw CodexLaunchException(
        'CoInitializeEx failed: 0x${hr.toRadixString(16)}',
      );
    }
    try {
      final manager = ApplicationActivationManager.createInstance();
      final aumidPtr = aumid.toNativeUtf16();
      final argsPtr = arguments.toNativeUtf16();
      final processIdPtr = calloc<Uint32>();
      try {
        final activateHr = manager.activateApplication(
          aumidPtr,
          argsPtr,
          0,
          processIdPtr,
        );
        if (activateHr != S_OK) {
          throw CodexLaunchException(
            'ActivateApplication failed: 0x${activateHr.toRadixString(16)}',
          );
        }
      } finally {
        calloc.free(aumidPtr);
        calloc.free(argsPtr);
        calloc.free(processIdPtr);
        manager.release();
      }
    } finally {
      if (shouldUninit) {
        CoUninitialize();
      }
    }
  }

  // -------- macOS --------

  Future<void> _launchMacOS(List<String> args) async {
    const appPath = '/Applications/Codex.app';
    if (!await Directory(appPath).exists()) {
      throw const CodexNotInstalledException();
    }
    final result = await Process.start(
      'open',
      ['-a', appPath, '--args', ...args],
      mode: ProcessStartMode.detached,
    );
    if (result.pid == 0) {
      throw const CodexLaunchException('open failed to spawn');
    }
  }
}

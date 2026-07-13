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
///   默认匹配官方新旧包名(OpenAI.ChatGPT* / OpenAI.Codex*);用户可传入自定义
///   `-Name` 通配符覆盖(比如企业内部签名的包名)。
/// - macOS: 扫 `.app` 路径 → open -a
///   默认按 ChatGPT.app → Codex.app 顺序探测;用户可传入自定义完整路径覆盖。
/// - Linux: 暂不支持
class CodexLauncherService {
  /// codex 进程是否已经在跑(与是否开了 CDP 无关,只看进程存在性)。
  /// 用于区分"codex 未启动"和"codex 已启动但没带 --remote-debugging-port"。
  Future<bool> isCodexRunning({String? userTarget}) async {
    if (Platform.isWindows) {
      return _isCodexRunningWindows();
    }
    if (Platform.isMacOS) {
      return _isCodexRunningMacOS(userTarget?.trim());
    }
    return false;
  }

  Future<bool> _isCodexRunningWindows() async {
    // Windows 上 UWP 打包的 codex 真实进程名不确定(可能是 ChatGPT.exe、
    // Codex.exe、Codex Desktop.exe、含空格/加后缀等等)。tasklist /FI IMAGENAME
    // 只支持精确匹配,枚举不完。这里直接列所有进程,行内模糊匹配包含 chatgpt
    // 或 codex 的名字。tasklist 输出全是 ASCII 进程名,匹配不受 codepage 影响。
    try {
      final r = await Process.run(
        'tasklist',
        ['/NH', '/FO', 'CSV'],
        stdoutEncoding: utf8,
      ).timeout(const Duration(seconds: 3));
      if (r.exitCode != 0) return false;
      final out = (r.stdout as String).toLowerCase();
      // CSV 每行第一列 "进程名","PID",...
      // 找到形如 "xxx.exe" 且 xxx 包含 chatgpt / codex 的行就算在跑。
      // 排除已知 helper:codex-computer-use.exe 是 codex 的自动化辅助子进程,
      // 主体没跑时也可能在;codex.exe 是 codex CLI(用户可能装了但主 App 没开)。
      // 命中主 App 的判据是 exe 名同时含 chatgpt/codex 且不是这些 helper。
      const helpers = ['codex-computer-use.exe', 'codex.exe'];
      for (final line in out.split('\n')) {
        // 只取首列(exe 名)判定。避免命令行参数里出现 codex 误伤(tasklist
        // /NH 只输出进程名,不会有命令行,所以就是首字段)。
        final firstColEnd = line.indexOf('","');
        if (firstColEnd < 0) continue;
        final name = line.substring(1, firstColEnd);
        if (!name.endsWith('.exe')) continue;
        if (helpers.contains(name)) continue;
        if (name.contains('chatgpt') || name.contains('codex')) return true;
      }
    } on Object {
      // tasklist 缺失、超时、权限不足 — 当作未检测到,让主流程继续尝试启动。
    }
    return false;
  }

  Future<bool> _isCodexRunningMacOS(String? override) async {
    // pgrep -f 匹配完整命令行,能同时覆盖 ChatGPT.app / Codex.app 主进程。
    // override 若指向 .app 路径,用它的 basename 做匹配关键字。
    final keywords = <String>[];
    if (override != null && override.isNotEmpty) {
      final name = override.split('/').lastWhere(
        (s) => s.isNotEmpty,
        orElse: () => '',
      );
      if (name.isNotEmpty) keywords.add(name);
    }
    keywords.addAll(['ChatGPT.app', 'Codex.app']);
    for (final kw in keywords) {
      try {
        final r = await Process.run('pgrep', ['-fx', '.*$kw.*']);
        if (r.exitCode == 0) return true;
        // 有些系统 pgrep 不认 -fx,退回 -f。
        final r2 = await Process.run('pgrep', ['-f', kw]);
        if (r2.exitCode == 0) return true;
      } catch (_) {
        // pgrep 不可用就当没检测到。
      }
    }
    return false;
  }

  Future<void> launchCodex({
    required int debugPort,
    String? userTarget,
  }) async {
    final cdpArgs = [
      '--remote-debugging-port=$debugPort',
      '--remote-allow-origins=*',
    ];
    final override = userTarget?.trim();
    if (Platform.isWindows) {
      await _launchWindows(cdpArgs, override);
      return;
    }
    if (Platform.isMacOS) {
      await _launchMacOS(cdpArgs, override);
      return;
    }
    throw const CodexNotInstalledException();
  }

  // -------- Windows --------

  /// 默认候选的 AppxPackage `-Name` 通配符。按顺序尝试,任一命中即用。
  /// 用户 override(非空)会插到最前面,内置默认作兜底。
  static const List<String> _defaultWindowsAppxPatterns = [
    'OpenAI.ChatGPT*',
    'OpenAI.Codex*',
  ];

  Future<void> _launchWindows(List<String> args, String? override) async {
    final patterns = [
      if (override != null && override.isNotEmpty) override,
      ..._defaultWindowsAppxPatterns,
    ];
    for (final pattern in patterns) {
      final aumid = await _findWindowsAumid(pattern);
      if (aumid != null) {
        _activatePackagedApp(aumid, args.join(' '));
        return;
      }
    }
    throw const CodexNotInstalledException();
  }

  Future<String?> _findWindowsAumid(String namePattern) async {
    // 加 5s 超时。部分机器上 PowerShell 冷启动/AV 拦截会挂十几秒甚至更久,
    // 用户看着注入按钮转圈莫名其妙。挂就当没找到,回主流程继续下一 pattern。
    try {
      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-Command',
          "Get-AppxPackage -Name '$namePattern' | Select-Object -ExpandProperty PackageFamilyName",
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ).timeout(const Duration(seconds: 5));
      if (result.exitCode != 0) return null;
      final pfn = (result.stdout as String).trim().split('\n').first.trim();
      if (pfn.isEmpty) return null;
      return '$pfn!App';
    } on Object {
      return null;
    }
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

  /// 默认候选 `.app` 完整路径。按顺序探测,谁存在用谁。
  /// 官方最新叫 ChatGPT.app;旧版本装的还是 Codex.app,保留兜底。
  static const List<String> _defaultMacAppPaths = [
    '/Applications/ChatGPT.app',
    '/Applications/Codex.app',
  ];

  Future<void> _launchMacOS(List<String> args, String? override) async {
    final candidates = [
      if (override != null && override.isNotEmpty) override,
      ..._defaultMacAppPaths,
    ];
    String? appPath;
    for (final path in candidates) {
      if (await Directory(path).exists()) {
        appPath = path;
        break;
      }
    }
    if (appPath == null) {
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

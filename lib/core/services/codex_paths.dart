import 'dart:io';

import 'package:path/path.dart' as p;

/// 统一解析 codex 相关路径。历史遗留代码里散落硬编码 `~/.codex`,
/// 新代码请走这里,顺带支持 `CODEX_HOME` 环境变量。
class CodexPaths {
  const CodexPaths._();

  /// codex 主目录。
  /// - 优先看 `CODEX_HOME` 环境变量(codex 自己也是这个规则)
  /// - fallback 到 `~/.codex`
  ///
  /// 抛 [StateError] 如果两者都拿不到(极端情况:非 Windows 无 HOME env)。
  static String home() {
    final override = _envOverride();
    if (override != null && override.isNotEmpty) return override;
    final userHome = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (userHome == null || userHome.isEmpty) {
      throw StateError('Cannot resolve user home directory');
    }
    return p.join(userHome, '.codex');
  }

  /// `<codex_home>/config.toml`
  static String configToml() => p.join(home(), 'config.toml');

  /// `<codex_home>/.tmp/plugins`。跟 CodexPlusPlus 目录约定一致,
  /// 但这是 codex 自己 marketplace loader 认识的路径,不是 CodexPlusPlus 定的。
  static String pluginsCuratedRoot() => p.join(home(), '.tmp', 'plugins');

  /// `<codex_home>/.tmp/plugins-remote`
  static String pluginsCuratedRemoteRoot() =>
      p.join(home(), '.tmp', 'plugins-remote');

  static String? _envOverride() {
    final v = Platform.environment['CODEX_HOME'];
    if (v == null) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

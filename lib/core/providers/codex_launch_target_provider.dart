import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_storage.dart';

part 'codex_launch_target_provider.g.dart';

/// codex 客户端的启动目标用户覆盖。留空 = 走 launcher 内置默认。
/// - macOS: 存 `.app` 完整路径,例如 `/Applications/ChatGPT.app`。
/// - Windows: 存 Get-AppxPackage 的 -Name 通配符,例如 `OpenAI.ChatGPT*`。
///
/// 官方 codex 已从 Codex 更名为 ChatGPT,不同版本/发行渠道的名字可能再变;
/// 用户可以在设置里自己填,shim 立即用。
@Riverpod(keepAlive: true)
class CodexLaunchTargetNotifier extends _$CodexLaunchTargetNotifier {
  static const _storageKey = 'codexLaunchTarget';

  @override
  String build() {
    Future.microtask(_load);
    return '';
  }

  Future<void> _load() async {
    final storage = ref.read(appStorageProvider);
    final value = await storage.getString(_storageKey);
    state = value?.trim() ?? '';
  }

  Future<void> set(String value) async {
    final trimmed = value.trim();
    if (state == trimmed) return;
    state = trimmed;
    final storage = ref.read(appStorageProvider);
    if (trimmed.isEmpty) {
      await storage.remove(_storageKey);
    } else {
      await storage.setString(_storageKey, trimmed);
    }
  }
}

abstract class CodexConfigQueryRepository {
  /// 当前 codex config.toml 里的 `model_provider`。不存在返回 null。
  Future<String?> readModelProvider();
}

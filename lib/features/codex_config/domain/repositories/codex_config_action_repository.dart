abstract class CodexConfigActionRepository {
  /// 覆盖顶层 `model_provider`。
  Future<void> writeModelProvider(String value);

  /// 覆盖顶层 `model_provider`,并保证 `[model_providers.<value>]` 段存在
  /// (已有则不动)。用于"切到 shimx 自己的桶"时避免 codex 找不到 provider 定义。
  Future<void> writeModelProviderWithSection({
    required String value,
    required String baseUrl,
  });
}

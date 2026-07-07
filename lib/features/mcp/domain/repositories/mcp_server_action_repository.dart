abstract class McpServerActionRepository {
  /// 持久化 shimx 内置 MCP server 的开关。
  Future<void> saveEnabled(bool enabled);

  /// 在 ~/.codex/config.toml 注册 `[mcp_servers.<id>] url = "..."` 段。
  /// 已存在则跳过。返回 true 表示真的写入了。
  Future<bool> registerInCodex({required String id, required String url});

  /// 从 ~/.codex/config.toml 移除 `[mcp_servers.<id>]` 段(含子段)。
  Future<bool> unregisterFromCodex({required String id});
}

import 'package:shimx/features/mcp/domain/models/mcp_server_info.dart';

abstract class McpServerQueryRepository {
  /// 列出 shimx 提供的所有 MCP server 配置 + 当前状态。
  /// 现阶段返回硬编码的 1 个(shimx_claude),后续可扩展。
  Future<List<McpServerInfo>> listServers();

  /// shimx 内置 MCP server 是否开启;null = 用户从未设置过(由调用方应用默认值)。
  Future<bool?> enabled();

  /// codex 是否已注册该 MCP server(看 ~/.codex/config.toml)。
  Future<bool> isRegisteredInCodex({required String id});
}

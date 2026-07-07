import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/features/mcp/data/models/mcp_server_info_dto.dart';

/// shimx 内置 MCP server 的查询端:
///   - listServers:列出 shimx 暴露的 MCP server 配置(现阶段硬编码 1 个 shimx_claude)
///   - enabled:读持久化开关(默认 true,与设置首次同步)
///   - isRegisteredInCodex:扫 ~/.codex/config.toml 是否含 [mcp_servers.<id>] 段
class McpServerQueryDatasource {
  McpServerQueryDatasource({required this.appStorage});

  final AppStorage appStorage;

  /// shimx 唯一的内置 MCP server id;同步到 ~/.codex/config.toml 的 [mcp_servers.<id>]
  static const String shimxClaudeId = 'shimx_claude';
  static const String shimxClaudeUrl = 'http://127.0.0.1:18787/mcp';

  static const String _enabledKey = 'mcp_server_enabled';

  /// 列出 shimx 提供的全部 MCP server。当前只有一条。
  ///
  /// 注意:returned status 默认是 'stopped',真实 running 状态由 provider 层
  /// 结合 McpService.isRunning 重新覆盖 —— datasource 不感知 runtime。
  Future<List<McpServerInfoDto>> listServers() async {
    final registered = await isRegisteredInCodex(shimxClaudeId);
    return [
      McpServerInfoDto(
        id: shimxClaudeId,
        name: shimxClaudeId,
        description: '',
        url: shimxClaudeUrl,
        status: 'stopped',
        toolCount: 0,
        registeredInCodex: registered,
      ),
    ];
  }

  /// 读 shimx 内置 MCP server 是否开启。null = 用户从未配置过(由调用方决定默认值)。
  Future<bool?> enabled() {
    return appStorage.getBool(_enabledKey);
  }

  /// 扫 ~/.codex/config.toml 是否含 `[mcp_servers.<id>]` 段。
  /// 纯文本匹配,避免引 toml 解析依赖;写入侧仍使用 toml 库。
  Future<bool> isRegisteredInCodex(String id) async {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) return false;
    final config = File(p.join(home, '.codex', 'config.toml'));
    if (!await config.exists()) return false;
    try {
      final text = await config.readAsString();
      return text.contains('[mcp_servers.$id]');
    } catch (_) {
      return false;
    }
  }
}

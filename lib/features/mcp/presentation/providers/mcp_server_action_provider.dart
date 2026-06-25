import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/mcp_service.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_export_provider.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_query_provider.dart';
import 'package:shim/features/mcp/data/datasources/mcp_server_action_datasource.dart';
import 'package:shim/features/mcp/data/datasources/mcp_server_query_datasource.dart';
import 'package:shim/features/mcp/data/repositories/mcp_server_action_repository_impl.dart';
import 'package:shim/features/mcp/domain/repositories/mcp_server_action_repository.dart';
import 'package:shim/features/mcp/presentation/providers/mcp_server_query_provider.dart';

part 'mcp_server_action_provider.g.dart';

/// shim 内置 MCP server 监听端口。改值时一并改 [McpServerQueryDatasource.shimClaudeUrl] 协议。
const int shimMcpServerPort = 18787;

@riverpod
McpServerActionRepository mcpServerActionRepository(Ref ref) {
  return McpServerActionRepositoryImpl(
    dataSource: McpServerActionDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// keepAlive 保留 notifier 实例 —— 否则 UI 切走或重建会 dispose,
/// 而 setEnabled 是 await + ref.invalidate,中途 dispose 会抛
/// 'Cannot use the Ref ... after disposed'。
@Riverpod(keepAlive: true)
class McpServerActions extends _$McpServerActions {
  @override
  void build() {}

  /// 开关 shim 内置 MCP server:
  /// 开 → 注册工具 + 起 HTTP 监听 + 写 codex config.toml
  /// 关 → 停 HTTP + 从 config.toml 移除
  Future<void> setEnabled(bool enabled) async {
    final actionRepo = ref.read(mcpServerActionRepositoryProvider);
    await actionRepo.saveEnabled(enabled);
    if (enabled) {
      await startMcpServer(ref);
    } else {
      await stopMcpServer(ref);
    }
    ref.invalidate(mcpServerEnabledProvider);
    ref.invalidate(mcpServerListProvider);
  }
}

/// 应用启动时根据持久化的 enabled 自动起 MCP server。
/// keepAlive,只在第一次 watch 时跑一次。
@Riverpod(keepAlive: true)
Future<void> mcpServerAutoStart(Ref ref) async {
  final queryRepo = ref.read(mcpServerQueryRepositoryProvider);
  final stored = await queryRepo.enabled();
  final shouldEnable = stored ?? true;
  if (shouldEnable) {
    await startMcpServer(ref);
  }
}

/// 起 MCP server:注册 Claude 工具 + 起 HTTP 监听 + 写 codex config.toml。
/// 已在运行时只补 config.toml 同步,幂等。
Future<void> startMcpServer(Ref ref) async {
  final actionRepo = ref.read(mcpServerActionRepositoryProvider);
  await actionRepo.registerInCodex(
    id: McpServerQueryDatasource.shimClaudeId,
    url: McpServerQueryDatasource.shimClaudeUrl,
  );

  final service = ref.read(mcpServiceProvider);
  if (service.isRunning) {
    AppLogService.instance.info('McpServer', '已在运行,跳过 start');
  } else {
    registerClaudeSessionTools(
      service,
      queryRepository: ref.read(claudeSessionQueryRepositoryProvider),
      exportRepository: ref.read(claudeSessionExportRepositoryProvider),
    );
    try {
      await service.start(port: shimMcpServerPort);
    } catch (e) {
      AppLogService.instance.error('McpServer', '启动失败', details: '$e');
      return;
    }
    ref.read(mcpServerRunningPortProvider).value = service.port;
  }
}

/// 停 MCP server:停 HTTP + 从 config.toml 移除。
Future<void> stopMcpServer(Ref ref) async {
  final actionRepo = ref.read(mcpServerActionRepositoryProvider);
  try {
    await actionRepo.unregisterFromCodex(
      id: McpServerQueryDatasource.shimClaudeId,
    );
  } finally {
    final service = ref.read(mcpServiceProvider);
    await service.stop();
    ref.read(mcpServerRunningPortProvider).value = null;
  }
}

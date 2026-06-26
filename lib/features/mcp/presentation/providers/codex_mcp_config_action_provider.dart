import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/features/mcp/data/datasources/codex_mcp_config_action_datasource.dart';
import 'package:shim/features/mcp/data/repositories/codex_mcp_config_action_repository_impl.dart';
import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shim/features/mcp/domain/repositories/codex_mcp_config_action_repository.dart';
import 'package:shim/features/mcp/presentation/providers/codex_mcp_config_query_provider.dart';

part 'codex_mcp_config_action_provider.g.dart';

@Riverpod(keepAlive: true)
CodexMcpConfigActionRepository codexMcpConfigActionRepository(Ref ref) {
  return CodexMcpConfigActionRepositoryImpl(
    dataSource: CodexMcpConfigActionDatasource(),
  );
}

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。
@Riverpod(keepAlive: true)
class CodexMcpConfigActions extends _$CodexMcpConfigActions {
  @override
  void build() {}

  Future<void> save(CodexMcpConfig config) async {
    AppLogService.instance.info(
      'CodexMcpConfig',
      'Provider 保存 MCP 配置',
      details:
          'kind=${config.kind}\nid=${config.id}\nenabled=${config.enabled}',
    );
    await ref.read(codexMcpConfigActionRepositoryProvider).saveConfig(config);
    if (!ref.mounted) return;
    ref.invalidate(codexMcpConfigsProvider);
  }

  Future<void> remove({required String kind, required String id}) async {
    AppLogService.instance.info(
      'CodexMcpConfig',
      'Provider 删除 MCP 配置',
      details: 'kind=$kind\nid=$id',
    );
    await ref
        .read(codexMcpConfigActionRepositoryProvider)
        .deleteConfig(kind: kind, id: id);
    if (!ref.mounted) return;
    ref.invalidate(codexMcpConfigsProvider);
  }

  Future<void> setEnabled({
    required String kind,
    required String id,
    required bool enabled,
  }) async {
    AppLogService.instance.info(
      'CodexMcpConfig',
      'Provider 切换 MCP 配置',
      details: 'kind=$kind\nid=$id\nenabled=$enabled',
    );
    await ref
        .read(codexMcpConfigActionRepositoryProvider)
        .setEnabled(kind: kind, id: id, enabled: enabled);
    if (!ref.mounted) return;
    ref.invalidate(codexMcpConfigsProvider);
  }
}

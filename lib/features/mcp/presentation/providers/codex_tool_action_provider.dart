import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/features/mcp/data/datasources/codex_tool_action_datasource.dart';
import 'package:shim/features/mcp/data/repositories/codex_tool_action_repository_impl.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';
import 'package:shim/features/mcp/domain/repositories/codex_tool_action_repository.dart';
import 'package:shim/features/mcp/presentation/providers/codex_tool_query_provider.dart';

part 'codex_tool_action_provider.g.dart';

@Riverpod(keepAlive: true)
CodexToolActionRepository codexToolActionRepository(Ref ref) {
  return CodexToolActionRepositoryImpl(dataSource: CodexToolActionDatasource());
}

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。
@Riverpod(keepAlive: true)
class CodexToolActions extends _$CodexToolActions {
  @override
  void build() {}

  Future<void> save(CodexTool tool) async {
    AppLogService.instance.info(
      'CodexTool',
      'Provider 保存配置片段',
      details: 'kind=${tool.kind}\nid=${tool.id}\nenabled=${tool.enabled}',
    );
    await ref.read(codexToolActionRepositoryProvider).saveTool(tool);
    if (!ref.mounted) return;
    ref.invalidate(codexToolsProvider);
  }

  Future<void> remove({required String kind, required String id}) async {
    AppLogService.instance.info(
      'CodexTool',
      'Provider 删除配置片段',
      details: 'kind=$kind\nid=$id',
    );
    await ref
        .read(codexToolActionRepositoryProvider)
        .deleteTool(kind: kind, id: id);
    if (!ref.mounted) return;
    ref.invalidate(codexToolsProvider);
  }

  Future<void> setEnabled({
    required String kind,
    required String id,
    required bool enabled,
  }) async {
    AppLogService.instance.info(
      'CodexTool',
      'Provider 切换配置片段',
      details: 'kind=$kind\nid=$id\nenabled=$enabled',
    );
    await ref
        .read(codexToolActionRepositoryProvider)
        .setEnabled(kind: kind, id: id, enabled: enabled);
    if (!ref.mounted) return;
    ref.invalidate(codexToolsProvider);
  }
}

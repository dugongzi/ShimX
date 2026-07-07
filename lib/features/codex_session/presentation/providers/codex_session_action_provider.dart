import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/utils/codex_session_export_formatter.dart';
import 'package:shimx/features/codex_session/data/datasources/codex_session_action_datasource.dart';
import 'package:shimx/features/codex_session/data/repositories/codex_session_action_repository_impl.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shimx/features/codex_session/domain/repositories/codex_session_action_repository.dart';

part 'codex_session_action_provider.g.dart';

@riverpod
CodexSessionActionRepository codexSessionActionRepository(Ref ref) {
  return CodexSessionActionRepositoryImpl(
    dataSource: CodexSessionActionDatasource(
      formatter: CodexSessionExportFormatter(),
    ),
  );
}

@riverpod
Future<String> deleteCodexThread(Ref ref, {required String id}) async {
  return ref.read(codexSessionActionRepositoryProvider).deleteThread(id: id);
}

/// 导出单条会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。
@riverpod
Future<String?> exportCodexThread(
  Ref ref, {
  required CodexThreadDetail detail,
  required String format,
  String? dialogTitle,
}) async {
  final path = await ref.read(codexSessionActionRepositoryProvider).pickAndExport(
        detail: detail,
        format: format,
        dialogTitle: dialogTitle,
      );
  if (path == null) return null;
  AppLogService.instance.info(
    'CodexExport',
    '已导出会话',
    details: 'id=${detail.id} format=$format path=$path',
  );
  return path;
}

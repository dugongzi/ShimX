import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/features/claude_session/data/datasources/claude_session_export_datasource.dart';
import 'package:shim/core/utils/claude_session_export_formatter.dart';
import 'package:shim/features/claude_session/data/repositories/claude_session_export_repository_impl.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_detail.dart';
import 'package:shim/features/claude_session/domain/repositories/claude_session_export_repository.dart';

part 'claude_session_export_provider.g.dart';

@riverpod
ClaudeSessionExportRepository claudeSessionExportRepository(Ref ref) {
  return ClaudeSessionExportRepositoryImpl(
    dataSource: ClaudeSessionExportDatasource(),
    formatter: ClaudeSessionExportFormatter(),
  );
}

/// 完整加载 jsonl 成 detail (用于详情视图 + 导出共用)
@riverpod
Future<ClaudeThreadDetail> claudeThreadDetail(
  Ref ref, {
  required String jsonlPath,
}) {
  return ref
      .read(claudeSessionExportRepositoryProvider)
      .loadThreadDetail(jsonlPath: jsonlPath);
}

/// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。
Future<String?> exportClaudeThread({
  required ClaudeSessionExportRepository repo,
  required ClaudeThreadDetail detail,
  required String format,
}) async {
  final defaultName = _defaultFileName(
    detail.title.isEmpty ? detail.sessionId : detail.title,
    format,
  );
  final outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Export Claude Code conversation',
    fileName: defaultName,
    type: FileType.custom,
    allowedExtensions: [_extOf(format)],
  );
  if (outputPath == null) return null;
  await repo.exportToFile(
    detail: detail,
    format: format,
    outputPath: outputPath,
  );
  AppLogService.instance.info(
    'ClaudeExport',
    '已导出会话',
    details: 'session=${detail.sessionId} format=$format path=$outputPath',
  );
  return outputPath;
}

String _extOf(String format) {
  switch (format) {
    case 'markdown':
      return 'md';
    case 'raws':
      return 'jsonl';
    default:
      return 'txt';
  }
}

String _defaultFileName(String title, String format) {
  final safe = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return '$safe.${_extOf(format)}';
}

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/utils/claude_session_export_formatter.dart';
import 'package:shimx/features/claude_session/data/datasources/claude_session_action_datasource.dart';
import 'package:shimx/features/claude_session/data/repositories/claude_session_action_repository_impl.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';
import 'package:shimx/features/claude_session/domain/repositories/claude_session_action_repository.dart';

part 'claude_session_action_provider.g.dart';

@riverpod
ClaudeSessionActionRepository claudeSessionActionRepository(Ref ref) {
  return ClaudeSessionActionRepositoryImpl(
    dataSource: ClaudeSessionActionDatasource(
      formatter: ClaudeSessionExportFormatter(),
    ),
  );
}

/// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。
@riverpod
Future<String?> exportClaudeThread(
  Ref ref, {
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
  await ref.read(claudeSessionActionRepositoryProvider).exportToFile(
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

/// 删除某 Claude 会话:jsonl 备份到 appSupport 下再删除原文件。返回备份路径。
@riverpod
Future<String> deleteClaudeThread(
  Ref ref, {
  required String jsonlPath,
}) async {
  final backupPath = await ref
      .read(claudeSessionActionRepositoryProvider)
      .deleteThread(jsonlPath: jsonlPath);
  AppLogService.instance.info(
    'ClaudeSession',
    '已删除会话',
    details: 'jsonl=$jsonlPath backup=$backupPath',
  );
  return backupPath;
}

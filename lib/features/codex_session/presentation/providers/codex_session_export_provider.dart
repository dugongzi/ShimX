import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/codex_session/data/datasources/codex_session_export_datasource.dart';
import 'package:shim/core/utils/codex_session_export_formatter.dart';
import 'package:shim/features/codex_session/data/repositories/codex_session_export_repository_impl.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_export_repository.dart';

part 'codex_session_export_provider.g.dart';

@riverpod
CodexSessionExportRepository codexSessionExportRepository(Ref ref) {
  return CodexSessionExportRepositoryImpl(
    dataSource: CodexSessionExportDatasource(),
    formatter: CodexSessionExportFormatter(),
  );
}

@riverpod
Future<CodexThreadDetail> codexThreadDetail(
  Ref ref, {
  required String id,
}) {
  return ref.read(codexSessionExportRepositoryProvider).loadThreadDetail(id: id);
}

/// 把导出会话路由注册到 bridge。
///
/// /session/export — 弹系统保存对话框 → 选完路径后真正写文件。
///   payload.id     thread id (required)
///   payload.format 'markdown' | 'raws' (required)
@Riverpod(keepAlive: true)
bool codexSessionExportRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final repo = ref.read(codexSessionExportRepositoryProvider);

  bridge.register('/session/export', (payload) async {
    final id = (payload['id'] as String?)?.trim();
    final format = (payload['format'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw ArgumentError('missing id');
    }
    if (format == null || format.isEmpty) {
      throw ArgumentError('missing format');
    }

    final detail = await repo.loadThreadDetail(id: id);
    final defaultName = _defaultFileName(detail.title.isEmpty ? id : detail.title, format);
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export conversation',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: [_extOf(format)],
    );
    if (outputPath == null) {
      // 用户取消
      return {'ok': false, 'cancelled': true};
    }

    await repo.exportToFile(
      detail: detail,
      format: format,
      outputPath: outputPath,
    );
    AppLogService.instance.info(
      'CodexExport',
      '已导出会话',
      details: 'id=$id format=$format path=$outputPath',
    );
    return {'ok': true, 'path': outputPath, 'format': format};
  });

  return true;
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

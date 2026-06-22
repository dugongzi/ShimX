import 'dart:io';

import 'package:shim/features/claude_session/data/datasources/claude_session_export_datasource.dart';
import 'package:shim/core/utils/claude_session_export_formatter.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_detail.dart';
import 'package:shim/features/claude_session/domain/repositories/claude_session_export_repository.dart';

class ClaudeSessionExportRepositoryImpl
    implements ClaudeSessionExportRepository {
  final ClaudeSessionExportDatasource dataSource;
  final ClaudeSessionExportFormatter formatter;

  ClaudeSessionExportRepositoryImpl({
    required this.dataSource,
    required this.formatter,
  });

  @override
  Future<ClaudeThreadDetail> loadThreadDetail({
    required String jsonlPath,
  }) async {
    final dto = await dataSource.loadDetail(jsonlPath: jsonlPath);
    return dto.toEntity();
  }

  @override
  Future<void> exportToFile({
    required ClaudeThreadDetail detail,
    required String format,
    required String outputPath,
  }) async {
    switch (format) {
      case 'raws':
        if (detail.jsonlPath.isEmpty) {
          throw StateError('jsonl path is empty');
        }
        final src = File(detail.jsonlPath);
        if (!await src.exists()) {
          throw StateError('jsonl file not found: ${detail.jsonlPath}');
        }
        await src.copy(outputPath);
        return;
      case 'markdown':
        final md = formatter.renderMarkdown(detail);
        await File(outputPath).writeAsString(md);
        return;
      default:
        throw ArgumentError('unsupported format: $format');
    }
  }
}

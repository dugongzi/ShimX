import 'dart:io';

import 'package:shimx/core/utils/claude_session_export_formatter.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';

/// 会话相关的写操作(导出落盘等)。读取/解析 jsonl 见 ClaudeSessionQueryDatasource。
class ClaudeSessionActionDatasource {
  ClaudeSessionActionDatasource({required this.formatter});

  final ClaudeSessionExportFormatter formatter;

  /// 把已加载的 detail 按 format 输出到 outputPath。
  /// format ∈ { markdown, raws }。raws 直接拷贝原 jsonl。
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

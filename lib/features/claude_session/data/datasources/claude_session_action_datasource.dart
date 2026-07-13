import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shimx/core/utils/claude_session_export_formatter.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';

/// 会话相关的写操作(导出落盘 / 删除)。读取/解析 jsonl 见 ClaudeSessionQueryDatasource。
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

  /// 删除 jsonl 文件:先复制到备份目录(带时间戳),再删原文件。
  /// 备份路径:`<appSupport>/backups/claude_session_delete/<ts>_<basename>`
  /// 与 codex 侧删除备份同层同风格,便于用户找到误删的会话。
  Future<String> deleteThread({required String jsonlPath}) async {
    if (jsonlPath.isEmpty) {
      throw StateError('jsonl path is empty');
    }
    final src = File(jsonlPath);
    if (!await src.exists()) {
      throw StateError('jsonl file not found: $jsonlPath');
    }
    final backupPath = await _backupPath(jsonlPath);
    await src.copy(backupPath);
    await src.delete();
    return backupPath;
  }

  Future<String> _backupPath(String jsonlPath) async {
    final dir = await getApplicationSupportDirectory();
    final backupDir =
        Directory(p.join(dir.path, 'backups', 'claude_session_delete'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = p.basename(jsonlPath);
    return p.join(backupDir.path, '${ts}_$base');
  }
}

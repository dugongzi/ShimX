import 'package:shim/features/claude_session/domain/models/claude_thread_detail.dart';

abstract class ClaudeSessionExportRepository {
  /// 完整解析 jsonl 成 detail(含全部消息)。
  Future<ClaudeThreadDetail> loadThreadDetail({required String jsonlPath});

  /// format ∈ { markdown, raws }。raws 直接拷贝原 jsonl,markdown 走 formatter。
  Future<void> exportToFile({
    required ClaudeThreadDetail detail,
    required String format,
    required String outputPath,
  });
}

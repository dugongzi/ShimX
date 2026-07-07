import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';

abstract class ClaudeSessionActionRepository {
  /// format ∈ { markdown, raws }。raws 直接拷贝原 jsonl,markdown 走 formatter。
  Future<void> exportToFile({
    required ClaudeThreadDetail detail,
    required String format,
    required String outputPath,
  });
}

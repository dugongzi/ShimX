import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';

abstract class ClaudeSessionActionRepository {
  /// format ∈ { markdown, raws }。raws 直接拷贝原 jsonl,markdown 走 formatter。
  Future<void> exportToFile({
    required ClaudeThreadDetail detail,
    required String format,
    required String outputPath,
  });

  /// 删除会话。先把 jsonl 挪到备份目录(带时间戳),再从原目录移除,
  /// 便于用户误删后回滚。返回备份文件路径。
  Future<String> deleteThread({required String jsonlPath});
}

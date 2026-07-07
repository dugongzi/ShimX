import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_message.dart';

part 'claude_thread_detail.freezed.dart';

/// 一个 Claude Code 会话的完整明细:头部元信息 + 解析出的消息流。导出用。
@freezed
abstract class ClaudeThreadDetail with _$ClaudeThreadDetail {
  const ClaudeThreadDetail._();

  const factory ClaudeThreadDetail({
    required String sessionId,
    required String title,
    required String cwd,
    required String gitBranch,
    required String cliVersion,
    /// 原始 jsonl 路径
    required String jsonlPath,
    required int createdAtMs,
    required int updatedAtMs,
    required List<ClaudeThreadMessage> messages,
  }) = _ClaudeThreadDetail;
}

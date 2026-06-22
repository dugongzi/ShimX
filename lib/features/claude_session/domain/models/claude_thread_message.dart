import 'package:freezed_annotation/freezed_annotation.dart';

part 'claude_thread_message.freezed.dart';

/// 单条 Claude Code 对话消息。
///
/// kind:
///   text        — 普通文本(user / assistant 的文本块)
///   tool_use    — assistant 工具调用(toolName + JSON 参数)
///   tool_result — 工具返回
///   raws        — 无法识别的兜底
@freezed
abstract class ClaudeThreadMessage with _$ClaudeThreadMessage {
  const ClaudeThreadMessage._();

  const factory ClaudeThreadMessage({
    required int index,
    /// 事件 ISO8601 UTC,可能空
    required String timestamp,
    /// user / assistant / tool
    required String role,
    /// text / tool_use / tool_result / raws
    required String kind,
    required String text,
    /// 仅 tool_use 时有值
    @Default('') String toolName,
  }) = _ClaudeThreadMessage;
}

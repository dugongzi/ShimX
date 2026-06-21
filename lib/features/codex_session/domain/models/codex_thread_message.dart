import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_thread_message.freezed.dart';

/// 单条对话消息(从 rollout JSONL 的 response_item / event_msg 解析后归一)。
///
/// kind:
///   text      — 普通文本(role=user/assistant/system/developer 的 input_text/output_text)
///   tool_use  — 工具调用(name + 参数 JSON)
///   tool_result — 工具返回
///   raws       — 解析不出的兜底,原文整段 JSON
@freezed
abstract class CodexThreadMessage with _$CodexThreadMessage {
  const CodexThreadMessage._();

  const factory CodexThreadMessage({
    /// 0-based 在 rollout 流里的位置
    required int index,
    /// 事件时间戳(ISO 8601 UTC)。可能为空字符串,表示没拿到。
    required String timestamp,
    /// user / assistant / developer / system / tool
    required String role,
    /// text / tool_use / tool_result / raws
    required String kind,
    /// 纯文本内容(tool_use 时是 "<toolName>(<jsonArgs>)" 之类的字符串描述)
    required String text,
  }) = _CodexThreadMessage;
}

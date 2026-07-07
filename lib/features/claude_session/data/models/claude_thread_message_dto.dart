import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_message.dart';

part 'claude_thread_message_dto.freezed.dart';
part 'claude_thread_message_dto.g.dart';

@freezed
abstract class ClaudeThreadMessageDto with _$ClaudeThreadMessageDto {
  const ClaudeThreadMessageDto._();

  const factory ClaudeThreadMessageDto({
    @Default(0) int index,
    @Default('') String timestamp,
    @Default('') String role,
    @Default('text') String kind,
    @Default('') String text,
    @Default('') String toolName,
  }) = _ClaudeThreadMessageDto;

  factory ClaudeThreadMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ClaudeThreadMessageDtoFromJson(json);

  ClaudeThreadMessage toEntity() {
    return ClaudeThreadMessage(
      index: index,
      timestamp: timestamp,
      role: role,
      kind: kind,
      text: text,
      toolName: toolName,
    );
  }
}

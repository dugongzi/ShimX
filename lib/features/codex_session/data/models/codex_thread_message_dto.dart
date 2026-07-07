import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_message.dart';

part 'codex_thread_message_dto.freezed.dart';
part 'codex_thread_message_dto.g.dart';

@freezed
abstract class CodexThreadMessageDto with _$CodexThreadMessageDto {
  const CodexThreadMessageDto._();

  const factory CodexThreadMessageDto({
    @Default(0) int index,
    @Default('') String timestamp,
    @Default('') String role,
    @Default('text') String kind,
    @Default('') String text,
  }) = _CodexThreadMessageDto;

  factory CodexThreadMessageDto.fromJson(Map<String, dynamic> json) =>
      _$CodexThreadMessageDtoFromJson(json);

  CodexThreadMessage toEntity() {
    return CodexThreadMessage(
      index: index,
      timestamp: timestamp,
      role: role,
      kind: kind,
      text: text,
    );
  }
}

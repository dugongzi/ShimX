import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/codex_session/data/models/codex_thread_message_dto.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';

part 'codex_thread_detail_dto.freezed.dart';
part 'codex_thread_detail_dto.g.dart';

@freezed
abstract class CodexThreadDetailDto with _$CodexThreadDetailDto {
  const CodexThreadDetailDto._();

  const factory CodexThreadDetailDto({
    @Default('') String id,
    @Default('') String title,
    @Default('') String cwd,
    @Default(0) int createdAtMs,
    @Default(0) int updatedAtMs,
    @Default('') String modelProvider,
    @Default('') String model,
    @Default('') String cliVersion,
    @Default('') String rolloutPath,
    @Default([]) List<CodexThreadMessageDto> messages,
  }) = _CodexThreadDetailDto;

  factory CodexThreadDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CodexThreadDetailDtoFromJson(json);

  CodexThreadDetail toEntity() {
    return CodexThreadDetail(
      id: id,
      title: title,
      cwd: cwd,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      modelProvider: modelProvider,
      model: model,
      cliVersion: cliVersion,
      rolloutPath: rolloutPath,
      messages: messages.map((m) => m.toEntity()).toList(),
    );
  }
}

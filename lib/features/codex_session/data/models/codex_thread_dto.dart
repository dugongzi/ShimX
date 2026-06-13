import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread.dart';

part 'codex_thread_dto.freezed.dart';
part 'codex_thread_dto.g.dart';

@freezed
abstract class CodexThreadDto with _$CodexThreadDto {
  const CodexThreadDto._();

  const factory CodexThreadDto({
    @Default('') String id,
    @Default('') String title,
    @Default('') String preview,
    @Default('') String firstUserMessage,
    @Default('') String cwd,
    @Default(0) int archived,
    @Default(0) int updatedAtMs,
    @Default(0) int createdAtMs,
    @Default(0) int tokensUsed,
  }) = _CodexThreadDto;

  factory CodexThreadDto.fromJson(Map<String, dynamic> json) =>
      _$CodexThreadDtoFromJson(json);

  CodexThread toEntity() {
    return CodexThread(
      id: id,
      title: title,
      preview: preview,
      firstUserMessage: firstUserMessage,
      cwd: cwd,
      archived: archived != 0,
      updatedAtMs: updatedAtMs,
      createdAtMs: createdAtMs,
      tokensUsed: tokensUsed,
    );
  }
}

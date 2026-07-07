import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread.dart';

part 'claude_thread_dto.freezed.dart';
part 'claude_thread_dto.g.dart';

@freezed
abstract class ClaudeThreadDto with _$ClaudeThreadDto {
  const ClaudeThreadDto._();

  const factory ClaudeThreadDto({
    @Default('') String sessionId,
    @Default('') String jsonlPath,
    @Default('') String title,
    @Default('') String preview,
    @Default('') String cwd,
    @Default('') String gitBranch,
    @Default(0) int updatedAtMs,
    @Default(0) int createdAtMs,
    @Default(0) int sizeBytes,
  }) = _ClaudeThreadDto;

  factory ClaudeThreadDto.fromJson(Map<String, dynamic> json) =>
      _$ClaudeThreadDtoFromJson(json);

  ClaudeThread toEntity() {
    return ClaudeThread(
      sessionId: sessionId,
      jsonlPath: jsonlPath,
      title: title,
      preview: preview,
      cwd: cwd,
      gitBranch: gitBranch,
      updatedAtMs: updatedAtMs,
      createdAtMs: createdAtMs,
      sizeBytes: sizeBytes,
    );
  }
}

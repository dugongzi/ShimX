import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/claude_session/domain/models/claude_project.dart';

part 'claude_project_dto.freezed.dart';
part 'claude_project_dto.g.dart';

@freezed
abstract class ClaudeProjectDto with _$ClaudeProjectDto {
  const ClaudeProjectDto._();

  const factory ClaudeProjectDto({
    @Default('') String encodedDir,
    @Default('') String cwd,
    @Default(0) int sessionCount,
    @Default(0) int lastActiveMs,
  }) = _ClaudeProjectDto;

  factory ClaudeProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ClaudeProjectDtoFromJson(json);

  ClaudeProject toEntity() {
    return ClaudeProject(
      encodedDir: encodedDir,
      cwd: cwd,
      sessionCount: sessionCount,
      lastActiveMs: lastActiveMs,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/codex_session/domain/models/codex_project.dart';

part 'codex_project_dto.freezed.dart';
part 'codex_project_dto.g.dart';

@freezed
abstract class CodexProjectDto with _$CodexProjectDto {
  const CodexProjectDto._();

  const factory CodexProjectDto({
    @Default('') String cwd,
    @Default(0) int sessionCount,
    @Default(0) int lastActiveMs,
  }) = _CodexProjectDto;

  factory CodexProjectDto.fromJson(Map<String, dynamic> json) =>
      _$CodexProjectDtoFromJson(json);

  CodexProject toEntity() {
    return CodexProject(
      cwd: cwd,
      sessionCount: sessionCount,
      lastActiveMs: lastActiveMs,
    );
  }
}

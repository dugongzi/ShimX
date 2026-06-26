import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/features/skills/domain/models/codex_skill.dart';

part 'codex_skill_dto.freezed.dart';
part 'codex_skill_dto.g.dart';

@freezed
abstract class CodexSkillDto with _$CodexSkillDto {
  const CodexSkillDto._();

  const factory CodexSkillDto({
    @Default('') String id,
    @Default('') String name,
    @Default('') String description,
    @Default('') String path,
    @Default(false) bool managedByShim,
    @Default(true) bool readOnly,
    @Default(false) bool hasSkillFile,
    @Default(0) int installedAt,
    @Default('') String contentHash,
  }) = _CodexSkillDto;

  factory CodexSkillDto.fromJson(Map<String, Object?> json) =>
      _$CodexSkillDtoFromJson(json);

  factory CodexSkillDto.fromEntity(CodexSkill entity) {
    return CodexSkillDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      path: entity.path,
      managedByShim: entity.managedByShim,
      readOnly: entity.readOnly,
      hasSkillFile: entity.hasSkillFile,
      installedAt: entity.installedAt,
      contentHash: entity.contentHash,
    );
  }

  CodexSkill toEntity() {
    return CodexSkill(
      id: id,
      name: name,
      description: description,
      path: path,
      managedByShim: managedByShim,
      readOnly: readOnly,
      hasSkillFile: hasSkillFile,
      installedAt: installedAt,
      contentHash: contentHash,
    );
  }
}

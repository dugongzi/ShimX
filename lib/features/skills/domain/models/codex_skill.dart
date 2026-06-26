import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_skill.freezed.dart';

@freezed
abstract class CodexSkill with _$CodexSkill {
  const CodexSkill._();

  const factory CodexSkill({
    required String id,
    required String name,
    required String description,
    required String path,
    required bool managedByShim,
    required bool readOnly,
    required bool hasSkillFile,
    required int installedAt,
    required String contentHash,
  }) = _CodexSkill;
}

class CodexSkillSourceType {
  const CodexSkillSourceType._();

  static const folder = 'folder';
  static const zip = 'zip';
  static const imported = 'imported';
}

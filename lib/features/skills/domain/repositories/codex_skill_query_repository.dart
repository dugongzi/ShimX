import 'package:shim/features/skills/domain/models/codex_skill.dart';

abstract class CodexSkillQueryRepository {
  Future<List<CodexSkill>> listSkills();
}

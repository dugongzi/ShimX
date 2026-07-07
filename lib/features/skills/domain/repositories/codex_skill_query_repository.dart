import 'package:shimx/features/skills/domain/models/codex_skill.dart';

abstract class CodexSkillQueryRepository {
  Future<List<CodexSkill>> listSkills();
}

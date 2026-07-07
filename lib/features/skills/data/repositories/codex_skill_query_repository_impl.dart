import 'package:shimx/features/skills/data/datasources/codex_skill_query_datasource.dart';
import 'package:shimx/features/skills/domain/models/codex_skill.dart';
import 'package:shimx/features/skills/domain/repositories/codex_skill_query_repository.dart';

class CodexSkillQueryRepositoryImpl implements CodexSkillQueryRepository {
  CodexSkillQueryRepositoryImpl({required this.dataSource});

  final CodexSkillQueryDatasource dataSource;

  @override
  Future<List<CodexSkill>> listSkills() async {
    final skills = await dataSource.listSkills();
    return skills.map((skill) => skill.toEntity()).toList();
  }
}

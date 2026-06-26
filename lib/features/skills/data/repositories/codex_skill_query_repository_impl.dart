import 'package:shim/features/skills/data/datasources/codex_skill_query_datasource.dart';
import 'package:shim/features/skills/domain/models/codex_skill.dart';
import 'package:shim/features/skills/domain/repositories/codex_skill_query_repository.dart';

class CodexSkillQueryRepositoryImpl implements CodexSkillQueryRepository {
  CodexSkillQueryRepositoryImpl({required this.dataSource});

  final CodexSkillQueryDatasource dataSource;

  @override
  Future<List<CodexSkill>> listSkills() async {
    final skills = await dataSource.listSkills();
    return skills.map((skill) => skill.toEntity()).toList();
  }
}

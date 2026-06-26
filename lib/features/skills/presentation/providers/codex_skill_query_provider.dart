import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/skills/data/datasources/codex_skill_query_datasource.dart';
import 'package:shim/features/skills/data/datasources/codex_skill_registry.dart';
import 'package:shim/features/skills/data/repositories/codex_skill_query_repository_impl.dart';
import 'package:shim/features/skills/domain/models/codex_skill.dart';
import 'package:shim/features/skills/domain/repositories/codex_skill_query_repository.dart';

part 'codex_skill_query_provider.g.dart';

@riverpod
CodexSkillQueryRepository codexSkillQueryRepository(Ref ref) {
  return CodexSkillQueryRepositoryImpl(
    dataSource: CodexSkillQueryDatasource(
      registry: CodexSkillRegistry(storage: ref.read(appStorageProvider)),
    ),
  );
}

@riverpod
Future<List<CodexSkill>> codexSkills(Ref ref) {
  return ref.read(codexSkillQueryRepositoryProvider).listSkills();
}

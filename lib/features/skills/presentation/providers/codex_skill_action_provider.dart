import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/skills/data/datasources/codex_skill_action_datasource.dart';
import 'package:shim/features/skills/data/datasources/codex_skill_registry.dart';
import 'package:shim/features/skills/data/repositories/codex_skill_action_repository_impl.dart';
import 'package:shim/features/skills/domain/repositories/codex_skill_action_repository.dart';
import 'package:shim/features/skills/presentation/providers/codex_skill_query_provider.dart';

part 'codex_skill_action_provider.g.dart';

@Riverpod(keepAlive: true)
CodexSkillActionRepository codexSkillActionRepository(Ref ref) {
  return CodexSkillActionRepositoryImpl(
    dataSource: CodexSkillActionDatasource(
      registry: CodexSkillRegistry(storage: ref.read(appStorageProvider)),
    ),
  );
}

@Riverpod(keepAlive: true)
class CodexSkillActions extends _$CodexSkillActions {
  @override
  void build() {}

  Future<void> installFromFolder({
    required String sourcePath,
    bool overwriteManaged = false,
  }) async {
    await ref
        .read(codexSkillActionRepositoryProvider)
        .installFromFolder(
          sourcePath: sourcePath,
          overwriteManaged: overwriteManaged,
        );
    if (!ref.mounted) return;
    ref.invalidate(codexSkillsProvider);
  }

  Future<List<String>> listZipSkillDirectories({required String zipPath}) {
    return ref
        .read(codexSkillActionRepositoryProvider)
        .listZipSkillDirectories(zipPath: zipPath);
  }

  Future<void> installFromZip({
    required String zipPath,
    String? skillDirectory,
    bool overwriteManaged = false,
  }) async {
    await ref
        .read(codexSkillActionRepositoryProvider)
        .installFromZip(
          zipPath: zipPath,
          skillDirectory: skillDirectory,
          overwriteManaged: overwriteManaged,
        );
    if (!ref.mounted) return;
    ref.invalidate(codexSkillsProvider);
  }

  Future<void> importExisting({required String id}) async {
    await ref.read(codexSkillActionRepositoryProvider).importExisting(id: id);
    if (!ref.mounted) return;
    ref.invalidate(codexSkillsProvider);
  }

  Future<void> deleteManaged({required String id}) async {
    await ref.read(codexSkillActionRepositoryProvider).deleteManaged(id: id);
    if (!ref.mounted) return;
    ref.invalidate(codexSkillsProvider);
  }
}

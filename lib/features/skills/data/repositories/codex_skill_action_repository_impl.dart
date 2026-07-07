import 'package:shimx/features/skills/data/datasources/codex_skill_action_datasource.dart';
import 'package:shimx/features/skills/domain/repositories/codex_skill_action_repository.dart';

class CodexSkillActionRepositoryImpl implements CodexSkillActionRepository {
  CodexSkillActionRepositoryImpl({required this.dataSource});

  final CodexSkillActionDatasource dataSource;

  @override
  Future<void> installFromFolder({
    required String sourcePath,
    bool overwriteManaged = false,
  }) {
    return dataSource.installFromFolder(
      sourcePath: sourcePath,
      overwriteManaged: overwriteManaged,
    );
  }

  @override
  Future<List<String>> listZipSkillDirectories({required String zipPath}) {
    return dataSource.listZipSkillDirectories(zipPath: zipPath);
  }

  @override
  Future<void> installFromZip({
    required String zipPath,
    String? skillDirectory,
    bool overwriteManaged = false,
  }) {
    return dataSource.installFromZip(
      zipPath: zipPath,
      skillDirectory: skillDirectory,
      overwriteManaged: overwriteManaged,
    );
  }

  @override
  Future<void> importExisting({required String id}) {
    return dataSource.importExisting(id: id);
  }

  @override
  Future<void> deleteManaged({required String id}) {
    return dataSource.deleteManaged(id: id);
  }
}

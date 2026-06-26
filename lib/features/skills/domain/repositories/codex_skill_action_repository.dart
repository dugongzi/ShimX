abstract class CodexSkillActionRepository {
  Future<void> installFromFolder({
    required String sourcePath,
    bool overwriteManaged,
  });

  Future<List<String>> listZipSkillDirectories({required String zipPath});

  Future<void> installFromZip({
    required String zipPath,
    String? skillDirectory,
    bool overwriteManaged,
  });

  Future<void> importExisting({required String id});

  Future<void> deleteManaged({required String id});
}

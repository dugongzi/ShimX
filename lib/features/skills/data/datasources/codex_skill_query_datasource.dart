import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shimx/core/utils/codex_skill_file_utils.dart';
import 'package:shimx/features/skills/data/datasources/codex_skill_registry.dart';
import 'package:shimx/features/skills/data/models/codex_skill_dto.dart';

class CodexSkillQueryDatasource {
  CodexSkillQueryDatasource({
    Directory? skillsDirectory,
    CodexSkillRegistry? registry,
  }) : _skillsDirectory = skillsDirectory,
       _registry = registry ?? CodexSkillRegistry();

  final Directory? _skillsDirectory;
  final CodexSkillRegistry _registry;

  Future<List<CodexSkillDto>> listSkills() async {
    final dir = _codexSkillsDirectory();
    if (dir == null || !await dir.exists()) return [];
    final registry = await _registry.read();
    final skills = <CodexSkillDto>[];

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final id = p.basename(entity.path);
      if (id.startsWith('.')) continue;
      final skillFile = File(p.join(entity.path, 'SKILL.md'));
      final hasSkillFile = await skillFile.exists();
      if (!hasSkillFile) continue;
      final meta = readCodexSkillMetadata(entity);
      final entry = registry[id];
      final managed = entry != null;
      final installedAt = switch (entry?['installedAt']) {
        final int value => value,
        final num value => value.toInt(),
        _ => 0,
      };
      final contentHash = await computeCodexSkillHashInBackground(entity);
      skills.add(
        CodexSkillDto(
          id: id,
          name: meta.name,
          description: meta.description,
          path: entity.path,
          managedByShimX: managed,
          readOnly: !managed,
          hasSkillFile: hasSkillFile,
          installedAt: installedAt,
          contentHash: contentHash,
        ),
      );
    }

    skills.sort((a, b) {
      if (a.managedByShimX != b.managedByShimX) {
        return a.managedByShimX ? -1 : 1;
      }
      return a.id.compareTo(b.id);
    });
    return skills;
  }

  Directory? _codexSkillsDirectory() {
    if (_skillsDirectory != null) return _skillsDirectory;
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;
    return Directory(p.join(home, '.codex', 'skills'));
  }
}

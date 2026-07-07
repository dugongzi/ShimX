import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shimx/features/skills/data/datasources/codex_skill_action_datasource.dart';
import 'package:shimx/features/skills/data/datasources/codex_skill_query_datasource.dart';
import 'package:shimx/features/skills/data/datasources/codex_skill_registry.dart';
import 'package:shimx/features/skills/data/repositories/codex_skill_query_repository_impl.dart';
import 'package:shimx/features/skills/domain/models/codex_skill.dart';

void main() {
  late Directory tempDir;
  late Directory skillsDir;
  late Map<String, Map<String, Object?>> registryMemory;
  late CodexSkillRegistry registry;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('shimx_codex_skill_test_');
    skillsDir = Directory(p.join(tempDir.path, 'skills'));
    registryMemory = {};
    registry = CodexSkillRegistry(memory: registryMemory);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('query scans managed and external skills with frontmatter', () async {
    await _writeSkill(
      Directory(p.join(skillsDir.path, 'managed_skill')),
      name: 'Managed Skill',
      description: 'Managed description',
    );
    await _writeSkill(
      Directory(p.join(skillsDir.path, 'external_skill')),
      name: 'External Skill',
      description: 'External description',
    );
    registryMemory['managed_skill'] = {
      'installedAt': 123,
      'sourceType': CodexSkillSourceType.imported,
      'sourcePath': p.join(skillsDir.path, 'managed_skill'),
      'contentHash': 'old',
    };

    final datasource = CodexSkillQueryDatasource(
      skillsDirectory: skillsDir,
      registry: registry,
    );

    final skills = await datasource.listSkills();

    expect(skills.map((skill) => skill.id), [
      'managed_skill',
      'external_skill',
    ]);
    expect(skills.first.name, 'Managed Skill');
    expect(skills.first.description, 'Managed description');
    expect(skills.first.managedByShimX, isTrue);
    expect(skills.first.readOnly, isFalse);
    expect(skills.last.managedByShimX, isFalse);
    expect(skills.last.readOnly, isTrue);
  });

  test('install folder copies skill and writes registry', () async {
    final source = Directory(p.join(tempDir.path, 'source_skill'));
    await _writeSkill(source, name: 'Folder Skill', description: 'From folder');

    final datasource = CodexSkillActionDatasource(
      skillsDirectory: skillsDir,
      registry: registry,
    );

    await datasource.installFromFolder(sourcePath: source.path);

    final target = Directory(p.join(skillsDir.path, 'source_skill'));
    expect(await File(p.join(target.path, 'SKILL.md')).exists(), isTrue);
    expect(
      registryMemory['source_skill']?['sourceType'],
      CodexSkillSourceType.folder,
    );
    expect(registryMemory['source_skill']?['contentHash'], isA<String>());
  });

  test(
    'zip install copies first skill directory and writes registry',
    () async {
      final zip = File(p.join(tempDir.path, 'bundle.zip'));
      await zip.writeAsBytes(
        _zipBytes({
          'bundle/zip_skill/SKILL.md': _skillText(
            name: 'Zip Skill',
            description: 'From zip',
          ),
          'bundle/zip_skill/notes.txt': 'hello',
        }),
      );

      final datasource = CodexSkillActionDatasource(
        skillsDirectory: skillsDir,
        registry: registry,
      );

      final candidates = await datasource.listZipSkillDirectories(
        zipPath: zip.path,
      );
      expect(candidates, ['bundle/zip_skill']);

      await datasource.installFromZip(zipPath: zip.path);

      final target = Directory(p.join(skillsDir.path, 'zip_skill'));
      expect(await File(p.join(target.path, 'SKILL.md')).exists(), isTrue);
      expect(
        await File(p.join(target.path, 'notes.txt')).readAsString(),
        'hello',
      );
      expect(
        registryMemory['zip_skill']?['sourceType'],
        CodexSkillSourceType.zip,
      );
    },
  );

  test(
    'delete fails for external skill and succeeds for managed skill',
    () async {
      await _writeSkill(
        Directory(p.join(skillsDir.path, 'external_skill')),
        name: 'External Skill',
        description: '',
      );
      await _writeSkill(
        Directory(p.join(skillsDir.path, 'managed_skill')),
        name: 'Managed Skill',
        description: '',
      );
      registryMemory['managed_skill'] = {
        'installedAt': 123,
        'sourceType': CodexSkillSourceType.imported,
        'sourcePath': p.join(skillsDir.path, 'managed_skill'),
        'contentHash': 'old',
      };

      final datasource = CodexSkillActionDatasource(
        skillsDirectory: skillsDir,
        registry: registry,
      );

      await expectLater(
        datasource.deleteManaged(id: 'external_skill'),
        throwsStateError,
      );

      await datasource.deleteManaged(id: 'managed_skill');

      expect(
        await Directory(p.join(skillsDir.path, 'managed_skill')).exists(),
        isFalse,
      );
      expect(registryMemory.containsKey('managed_skill'), isFalse);
      expect(
        await Directory(p.join(skillsDir.path, 'external_skill')).exists(),
        isTrue,
      );
    },
  );

  test('install refuses to overwrite same-name external skill', () async {
    await _writeSkill(
      Directory(p.join(skillsDir.path, 'source_skill')),
      name: 'External',
      description: '',
    );
    final source = Directory(p.join(tempDir.path, 'source_skill'));
    await _writeSkill(source, name: 'Source', description: '');

    final datasource = CodexSkillActionDatasource(
      skillsDirectory: skillsDir,
      registry: registry,
    );

    await expectLater(
      datasource.installFromFolder(sourcePath: source.path),
      throwsStateError,
    );
  });

  test('repository maps DTOs to CodexSkill entities', () async {
    await _writeSkill(
      Directory(p.join(skillsDir.path, 'entity_skill')),
      name: 'Entity Skill',
      description: 'Entity mapping',
    );
    final repository = CodexSkillQueryRepositoryImpl(
      dataSource: CodexSkillQueryDatasource(
        skillsDirectory: skillsDir,
        registry: registry,
      ),
    );

    final skills = await repository.listSkills();

    expect(skills.single, isA<CodexSkill>());
    expect(skills.single.id, 'entity_skill');
    expect(skills.single.name, 'Entity Skill');
  });
}

Future<void> _writeSkill(
  Directory dir, {
  required String name,
  required String description,
}) async {
  await dir.create(recursive: true);
  await File(p.join(dir.path, 'SKILL.md')).writeAsString(
    _skillText(name: name, description: description),
    encoding: utf8,
  );
}

String _skillText({required String name, required String description}) {
  return '''
---
name: "$name"
description: "$description"
---

# $name
''';
}

List<int> _zipBytes(Map<String, String> files) {
  final archive = Archive();
  for (final entry in files.entries) {
    final bytes = utf8.encode(entry.value);
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
  }
  return ZipEncoder().encode(archive);
}

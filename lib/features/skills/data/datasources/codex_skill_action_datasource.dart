import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:shimx/core/utils/codex_skill_file_utils.dart';
import 'package:shimx/features/skills/data/datasources/codex_skill_registry.dart';
import 'package:shimx/features/skills/domain/models/codex_skill.dart';
import 'package:shimx/features/skills/domain/models/skill_overwrite_required_exception.dart';

class CodexSkillActionDatasource {
  CodexSkillActionDatasource({
    Directory? skillsDirectory,
    CodexSkillRegistry? registry,
  }) : _skillsDirectory = skillsDirectory,
       _registry = registry ?? CodexSkillRegistry();

  final Directory? _skillsDirectory;
  final CodexSkillRegistry _registry;

  Future<void> installFromFolder({
    required String sourcePath,
    bool overwriteManaged = false,
  }) async {
    final source = Directory(sourcePath);
    if (!await source.exists()) {
      throw StateError('源目录不存在: $sourcePath');
    }
    if (!await File(p.join(source.path, 'SKILL.md')).exists()) {
      throw StateError('源目录缺少 SKILL.md: $sourcePath');
    }
    final id = validateCodexSkillId(p.basename(source.path));
    final target = await _targetDirectory(id);
    await _ensureCanWriteTarget(
      id: id,
      target: target,
      overwriteManaged: overwriteManaged,
    );
    await replaceDirectoryRecursive(source, target);
    await _markManaged(
      id: id,
      target: target,
      sourceType: CodexSkillSourceType.folder,
      sourcePath: source.path,
    );
  }

  Future<List<String>> listZipSkillDirectories({
    required String zipPath,
  }) async {
    final archive = await _readArchive(zipPath);
    final dirs = <String>{};
    for (final file in archive.files) {
      final normalized = _normalizeZipPath(file.name);
      if (normalized == null) continue;
      if (p.posix.basename(normalized) != 'SKILL.md') continue;
      final dir = p.posix.dirname(normalized);
      dirs.add(dir == '.' ? '' : dir);
    }
    final result = dirs.toList()..sort();
    return result;
  }

  Future<void> installFromZip({
    required String zipPath,
    String? skillDirectory,
    bool overwriteManaged = false,
  }) async {
    final archive = await _readArchive(zipPath);
    final candidates = await listZipSkillDirectories(zipPath: zipPath);
    if (candidates.isEmpty) {
      throw StateError('ZIP 中没有包含 SKILL.md 的目录');
    }
    final selected = skillDirectory ?? candidates.first;
    if (!candidates.contains(selected)) {
      throw StateError('ZIP 中不存在 Skill 目录: $selected');
    }
    final id = validateCodexSkillId(
      selected.isEmpty
          ? p.basenameWithoutExtension(zipPath)
          : p.posix.basename(selected),
    );
    final temp = await Directory.systemTemp.createTemp('shimx_codex_skill_zip_');
    try {
      final source = Directory(p.join(temp.path, id));
      await source.create(recursive: true);
      await _extractArchiveDirectory(
        archive: archive,
        selectedDirectory: selected,
        outputDirectory: source,
      );
      if (!await File(p.join(source.path, 'SKILL.md')).exists()) {
        throw StateError('解压后的 Skill 缺少 SKILL.md');
      }
      final target = await _targetDirectory(id);
      await _ensureCanWriteTarget(
        id: id,
        target: target,
        overwriteManaged: overwriteManaged,
      );
      await replaceDirectoryRecursive(source, target);
      await _markManaged(
        id: id,
        target: target,
        sourceType: CodexSkillSourceType.zip,
        sourcePath: zipPath,
      );
    } finally {
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    }
  }

  Future<void> importExisting({required String id}) async {
    final safeId = validateCodexSkillId(id);
    final target = await _targetDirectory(safeId);
    if (!await target.exists()) {
      throw StateError('Codex Skill 不存在: $safeId');
    }
    if (!await File(p.join(target.path, 'SKILL.md')).exists()) {
      throw StateError('Codex Skill 缺少 SKILL.md: $safeId');
    }
    await _markManaged(
      id: safeId,
      target: target,
      sourceType: CodexSkillSourceType.imported,
      sourcePath: target.path,
    );
  }

  Future<void> deleteManaged({required String id}) async {
    final safeId = validateCodexSkillId(id);
    final registry = await _registry.read();
    if (!registry.containsKey(safeId)) {
      throw StateError('只能删除 shimx 管理的 Skill: $safeId');
    }
    final target = await _targetDirectory(safeId);
    if (await target.exists()) {
      await target.delete(recursive: true);
    }
    registry.remove(safeId);
    await _registry.write(registry);
  }

  Future<Directory> _targetDirectory(String id) async {
    final root = _codexSkillsDirectory();
    if (root == null) {
      throw StateError('Cannot resolve user home directory');
    }
    await root.create(recursive: true);
    return Directory(p.join(root.path, id));
  }

  Future<void> _ensureCanWriteTarget({
    required String id,
    required Directory target,
    required bool overwriteManaged,
  }) async {
    if (!await target.exists()) return;
    final registry = await _registry.read();
    if (!registry.containsKey(id)) {
      throw StateError('同名外部 Skill 已存在，请先导入管理或换名: $id');
    }
    if (!overwriteManaged) {
      throw SkillOverwriteRequiredException(id);
    }
  }

  Future<void> _markManaged({
    required String id,
    required Directory target,
    required String sourceType,
    required String sourcePath,
  }) async {
    final registry = await _registry.read();
    final contentHash = await computeCodexSkillHashInBackground(target);
    registry[id] = {
      'installedAt': DateTime.now().millisecondsSinceEpoch,
      'sourceType': sourceType,
      'sourcePath': sourcePath,
      'contentHash': contentHash,
    };
    await _registry.write(registry);
  }

  Future<Archive> _readArchive(String zipPath) async {
    final input = File(zipPath);
    if (!await input.exists()) {
      throw StateError('ZIP 文件不存在: $zipPath');
    }
    return ZipDecoder().decodeBytes(await input.readAsBytes());
  }

  Future<void> _extractArchiveDirectory({
    required Archive archive,
    required String selectedDirectory,
    required Directory outputDirectory,
  }) async {
    final prefix = selectedDirectory.isEmpty ? '' : '$selectedDirectory/';
    for (final entry in archive.files) {
      if (entry.isFile != true) continue;
      final normalized = _normalizeZipPath(entry.name);
      if (normalized == null) continue;
      if (prefix.isNotEmpty && !normalized.startsWith(prefix)) continue;
      final relative = prefix.isEmpty
          ? normalized
          : normalized.substring(prefix.length);
      if (relative.isEmpty || relative.startsWith('../')) continue;
      final outFile = File(
        p.joinAll([outputDirectory.path, ...relative.split('/')]),
      );
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(entry.content as List<int>, flush: true);
    }
  }

  String? _normalizeZipPath(String rawPath) {
    final normalized = rawPath.replaceAll(r'\', '/');
    final parts = <String>[];
    for (final part in normalized.split('/')) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') return null;
      parts.add(part);
    }
    if (parts.isEmpty) return null;
    return parts.join('/');
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

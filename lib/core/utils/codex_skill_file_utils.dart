import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

class CodexSkillMetadata {
  const CodexSkillMetadata({required this.name, required this.description});

  final String name;
  final String description;
}

String validateCodexSkillId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Skill ID 不能为空');
  }
  if (trimmed == '.' ||
      trimmed == '..' ||
      trimmed.startsWith('.') ||
      trimmed.contains('/') ||
      trimmed.contains(r'\')) {
    throw ArgumentError('Skill ID 必须是非隐藏的单段目录名');
  }
  if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(trimmed)) {
    throw ArgumentError('Skill ID 只能包含字母、数字、点、下划线和短横线');
  }
  return trimmed;
}

CodexSkillMetadata readCodexSkillMetadata(Directory skillDir) {
  final fallback = p.basename(skillDir.path);
  final file = File(p.join(skillDir.path, 'SKILL.md'));
  if (!file.existsSync()) {
    return CodexSkillMetadata(name: fallback, description: '');
  }
  final text = file.readAsStringSync(encoding: utf8);
  final meta = _parseFrontMatter(text);
  return CodexSkillMetadata(
    name: meta['name']?.trim().isNotEmpty == true
        ? meta['name']!.trim()
        : fallback,
    description: meta['description']?.trim() ?? '',
  );
}

String computeCodexSkillHash(Directory dir) {
  if (!dir.existsSync()) return '';
  final files =
      dir
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final bytes = BytesBuilder(copy: false);
  for (final file in files) {
    final relative = p
        .relative(file.path, from: dir.path)
        .replaceAll(r'\', '/');
    bytes.add(utf8.encode(relative));
    bytes.add([0]);
    bytes.add(file.readAsBytesSync());
    bytes.add([0]);
  }
  return sha256.convert(bytes.takeBytes()).toString();
}

Future<String> computeCodexSkillHashInBackground(Directory dir) {
  final path = dir.path;
  return Isolate.run(() => computeCodexSkillHash(Directory(path)));
}

Future<void> copyDirectoryRecursive(
  Directory source,
  Directory destination,
) async {
  if (!await source.exists()) {
    throw StateError('源目录不存在: ${source.path}');
  }
  await destination.create(recursive: true);
  await for (final entity in source.list(
    recursive: false,
    followLinks: false,
  )) {
    final name = p.basename(entity.path);
    final targetPath = p.join(destination.path, name);
    if (entity is Directory) {
      await copyDirectoryRecursive(entity, Directory(targetPath));
    } else if (entity is File) {
      await File(targetPath).parent.create(recursive: true);
      await entity.copy(targetPath);
    }
  }
}

Future<void> replaceDirectoryRecursive(
  Directory source,
  Directory destination,
) async {
  final parent = destination.parent;
  await parent.create(recursive: true);
  final tmp = Directory(
    p.join(
      parent.path,
      '.${p.basename(destination.path)}.tmp-${DateTime.now().microsecondsSinceEpoch}',
    ),
  );
  if (await tmp.exists()) {
    await tmp.delete(recursive: true);
  }
  try {
    await copyDirectoryRecursive(source, tmp);
    if (await destination.exists()) {
      await destination.delete(recursive: true);
    }
    await tmp.rename(destination.path);
  } catch (_) {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
    rethrow;
  }
}

Map<String, String> _parseFrontMatter(String text) {
  final normalized = text.trimLeft().replaceFirst('\uFEFF', '');
  if (!normalized.startsWith('---')) return const {};
  final rest = normalized.substring(3);
  final end = RegExp(r'(^|\n)---\s*(\n|$)').firstMatch(rest);
  if (end == null) return const {};
  final frontMatter = rest.substring(0, end.start);
  final result = <String, String>{};
  for (final rawLine in const LineSplitter().convert(frontMatter)) {
    final index = rawLine.indexOf(':');
    if (index <= 0) continue;
    final key = rawLine.substring(0, index).trim();
    final value = rawLine.substring(index + 1).trim();
    if (key == 'name' || key == 'description') {
      result[key] = _stripYamlScalarQuotes(value);
    }
  }
  return result;
}

String _stripYamlScalarQuotes(String value) {
  if (value.length >= 2) {
    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      return value.substring(1, value.length - 1);
    }
  }
  return value;
}

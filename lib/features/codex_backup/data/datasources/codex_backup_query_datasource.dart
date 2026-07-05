import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:shim/features/codex_backup/data/datasources/codex_backup_paths.dart';
import 'package:shim/features/codex_backup/data/models/codex_backup_detail_dto.dart';
import 'package:shim/features/codex_backup/data/models/codex_backup_dto.dart';
import 'package:shim/features/codex_backup/data/models/codex_backup_entry_dto.dart';

/// 只读:扫备份根目录列出备份 + 读单个 manifest 详情。
class CodexBackupQueryDatasource {
  const CodexBackupQueryDatasource();

  /// 列备份 id(时间戳排序,不打开 manifest,只扫目录名),用于分页。
  /// 目录不存在返回空。backupId 就是目录名。
  Future<List<String>> listBackupIds({int limit = 30, int offset = 0}) async {
    final root = await CodexBackupPaths.rootDir();
    if (!root.existsSync()) return const [];
    final ids = <String>[];
    for (final entity in root.listSync()) {
      if (entity is! Directory) continue;
      // 只关心带 manifest 的目录,遗弃残留目录直接跳过
      final manifest = File(
        p.join(entity.path, CodexBackupPaths.manifestFilename()),
      );
      if (!manifest.existsSync()) continue;
      ids.add(p.basename(entity.path));
    }
    // backupId 是 ISO8601 时间戳格式,字典序等于时间序,直接倒序
    ids.sort((a, b) => b.compareTo(a));
    if (offset >= ids.length) return const [];
    final end = (offset + limit).clamp(0, ids.length);
    return ids.sublist(offset, end);
  }

  /// 读单个备份的元信息汇总(不返回 entries 列表,只返回 count + providers)。
  /// 列表 tile 显示用。
  Future<CodexBackupDto?> readSummary(String backupId) async {
    final root = await CodexBackupPaths.rootDir();
    final manifest = File(p.join(
      root.path,
      backupId,
      CodexBackupPaths.manifestFilename(),
    ));
    if (!manifest.existsSync()) return null;
    try {
      final raw = await manifest.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entries = (map['threads'] as List? ?? const [])
          .whereType<Map>()
          .toList();
      final providers = <String>{};
      for (final e in entries) {
        final op = e['originalProvider'];
        if (op is String) providers.add(op);
      }
      return CodexBackupDto(
        backupId: backupId,
        createdAtMs: (map['createdAtMs'] as num?)?.toInt() ?? 0,
        threadCount: entries.length,
        originalProviders: providers.toList()..sort(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 读单个备份的详情(manifest 里的每条 entry)。
  Future<CodexBackupDetailDto?> readDetail(String backupId) async {
    final root = await CodexBackupPaths.rootDir();
    final manifest = File(p.join(
      root.path,
      backupId,
      CodexBackupPaths.manifestFilename(),
    ));
    if (!manifest.existsSync()) return null;
    try {
      final raw = await manifest.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entries = (map['threads'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(CodexBackupEntryDto.fromJson)
          .toList();
      return CodexBackupDetailDto(
        backupId: backupId,
        createdAtMs: (map['createdAtMs'] as num?)?.toInt() ?? 0,
        entries: entries,
      );
    } catch (_) {
      return null;
    }
  }
}

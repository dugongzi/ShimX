import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'package:shimx/features/codex_backup/data/datasources/codex_backup_paths.dart';

/// 只写:创建备份 / 恢复备份 / 删除备份。
///
/// 备份数据全部落在 [CodexBackupPaths.rootDir],恢复时把 rollout jsonl 拷回
/// codex sessions 目录并 UPDATE threads 表的 model_provider。
class CodexBackupActionDatasource {
  const CodexBackupActionDatasource();

  /// 备份给定 threadIds 到一个新的备份目录,返回 backupId。
  ///
  /// 找不到的 thread 静默跳过,不抛错。全部找不到时返回空串(调用方视为"没备份")。
  Future<String> createBackup(List<String> threadIds) async {
    if (threadIds.isEmpty) return '';
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }

    final root = await CodexBackupPaths.ensureRoot();
    var backupId = CodexBackupPaths.newBackupId(DateTime.now());
    var dir = Directory(p.join(root.path, backupId));
    var counter = 1;
    while (dir.existsSync()) {
      backupId = '${CodexBackupPaths.newBackupId(DateTime.now())}-$counter';
      dir = Directory(p.join(root.path, backupId));
      counter += 1;
    }
    dir.createSync(recursive: true);
    final sessionsDir = Directory(p.join(dir.path, CodexBackupPaths.sessionsSubdir()));
    sessionsDir.createSync(recursive: true);

    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      final placeholders = List.filled(threadIds.length, '?').join(', ');
      final rows = db.select(
        '''
        SELECT id, title, cwd, updated_at_ms,
               COALESCE(model_provider, '') AS mp,
               rollout_path
        FROM threads
        WHERE id IN ($placeholders)
        ''',
        threadIds,
      );

      if (rows.isEmpty) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
        return '';
      }

      final entries = <Map<String, dynamic>>[];
      final sqliteRows = <Map<String, dynamic>>[];

      for (final row in rows) {
        final id = (row['id'] as String?) ?? '';
        if (id.isEmpty) continue;
        final rolloutPath = (row['rollout_path'] as String?) ?? '';
        var jsonlFilename = '';
        if (rolloutPath.isNotEmpty) {
          final src = File(rolloutPath);
          if (await src.exists()) {
            jsonlFilename = '$id.jsonl';
            final dst = File(p.join(sessionsDir.path, jsonlFilename));
            await src.copy(dst.path);
          }
        }
        entries.add({
          'threadId': id,
          'title': row['title'] ?? '',
          'cwd': row['cwd'] ?? '',
          'updatedAtMs': row['updated_at_ms'] ?? 0,
          'originalProvider': row['mp'] ?? '',
          'jsonlFilename': jsonlFilename,
        });
        // 完整行的 dump,恢复时兜底。row 本身是 sqlite Row(不可直接 jsonEncode),
        // 手工塞进 map。
        sqliteRows.add({
          'id': id,
          'title': row['title'] ?? '',
          'cwd': row['cwd'] ?? '',
          'model_provider': row['mp'] ?? '',
          'rollout_path': rolloutPath,
          'updated_at_ms': row['updated_at_ms'] ?? 0,
        });
      }

      if (entries.isEmpty) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
        return '';
      }

      final manifest = {
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
        'threads': entries,
      };
      await File(p.join(dir.path, CodexBackupPaths.manifestFilename()))
          .writeAsString(const JsonEncoder.withIndent('  ').convert(manifest));
      await File(p.join(dir.path, CodexBackupPaths.sqliteRowsFilename()))
          .writeAsString(const JsonEncoder.withIndent('  ').convert(sqliteRows));

      return backupId;
    } finally {
      db.dispose();
    }
  }

  /// 恢复备份里的部分或全部 entry。entryIds 为 null 表示恢复全部。
  ///
  /// 每条 entry 的处理:
  ///   1. 如果 threads 表还有该 id:UPDATE 回原 provider,顺便用备份 jsonl 覆盖
  ///      当前 rollout(可能已经被移动改过 session_meta)。
  ///   2. 如果 threads 表已经没有该 id:走 sqliteRows.json 兜底 INSERT 一行,
  ///      并把备份 jsonl 放到一个新的 rollout 路径。
  ///
  /// 返回实际处理成功的条数。
  Future<int> restoreBackup({
    required String backupId,
    List<String>? entryIds,
  }) async {
    final root = await CodexBackupPaths.rootDir();
    final dir = Directory(p.join(root.path, backupId));
    if (!dir.existsSync()) {
      throw StateError('Backup not found: $backupId');
    }
    final manifestFile = File(p.join(dir.path, CodexBackupPaths.manifestFilename()));
    if (!manifestFile.existsSync()) {
      throw StateError('Manifest missing in backup $backupId');
    }
    final manifest = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
    final allEntries = (manifest['threads'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final wanted = entryIds?.toSet();
    final targets = wanted == null
        ? allEntries
        : allEntries.where((e) => wanted.contains(e['threadId'])).toList();

    if (targets.isEmpty) return 0;

    // sqliteRows.json 兜底
    final sqliteRowsFile = File(p.join(dir.path, CodexBackupPaths.sqliteRowsFilename()));
    final sqliteRowsById = <String, Map<String, dynamic>>{};
    if (sqliteRowsFile.existsSync()) {
      try {
        final list = jsonDecode(await sqliteRowsFile.readAsString()) as List;
        for (final row in list.whereType<Map>()) {
          final m = Map<String, dynamic>.from(row);
          final id = m['id'] as String?;
          if (id != null) sqliteRowsById[id] = m;
        }
      } catch (_) {}
    }

    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath);
    var restored = 0;
    try {
      db.execute('BEGIN');
      try {
        for (final entry in targets) {
          final id = entry['threadId'] as String?;
          if (id == null || id.isEmpty) continue;
          final originalProvider = (entry['originalProvider'] as String?) ?? '';
          final jsonlFilename = (entry['jsonlFilename'] as String?) ?? '';

          final existingRows = db.select(
            'SELECT rollout_path FROM threads WHERE id = ?',
            [id],
          );

          String? targetRolloutPath;
          if (existingRows.isNotEmpty) {
            targetRolloutPath = existingRows.first['rollout_path'] as String?;
            db.execute(
              'UPDATE threads SET model_provider = ? WHERE id = ?',
              [originalProvider, id],
            );
          } else {
            // 兜底:从 sqliteRows 拿一行 INSERT 回去
            final saved = sqliteRowsById[id];
            if (saved == null) continue;
            targetRolloutPath = saved['rollout_path'] as String?;
            db.execute(
              '''
              INSERT OR IGNORE INTO threads
              (id, title, cwd, model_provider, rollout_path, updated_at_ms, archived)
              VALUES (?, ?, ?, ?, ?, ?, 0)
              ''',
              [
                id,
                saved['title'] ?? '',
                saved['cwd'] ?? '',
                originalProvider,
                targetRolloutPath ?? '',
                saved['updated_at_ms'] ?? 0,
              ],
            );
          }

          // jsonl 恢复:优先覆盖 rollout_path 指向的文件
          if (jsonlFilename.isNotEmpty && targetRolloutPath != null && targetRolloutPath.isNotEmpty) {
            final src = File(p.join(
              dir.path,
              CodexBackupPaths.sessionsSubdir(),
              jsonlFilename,
            ));
            if (await src.exists()) {
              final dst = File(targetRolloutPath);
              await dst.parent.create(recursive: true);
              await src.copy(dst.path);
            }
          }
          restored += 1;
        }
        db.execute('COMMIT');
      } catch (e) {
        db.execute('ROLLBACK');
        rethrow;
      }
    } finally {
      db.dispose();
    }
    return restored;
  }

  Future<void> deleteBackup(String backupId) async {
    final root = await CodexBackupPaths.rootDir();
    final dir = Directory(p.join(root.path, backupId));
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  String _codexDbPath() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('Cannot resolve user home directory');
    }
    return p.join(home, '.codex', 'state_5.sqlite');
  }
}


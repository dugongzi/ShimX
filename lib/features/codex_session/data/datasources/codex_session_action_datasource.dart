import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class CodexSessionActionDatasource {
  /// 删除会话：备份所有相关行到 JSON，再从所有相关表 DELETE。
  /// 返回备份文件路径供撤销/排查使用。
  Future<String> deleteThread({required String id}) async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath);
    try {
      final backup = <String, dynamic>{
        'id': id,
        'backed_up_at': DateTime.now().toIso8601String(),
        'threads': _dump(db, 'SELECT * FROM threads WHERE id = ?', [id]),
        'thread_dynamic_tools': _dump(
          db,
          'SELECT * FROM thread_dynamic_tools WHERE thread_id = ?',
          [id],
        ),
        'thread_spawn_edges_as_parent': _dump(
          db,
          'SELECT * FROM thread_spawn_edges WHERE parent_thread_id = ?',
          [id],
        ),
        'thread_spawn_edges_as_child': _dump(
          db,
          'SELECT * FROM thread_spawn_edges WHERE child_thread_id = ?',
          [id],
        ),
      };

      final threadRows = backup['threads'] as List<dynamic>;
      if (threadRows.isEmpty) {
        throw StateError('thread not found: $id');
      }

      final backupPath = await _writeBackup(id, backup);

      final rolloutPath = threadRows.first is Map
          ? (threadRows.first as Map)['rollout_path'] as String?
          : null;

      db.execute('BEGIN');
      try {
        db.execute(
          'DELETE FROM thread_dynamic_tools WHERE thread_id = ?',
          [id],
        );
        db.execute(
          'DELETE FROM thread_spawn_edges WHERE parent_thread_id = ? OR child_thread_id = ?',
          [id, id],
        );
        db.execute('DELETE FROM threads WHERE id = ?', [id]);
        db.execute('COMMIT');
      } catch (e) {
        db.execute('ROLLBACK');
        rethrow;
      }

      // SQL 删除成功后再删 rollout 文件，避免 Codex 启动时扫文件重建
      if (rolloutPath != null && rolloutPath.isNotEmpty) {
        final rolloutFile = File(rolloutPath);
        if (await rolloutFile.exists()) {
          try {
            await rolloutFile.delete();
          } catch (_) {}
        }
      }

      return backupPath;
    } finally {
      db.dispose();
    }
  }

  List<Map<String, dynamic>> _dump(
    Database db,
    String sql,
    List<Object?> params,
  ) {
    return db.select(sql, params).map((row) {
      return {for (final k in row.keys) k: row[k]};
    }).toList();
  }

  Future<String> _writeBackup(String id, Map<String, dynamic> backup) async {
    final dir = await getApplicationSupportDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups', 'session_delete'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final safeId = id.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(backupDir.path, '${ts}_$safeId.json'));
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(backup),
    );
    return file.path;
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

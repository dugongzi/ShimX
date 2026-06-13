import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/features/codex_session/data/models/codex_thread_dto.dart';
import 'package:sqlite3/sqlite3.dart';

class CodexSessionQueryDatasource {
  /// 列出未归档会话，按 updated_at_ms 倒序，最多 limit 条
  Future<List<CodexThreadDto>> listThreads({int limit = 100}) async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      final rows = db.select(
        '''
        SELECT id, title, preview, first_user_message, cwd,
               archived, updated_at_ms, created_at_ms, tokens_used
        FROM threads
        WHERE archived = 0
        ORDER BY updated_at_ms DESC
        LIMIT ?
        ''',
        [limit],
      );
      return rows.map((row) {
        return CodexThreadDto.fromJson({
          'id': row['id'] ?? '',
          'title': row['title'] ?? '',
          'preview': row['preview'] ?? '',
          'firstUserMessage': row['first_user_message'] ?? '',
          'cwd': row['cwd'] ?? '',
          'archived': row['archived'] ?? 0,
          'updatedAtMs': row['updated_at_ms'] ?? 0,
          'createdAtMs': row['created_at_ms'] ?? 0,
          'tokensUsed': row['tokens_used'] ?? 0,
        });
      }).toList();
    } finally {
      db.dispose();
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

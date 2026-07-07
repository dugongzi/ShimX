import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shimx/features/codex_session/data/models/codex_bucket_dto.dart';
import 'package:shimx/features/codex_session/data/models/codex_project_dto.dart';
import 'package:shimx/features/codex_session/data/models/codex_thread_detail_dto.dart';
import 'package:shimx/features/codex_session/data/models/codex_thread_dto.dart';
import 'package:sqlite3/sqlite3.dart';

class CodexSessionQueryDatasource {
  /// 列出未归档会话,按 updated_at_ms 倒序,最多 limit 条
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

  /// 按 cwd 分组,做成左栏"项目"列表。同 cwd 归一,空串归为 `(unknown)`。
  /// 按 lastActiveMs 倒序。
  Future<List<CodexProjectDto>> listProjects() async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      final rows = db.select(
        '''
        SELECT COALESCE(NULLIF(cwd, ''), '(unknown)') AS cwd_key,
               COUNT(*) AS session_count,
               MAX(updated_at_ms) AS last_active_ms
        FROM threads
        WHERE archived = 0
        GROUP BY cwd_key
        ORDER BY last_active_ms DESC
        ''',
      );
      return rows.map((row) {
        return CodexProjectDto.fromJson({
          'cwd': row['cwd_key'] ?? '(unknown)',
          'sessionCount': row['session_count'] ?? 0,
          'lastActiveMs': row['last_active_ms'] ?? 0,
        });
      }).toList();
    } finally {
      db.dispose();
    }
  }

  /// 列指定 cwd 下所有 thread(id + title + updated_at_ms),按更新时间倒序。
  /// 用于"按项目导出 zip"。
  ///
  /// Windows 兼容: codex 在 sqlite 里写 cwd 时大多会带 `\\?\` 长路径前缀,
  /// 而 codex sidebar DOM 上的 `data-app-action-sidebar-project-id` 不带前缀,
  /// 所以这里两种形式都查(传入带前缀也兼容)。
  Future<List<Map<String, dynamic>>> listThreadsByCwd({
    required String cwd,
  }) async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final variants = _cwdMatchVariants(cwd);
    final placeholders = List.filled(variants.length, '?').join(', ');
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      final rows = db.select(
        '''
        SELECT id, title, updated_at_ms
        FROM threads
        WHERE cwd IN ($placeholders)
        ORDER BY updated_at_ms DESC
        ''',
        variants,
      );
      return [
        for (final row in rows)
          {
            'id': row['id'] ?? '',
            'title': row['title'] ?? '',
            'updatedAtMs': row['updated_at_ms'] ?? 0,
          },
      ];
    } finally {
      db.dispose();
    }
  }

  /// 读 threads 元数据 + 打开 rollout JSONL 文件流式解析每行,
  /// 归一成 CodexThreadDetailDto。详情视图与导出共用。
  Future<CodexThreadDetailDto> loadDetail({required String id}) async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    Map<String, dynamic> meta;
    try {
      final rows = db.select(
        '''
        SELECT id, title, cwd, rollout_path,
               created_at_ms, updated_at_ms,
               model_provider, model, cli_version
        FROM threads
        WHERE id = ?
        ''',
        [id],
      );
      if (rows.isEmpty) {
        throw StateError('thread not found: $id');
      }
      final row = rows.first;
      meta = {
        'id': row['id'] ?? '',
        'title': row['title'] ?? '',
        'cwd': row['cwd'] ?? '',
        'rolloutPath': row['rollout_path'] ?? '',
        'createdAtMs': row['created_at_ms'] ?? 0,
        'updatedAtMs': row['updated_at_ms'] ?? 0,
        'modelProvider': row['model_provider'] ?? '',
        'model': row['model'] ?? '',
        'cliVersion': row['cli_version'] ?? '',
      };
    } finally {
      db.dispose();
    }

    final rolloutPath = meta['rolloutPath'] as String;
    final messages = await _parseRollout(rolloutPath);

    return CodexThreadDetailDto.fromJson({
      ...meta,
      'messages': messages,
    });
  }

  /// Windows 长路径前缀(`\\?\`)双向兼容: 调用方给啥都行。
  List<String> _cwdMatchVariants(String cwd) {
    if (cwd.isEmpty) return const [];
    const prefix = r'\\?\';
    final variants = <String>{cwd};
    if (cwd.startsWith(prefix)) {
      variants.add(cwd.substring(prefix.length));
    } else {
      variants.add('$prefix$cwd');
    }
    return variants.toList();
  }

  Future<List<Map<String, dynamic>>> _parseRollout(String path) async {
    if (path.isEmpty) return [];
    final file = File(path);
    if (!await file.exists()) return [];
    final messages = <Map<String, dynamic>>[];
    var index = 0;
    await for (final line in file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;
      try {
        final obj = jsonDecode(line) as Map<String, dynamic>;
        final type = obj['type'] as String?;
        final timestamp = obj['timestamp'] as String? ?? '';
        final payload = obj['payload'];
        if (payload is! Map<String, dynamic>) continue;

        if (type == 'response_item') {
          final itemType = payload['type'] as String?;
          final role = payload['role'] as String? ?? '';
          if (itemType == 'message') {
            final content = payload['content'];
            if (content is! List) continue;
            final buf = StringBuffer();
            for (final c in content) {
              if (c is! Map) continue;
              final ct = c['type'] as String?;
              if (ct == 'input_text' || ct == 'output_text' || ct == 'text') {
                final t = c['text'];
                if (t is String) buf.write(t);
              }
            }
            final text = buf.toString();
            if (text.isEmpty) continue;
            messages.add({
              'index': index++,
              'timestamp': timestamp,
              'role': role,
              'kind': 'text',
              'text': text,
            });
          } else if (itemType == 'function_call') {
            final name = payload['name'] as String? ?? '';
            final args = payload['arguments'] as String? ?? '';
            messages.add({
              'index': index++,
              'timestamp': timestamp,
              'role': 'tool',
              'kind': 'tool_use',
              'text': '$name($args)',
            });
          } else if (itemType == 'function_call_output') {
            final output = payload['output'] as String? ?? '';
            messages.add({
              'index': index++,
              'timestamp': timestamp,
              'role': 'tool',
              'kind': 'tool_result',
              'text': output,
            });
          }
        }
      } catch (_) {
        // 单行解析失败不影响整体
      }
    }
    return messages;
  }

  /// 按 `model_provider` 分组,做成首页"桶"列表。
  /// null / 空串归一到 `''`(UI 层单独处理成"(未指定)")。
  Future<List<CodexBucketDto>> listBuckets() async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      final rows = db.select(
        '''
        SELECT COALESCE(model_provider, '') AS bucket_key,
               COUNT(*) AS session_count,
               MAX(updated_at_ms) AS last_active_ms
        FROM threads
        WHERE archived = 0
        GROUP BY bucket_key
        ORDER BY last_active_ms DESC
        ''',
      );
      return rows.map((row) {
        return CodexBucketDto.fromJson({
          'bucket': row['bucket_key'] ?? '',
          'sessionCount': row['session_count'] ?? 0,
          'lastActiveMs': row['last_active_ms'] ?? 0,
        });
      }).toList();
    } finally {
      db.dispose();
    }
  }

  /// 单个桶下的会话列表。参数 `bucket` 是 `model_provider` 字段值,
  /// 传空串会命中 model_provider 为 NULL 或 '' 的行(桶名统一到 '')。
  Future<List<CodexThreadDto>> listThreadsByBucket({
    required String bucket,
    int limit = 30,
    int offset = 0,
  }) async {
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      final rows = db.select(
        '''
        SELECT id, title, preview, first_user_message, cwd,
               archived, updated_at_ms, created_at_ms, tokens_used,
               COALESCE(model_provider, '') AS mp
        FROM threads
        WHERE archived = 0 AND COALESCE(model_provider, '') = ?
        ORDER BY updated_at_ms DESC
        LIMIT ? OFFSET ?
        ''',
        [bucket, limit, offset],
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
          'modelProvider': row['mp'] ?? '',
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

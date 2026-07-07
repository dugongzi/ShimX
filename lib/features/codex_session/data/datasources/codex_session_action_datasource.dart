import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shimx/core/utils/codex_session_export_formatter.dart';
import 'package:shimx/features/codex_session/domain/models/codex_import_result.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

/// codex 会话所有写操作的 datasource:删除 + 导出(单条/打 zip)+ 导入(单条/解 zip)。
///
/// IO 全部封在这一层(sqlite / 文件 / FilePicker / zip 编解码),provider 只编排流程。
class CodexSessionActionDatasource {
  CodexSessionActionDatasource({
    required this.formatter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final CodexSessionExportFormatter formatter;
  final Uuid _uuid;

  // ──────────────────────────── delete ────────────────────────────

  /// 删除会话:备份所有相关行到 JSON,再从所有相关表 DELETE。
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

      final backupPath = await _writeDeleteBackup(id, backup);

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

      // SQL 删除成功后再删 rollout 文件,避免 Codex 启动时扫文件重建
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

  // ──────────────────────────── bucket move ────────────────────────────

  /// 把一批 thread 移动到目标桶(model_provider):
  ///   1. sqlite: `UPDATE threads SET model_provider = ? WHERE id IN (...)`(事务)
  ///   2. jsonl: 每条 rollout 找到 `session_meta` 那一行,rewrite payload.model_provider,
  ///      tmp 文件写 → rename 覆盖(原子)。
  /// jsonl 单条失败只 log,不回滚 sqlite —— codex 侧栏用 sqlite,jsonl 里的
  /// meta 字段不影响侧栏显示。返回实际 UPDATE 的行数。
  Future<int> moveThreadsToBucket({
    required List<String> threadIds,
    required String targetBucket,
  }) async {
    if (threadIds.isEmpty) return 0;
    final dbPath = _codexDbPath();
    if (!File(dbPath).existsSync()) {
      throw StateError('Codex database not found: $dbPath');
    }
    final db = sqlite3.open(dbPath);
    final rolloutPaths = <String>[];
    var affected = 0;
    try {
      db.execute('BEGIN');
      try {
        // 拿到每条 thread 当前的 rollout_path,后面 jsonl 改写要用
        final placeholders = List.filled(threadIds.length, '?').join(', ');
        final rows = db.select(
          'SELECT rollout_path FROM threads WHERE id IN ($placeholders)',
          threadIds,
        );
        for (final row in rows) {
          final rp = row['rollout_path'] as String?;
          if (rp != null && rp.isNotEmpty) rolloutPaths.add(rp);
        }

        final stmt = db.prepare(
          'UPDATE threads SET model_provider = ? WHERE id IN ($placeholders)',
        );
        try {
          stmt.execute([targetBucket, ...threadIds]);
        } finally {
          stmt.dispose();
        }
        affected = db.updatedRows;
        db.execute('COMMIT');
      } catch (e) {
        db.execute('ROLLBACK');
        rethrow;
      }
    } finally {
      db.dispose();
    }

    // sqlite 已经提交,jsonl 改写单独跑,失败静默(见方法头注释)
    for (final path in rolloutPaths) {
      try {
        await _rewriteRolloutModelProvider(path, targetBucket);
      } catch (_) {
        // 单文件失败不影响其它
      }
    }
    return affected;
  }

  /// rollout jsonl 里唯一一行 `type == "session_meta"` 里 payload.model_provider
  /// rewrite 为新桶。tmp 写 → rename 覆盖(原子)。
  Future<void> _rewriteRolloutModelProvider(
    String jsonlPath,
    String newProvider,
  ) async {
    final file = File(jsonlPath);
    if (!await file.exists()) return;
    final lines = await file.readAsLines();
    var changed = false;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.contains('"session_meta"') ||
          !line.contains('"model_provider"')) {
        continue;
      }
      try {
        final obj = jsonDecode(line);
        if (obj is! Map) continue;
        if (obj['type'] != 'session_meta') continue;
        final payload = obj['payload'];
        if (payload is! Map) continue;
        if (payload['model_provider'] == newProvider) continue;
        payload['model_provider'] = newProvider;
        lines[i] = jsonEncode(obj);
        changed = true;
      } catch (_) {
        // 单行解析失败略过
      }
    }
    if (!changed) return;

    final tmp = File('$jsonlPath.tmp');
    await tmp.writeAsString('${lines.join('\n')}\n');
    // Windows 上目标文件存在时 rename 会失败,兜底走 delete + rename
    try {
      await tmp.rename(jsonlPath);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await tmp.rename(jsonlPath);
    }
  }

  // ──────────────────────────── export ────────────────────────────

  /// 弹保存对话框 → 写文件。用户取消返回 null。
  /// 已知 outputPath 直接写的版本见 [exportToFile]。
  Future<String?> pickAndExport({
    required CodexThreadDetail detail,
    required String format,
    String? dialogTitle,
  }) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle ?? 'Export Codex conversation',
      fileName: defaultFileName(
        detail.title.isEmpty ? detail.id : detail.title,
        format,
      ),
      type: FileType.custom,
      allowedExtensions: [extOfFormat(format)],
    );
    if (outputPath == null) return null;
    await exportToFile(
      detail: detail,
      format: format,
      outputPath: outputPath,
    );
    return outputPath;
  }

  /// 弹保存对话框 → 多条打 zip 写。用户取消返回 (null, 0, 0)。
  /// 已知 outputPath 直接写的版本见 [exportBundleToZip]。
  Future<({String? path, int ok, int failed})> pickAndExportBundle({
    required Iterable<CodexThreadDetail> details,
    required String format,
    required String defaultBundleFileName,
    String? dialogTitle,
  }) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle ?? 'Export project conversations',
      fileName: defaultBundleFileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (outputPath == null) return (path: null, ok: 0, failed: 0);
    final result = await exportBundleToZip(
      details: details,
      format: format,
      outputPath: outputPath,
    );
    return (path: outputPath, ok: result.ok, failed: result.failed);
  }

  /// 把单条 detail 按 format 写到 outputPath。format ∈ {markdown, raws, html}。
  /// raws = 直接拷贝 rollout JSONL 原文件。
  Future<void> exportToFile({
    required CodexThreadDetail detail,
    required String format,
    required String outputPath,
  }) async {
    switch (format) {
      case 'raws':
        if (detail.rolloutPath.isEmpty) {
          throw StateError('rollout path is empty');
        }
        final src = File(detail.rolloutPath);
        if (!await src.exists()) {
          throw StateError('rollout file not found: ${detail.rolloutPath}');
        }
        await src.copy(outputPath);
        return;
      case 'markdown':
        await File(outputPath).writeAsString(formatter.renderMarkdown(detail));
        return;
      case 'html':
        await File(outputPath).writeAsString(formatter.renderHtml(detail));
        return;
      default:
        throw ArgumentError('unsupported format: $format');
    }
  }

  /// 多条 detail 打 zip 写到 outputPath。
  /// zip 内为空时不写文件并返回 (0, failed)。
  Future<({int ok, int failed})> exportBundleToZip({
    required Iterable<CodexThreadDetail> details,
    required String format,
    required String outputPath,
  }) async {
    if (format != 'markdown' && format != 'raws' && format != 'html') {
      throw ArgumentError('unsupported format: $format');
    }
    final archive = Archive();
    final ext = extOfFormat(format);
    final usedNames = <String>{};
    var ok = 0;
    var failed = 0;
    for (final detail in details) {
      try {
        final bytes = await _renderThreadBytes(detail: detail, format: format);
        final base = safeFileBase(
          detail.title.isEmpty ? detail.id : detail.title,
        );
        final entryName = uniqueName(usedNames, '$base.$ext');
        archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
        ok += 1;
      } catch (_) {
        failed += 1;
      }
    }
    if (archive.isEmpty) return (ok: 0, failed: failed);
    final zipBytes = ZipEncoder().encode(archive);
    await File(outputPath).writeAsBytes(zipBytes, flush: true);
    return (ok: ok, failed: failed);
  }

  Future<List<int>> _renderThreadBytes({
    required CodexThreadDetail detail,
    required String format,
  }) async {
    switch (format) {
      case 'markdown':
        return utf8.encode(formatter.renderMarkdown(detail));
      case 'html':
        return utf8.encode(formatter.renderHtml(detail));
      case 'raws':
        if (detail.rolloutPath.isEmpty) {
          throw StateError('rollout path is empty');
        }
        final src = File(detail.rolloutPath);
        if (!await src.exists()) {
          throw StateError('rollout file not found: ${detail.rolloutPath}');
        }
        return await src.readAsBytes();
      default:
        throw ArgumentError('unsupported format: $format');
    }
  }

  // ──────────────────────────── import ────────────────────────────

  /// 弹文件选择器(单个 .jsonl)→ 解析 + 写。用户取消返回 null。
  /// 失败抛异常,由调用方决定如何提示。
  Future<CodexImportResult?> pickAndImportSingle({String? targetCwd}) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import conversation',
      type: FileType.custom,
      allowedExtensions: ['jsonl'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;
    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('empty file');
    }
    return importRolloutBytes(
      bytes: bytes,
      overrideCwd:
          targetCwd != null && targetCwd.isNotEmpty ? targetCwd : null,
      displayName: fileStem(file.name),
    );
  }

  /// 弹文件选择器(一个 .zip)→ 解压 → 把每个 jsonl 导入。用户取消返回 null。
  /// zip 内无 jsonl 返回 (ok: 0, failed: 0, imported: const [])。
  /// 单条解析失败计入 failed,不抛。
  Future<CodexImportBundleResult?> pickAndImportBundle({
    String? targetCwd,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import project bundle',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;
    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('empty file');
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (err) {
      throw StateError('bad zip: $err');
    }

    final jsonlFiles = archive.files
        .where((f) => f.isFile && f.name.toLowerCase().endsWith('.jsonl'))
        .toList();
    if (jsonlFiles.isEmpty) {
      return CodexImportBundleResult(ok: 0, failed: 0, imported: const []);
    }

    var ok = 0;
    var failed = 0;
    final imported = <Map<String, dynamic>>[];
    for (final entry in jsonlFiles) {
      try {
        final fileBytes = entry.content as List<int>;
        if (fileBytes.isEmpty) {
          failed += 1;
          continue;
        }
        final result = await importRolloutBytes(
          bytes: fileBytes,
          overrideCwd:
              targetCwd != null && targetCwd.isNotEmpty ? targetCwd : null,
          displayName: fileStem(entry.name),
        );
        imported.add({
          'id': result.id,
          'title': result.title,
          'originalEntry': entry.name,
        });
        ok += 1;
      } catch (_) {
        failed += 1;
      }
    }

    return CodexImportBundleResult(ok: ok, failed: failed, imported: imported);
  }

  /// 把一份 rollout JSONL 内容写进 codex。
  ///
  /// [bytes] 来自 zip 解压或单文件导入。
  /// [overrideCwd] 非 null 时,强制把 thread.cwd 设成该值;null 时沿用 rollout 里 session_meta.cwd。
  /// [displayName] 用作 thread.title 的首选值。
  Future<CodexImportResult> importRolloutBytes({
    required List<int> bytes,
    String? overrideCwd,
    String? displayName,
  }) async {
    final content = utf8.decode(bytes, allowMalformed: true);
    final meta = _parseRolloutHead(content);

    final newId = _uuid.v7();
    final originalId = meta.id;
    final rewritten = originalId.isEmpty
        ? content
        : content.replaceAll(originalId, newId);

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final createdAtMs = meta.timestampMs > 0 ? meta.timestampMs : nowMs;
    final updatedAtMs = nowMs;

    final cwd = (overrideCwd != null && overrideCwd.isNotEmpty)
        ? overrideCwd
        : (meta.cwd.isEmpty ? _fallbackCwd() : meta.cwd);

    final resolvedTitle = _resolveTitle(displayName);

    final rolloutPath = await _writeRolloutFile(
      id: newId,
      createdAtMs: createdAtMs,
      content: rewritten,
    );

    _insertThreadRow(
      id: newId,
      rolloutPath: rolloutPath,
      cwd: cwd,
      title: resolvedTitle,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      source: meta.source,
      modelProvider: meta.modelProvider,
      model: meta.model,
      cliVersion: meta.cliVersion,
    );

    return CodexImportResult(
      id: newId,
      rolloutPath: rolloutPath,
      originalId: originalId,
      cwd: cwd,
      title: resolvedTitle,
    );
  }

  String _resolveTitle(String? displayName) {
    final name = (displayName ?? '').trim();
    if (name.isEmpty) return 'Imported thread';
    return name.length > 60 ? name.substring(0, 60) : name;
  }

  /// 只扫 session_meta(基本就是第一行),不再从对话内容抽 title ——
  /// codex 会在 rollout 开头注入 `# AGENTS.md instructions ...` 当 user 消息,会污染 title。
  _RolloutHead _parseRolloutHead(String content) {
    var id = '';
    var cwd = '';
    var cliVersion = '';
    var source = 'shimx';
    var modelProvider = '';
    var model = '';
    var timestampMs = 0;

    final lines = const LineSplitter().convert(content);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      Map<String, dynamic> obj;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is! Map<String, dynamic>) continue;
        obj = decoded;
      } catch (_) {
        continue;
      }
      final type = obj['type'] as String?;
      final payload = obj['payload'];

      if (type == 'session_meta' && payload is Map<String, dynamic>) {
        id = (payload['id'] as String?) ?? id;
        cwd = (payload['cwd'] as String?) ?? cwd;
        cliVersion = (payload['cli_version'] as String?) ?? cliVersion;
        source = (payload['source'] as String?) ?? source;
        modelProvider = (payload['model_provider'] as String?) ?? modelProvider;
        final ts = payload['timestamp'] as String?;
        if (ts != null && ts.isNotEmpty) {
          final dt = DateTime.tryParse(ts);
          if (dt != null) timestampMs = dt.millisecondsSinceEpoch;
        }
        break;
      }
    }

    return _RolloutHead(
      id: id,
      cwd: cwd,
      cliVersion: cliVersion,
      source: source,
      modelProvider: modelProvider,
      model: model,
      timestampMs: timestampMs,
    );
  }

  Future<String> _writeRolloutFile({
    required String id,
    required int createdAtMs,
    required String content,
  }) async {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAtMs);
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final dir = Directory(
      p.join(_codexHome(), 'sessions', year, month, day),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final iso = dt
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first; // YYYY-MM-DDTHH-MM-SS
    final fileName = 'rollout-$iso-$id.jsonl';
    final outPath = p.join(dir.path, fileName);
    await File(outPath).writeAsString(content, flush: true);
    return outPath;
  }

  void _insertThreadRow({
    required String id,
    required String rolloutPath,
    required String cwd,
    required String title,
    required int createdAtMs,
    required int updatedAtMs,
    required String source,
    required String modelProvider,
    required String model,
    required String cliVersion,
  }) {
    final dbPath = _codexDbPath();
    final db = sqlite3.open(dbPath);
    try {
      const sandboxPolicyJson =
          '{"type":"managed","file_system":{"type":"restricted","entries":[]},"network":"restricted"}';
      const approvalMode = 'on-request';

      db.execute(
        '''
        INSERT INTO threads (
          id, rollout_path,
          created_at, updated_at,
          source, model_provider, cwd, title,
          sandbox_policy, approval_mode,
          tokens_used, has_user_event, archived,
          cli_version, first_user_message,
          memory_mode, model,
          created_at_ms, updated_at_ms,
          preview, recency_at, recency_at_ms
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          id,
          rolloutPath,
          createdAtMs ~/ 1000,
          updatedAtMs ~/ 1000,
          source.isEmpty ? 'shimx' : source,
          modelProvider.isEmpty ? 'unknown' : modelProvider,
          cwd,
          title.isEmpty ? 'Imported thread' : title,
          sandboxPolicyJson,
          approvalMode,
          0, // tokens_used
          0, // has_user_event
          0, // archived
          cliVersion.isEmpty ? 'shimx-import' : cliVersion,
          '', // first_user_message
          'enabled', // memory_mode
          model.isEmpty ? null : model,
          createdAtMs,
          updatedAtMs,
          title.isEmpty ? '' : title, // preview
          updatedAtMs ~/ 1000, // recency_at
          updatedAtMs, // recency_at_ms
        ],
      );
    } finally {
      db.dispose();
    }
  }

  // ──────────────────────────── shared helpers ────────────────────────────

  List<Map<String, dynamic>> _dump(
    Database db,
    String sql,
    List<Object?> params,
  ) {
    return db.select(sql, params).map((row) {
      return {for (final k in row.keys) k: row[k]};
    }).toList();
  }

  Future<String> _writeDeleteBackup(
    String id,
    Map<String, dynamic> backup,
  ) async {
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

  String _codexHome() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('Cannot resolve user home directory');
    }
    return p.join(home, '.codex');
  }

  String _codexDbPath() => p.join(_codexHome(), 'state_5.sqlite');

  String _fallbackCwd() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    return home ?? '/';
  }
}

class _RolloutHead {
  _RolloutHead({
    required this.id,
    required this.cwd,
    required this.cliVersion,
    required this.source,
    required this.modelProvider,
    required this.model,
    required this.timestampMs,
  });

  final String id;
  final String cwd;
  final String cliVersion;
  final String source;
  final String modelProvider;
  final String model;
  final int timestampMs;
}

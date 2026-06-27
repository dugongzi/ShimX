import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

/// 把一条 rollout JSONL 导入到 codex (写 sqlite + 拷贝 rollout 文件到 codex sessions 目录)。
///
/// 注意:
///   * 写 codex 自己的 db, 有不兼容风险 — 仅做单条 insert, 不动已有行。
///   * 新 thread 总是分配一个新的 UUID v7 (避免与已有 id 冲突);文件内的 id 字符串也整体替换。
///   * 默认 sandbox_policy/approval_mode 等字段, codex 读到自己的默认值就行。
class CodexSessionImportDatasource {
  CodexSessionImportDatasource({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  /// 把一份 rollout JSONL 内容写进 codex。
  ///
  /// [bytes] 来自 zip 解压或单文件导入。
  /// [overrideCwd] 非 null 时, 强制把 thread.cwd 设成该值(把导入的 thread 归到指定项目);
  ///               null 时沿用 rollout 里 session_meta.cwd。
  /// [displayName] 用作 thread.title 的首选值: 单文件导入传文件名 stem,
  ///               zip 批量导入传 zip 内条目名 stem。这样 codex 侧栏看到的就是用户能控制的名字,
  ///               不会再被 rollout 第一条 "AGENTS.md instructions" 之类的注入消息污染。
  ///
  /// 返回新 thread 的 id 和 rollout 写盘后的路径。
  Future<ImportResult> importRolloutBytes({
    required List<int> bytes,
    String? overrideCwd,
    String? displayName,
  }) async {
    final content = utf8.decode(bytes, allowMalformed: true);
    final meta = _parseRolloutHead(content);

    final newId = _generateThreadId();
    final originalId = meta.id;
    // jsonl 内文里可能在 session_meta / response_item 各处提到原 id, 整体替换。
    final rewritten = originalId.isEmpty
        ? content
        : content.replaceAll(originalId, newId);

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final createdAtMs = meta.timestampMs > 0 ? meta.timestampMs : nowMs;
    final updatedAtMs = nowMs;

    final cwd = (overrideCwd != null && overrideCwd.isNotEmpty)
        ? overrideCwd
        : (meta.cwd.isEmpty ? _fallbackCwd() : meta.cwd);

    // title 优先级: 调用方给的 displayName > 'Imported thread' 兜底
    final resolvedTitle = _resolveTitle(displayName);

    // 写 rollout 文件到 codex sessions 目录, 按 codex 自己的命名规则。
    final rolloutPath = await _writeRolloutFile(
      id: newId,
      createdAtMs: createdAtMs,
      content: rewritten,
    );

    // sqlite insert
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

    return ImportResult(
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

  String _generateThreadId() => _uuid.v7();

  /// 只扫 session_meta (基本就是第一行), 不再尝试从对话内容抽 title ——
  /// 因为 codex 会在 rollout 开头注入 `# AGENTS.md instructions ...` 当 user 消息,
  /// 抽出来污染 title。title 改用调用方提供的 displayName (文件名)。
  _RolloutHead _parseRolloutHead(String content) {
    var id = '';
    var cwd = '';
    var cliVersion = '';
    var source = 'shim';
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
        // session_meta 通常就是第一行, 拿到就够了, 别再扫剩下整个 rollout
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
      // codex schema 大部分 NOT NULL 字段无默认值, 这里给保守的合理默认。
      // sandbox_policy / approval_mode 这俩是 codex 启动时会用的, 但仅"打开看历史"
      // 不需要触发 codex 的运行时校验, 简单 JSON 即可。
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
          source.isEmpty ? 'shim' : source,
          modelProvider.isEmpty ? 'unknown' : modelProvider,
          cwd,
          title.isEmpty ? 'Imported thread' : title,
          sandboxPolicyJson,
          approvalMode,
          0, // tokens_used
          0, // has_user_event - 导入的 thread 我们不知道有没有真实用户消息, 安全起见给 0
          0, // archived
          cliVersion.isEmpty ? 'shim-import' : cliVersion,
          '', // first_user_message - 不再从 rollout 提取, 避免 AGENTS 注入污染
          'enabled', // memory_mode
          model.isEmpty ? null : model,
          createdAtMs,
          updatedAtMs,
          title.isEmpty ? '' : title, // preview 兜底用 title, 不再扫 rollout
          updatedAtMs ~/ 1000, // recency_at
          updatedAtMs, // recency_at_ms
        ],
      );
    } finally {
      db.dispose();
    }
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

class ImportResult {
  ImportResult({
    required this.id,
    required this.rolloutPath,
    required this.originalId,
    required this.cwd,
    required this.title,
  });

  final String id;
  final String rolloutPath;
  final String originalId;
  final String cwd;
  final String title;
}

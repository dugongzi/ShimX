import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/features/claude_session/data/models/claude_project_dto.dart';
import 'package:shim/features/claude_session/data/models/claude_thread_dto.dart';

/// 扫 `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl`,只读。
///
/// 列表性能策略:不读完整 jsonl,只 peek 头部若干行拿到 cwd/gitBranch/标题预览,
/// 时间用文件 stat。大文件不会卡。
class ClaudeSessionQueryDatasource {
  /// 列出 ~/.claude/projects 下所有项目目录。
  /// 目录不存在(用户没装 Claude Code)返回空列表,不抛。
  Future<List<ClaudeProjectDto>> listProjects() async {
    final root = _claudeProjectsDir();
    final dir = Directory(root);
    if (!dir.existsSync()) return const [];

    final result = <ClaudeProjectDto>[];
    for (final entity in dir.listSync(followLinks: false)) {
      if (entity is! Directory) continue;
      final encodedDir = p.basename(entity.path);
      // 扫该项目下所有 jsonl 拿最大 mtime + 计数
      var count = 0;
      var lastActiveMs = 0;
      String? cwdFromFirstFile;
      File? firstJsonl;
      for (final f in entity.listSync(followLinks: false)) {
        if (f is! File) continue;
        if (!f.path.toLowerCase().endsWith('.jsonl')) continue;
        count++;
        final stat = f.statSync();
        final mtimeMs = stat.modified.millisecondsSinceEpoch;
        if (mtimeMs > lastActiveMs) lastActiveMs = mtimeMs;
        firstJsonl ??= f;
      }
      if (count == 0) continue;
      // 任意一个 jsonl 的头部 cwd 都能代表整个项目 — 拿来显示原始路径
      if (firstJsonl != null) {
        cwdFromFirstFile = await _peekCwdFromJsonl(firstJsonl);
      }
      result.add(ClaudeProjectDto.fromJson({
        'encodedDir': encodedDir,
        'cwd': cwdFromFirstFile ?? _decodeCwd(encodedDir),
        'sessionCount': count,
        'lastActiveMs': lastActiveMs,
      }));
    }
    result.sort((a, b) => b.lastActiveMs.compareTo(a.lastActiveMs));
    return result;
  }

  /// 列指定项目下所有 jsonl,按 mtime 倒序。每个 jsonl peek 头部拿元信息。
  Future<List<ClaudeThreadDto>> listThreads({
    required String encodedDir,
    int limit = 200,
  }) async {
    final projectPath = p.join(_claudeProjectsDir(), encodedDir);
    final dir = Directory(projectPath);
    if (!dir.existsSync()) return const [];

    final files = dir
        .listSync(followLinks: false)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jsonl'))
        .toList();

    // 先按 mtime 倒序排,再 take(limit) 后才 peek,避免给老会话也付解析代价
    files.sort((a, b) =>
        b.statSync().modified.compareTo(a.statSync().modified));

    final pick = files.take(limit).toList();
    final result = <ClaudeThreadDto>[];
    for (final f in pick) {
      try {
        result.add(await _peekThreadHeader(f));
      } catch (_) {
        // 单个文件解析失败不影响整体
      }
    }
    return result;
  }

  /// 头部 peek:读前若干行,合并出以下信息
  /// - sessionId  优先取文件名(去 .jsonl);兜底用首行的 sessionId
  /// - cwd / gitBranch  首条带这些字段的记录
  /// - title / preview  首条 type=user 的真实文本(剥命令注入),截断
  Future<ClaudeThreadDto> _peekThreadHeader(File file) async {
    final sessionId = _stripExt(p.basename(file.path));
    final stat = file.statSync();
    String cwd = '';
    String gitBranch = '';
    String title = '';

    final stream = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    var scanned = 0;
    await for (final line in stream) {
      scanned++;
      if (line.trim().isEmpty) continue;
      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(line) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      if (cwd.isEmpty) {
        final v = obj['cwd'];
        if (v is String && v.isNotEmpty) cwd = v;
      }
      if (gitBranch.isEmpty) {
        final v = obj['gitBranch'];
        if (v is String && v.isNotEmpty) gitBranch = v;
      }
      if (title.isEmpty && obj['type'] == 'user') {
        final extracted = _extractUserText(obj);
        if (extracted.isNotEmpty) {
          title = _truncate(extracted, 60);
        }
      }
      // 三项齐了就停,或者扫超过 50 行兜底退出
      if (cwd.isNotEmpty && gitBranch.isNotEmpty && title.isNotEmpty) break;
      if (scanned >= 50) break;
    }

    return ClaudeThreadDto.fromJson({
      'sessionId': sessionId,
      'jsonlPath': file.path,
      'title': title,
      'preview': title,
      'cwd': cwd,
      'gitBranch': gitBranch,
      'updatedAtMs': stat.modified.millisecondsSinceEpoch,
      'createdAtMs': stat.changed.millisecondsSinceEpoch,
      'sizeBytes': stat.size,
    });
  }

  /// 仅读一两行拿 cwd
  Future<String?> _peekCwdFromJsonl(File file) async {
    final stream = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    var scanned = 0;
    await for (final line in stream) {
      scanned++;
      if (line.trim().isEmpty) continue;
      try {
        final obj = jsonDecode(line) as Map<String, dynamic>;
        final v = obj['cwd'];
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
      if (scanned >= 20) break;
    }
    return null;
  }

  /// 抠 user 消息里的真实文本,跳过 `<command-name>` / `<local-command-stdout>` 等注入包裹
  String _extractUserText(Map<String, dynamic> obj) {
    final message = obj['message'];
    if (message is! Map) return '';
    final content = message['content'];
    if (content is String) {
      return _stripCommandWrap(content).trim();
    }
    if (content is! List) return '';
    final buf = StringBuffer();
    for (final c in content) {
      if (c is! Map) continue;
      final ct = c['type'];
      if (ct == 'text') {
        final t = c['text'];
        if (t is String) buf.write(t);
      }
    }
    return _stripCommandWrap(buf.toString()).trim();
  }

  /// 剥掉 `<command-name>...</command-name>`、`<local-command-stdout>...</local-command-stdout>`
  /// 之类的命令注入包裹,只留真实用户文本
  String _stripCommandWrap(String s) {
    var out = s;
    // 移除整个 <command-*>...</command-*> 块
    final tagBlock = RegExp(
      r'<(command-[a-z-]+|local-command-[a-z-]+)[^>]*>[\s\S]*?</\1>',
      multiLine: true,
    );
    out = out.replaceAll(tagBlock, '');
    return out.trim();
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…';
  }

  String _stripExt(String name) {
    final i = name.lastIndexOf('.');
    if (i <= 0) return name;
    return name.substring(0, i);
  }

  /// 兜底:从 `f--Programming-projects-FlutterProject-shim` 还原盘符路径
  /// 不是所有平台都靠 `-` 还原都能拿对(unix 下分隔符也是 -),所以只在 jsonl 里
  /// 没拿到 cwd 时用。Windows 规则:首字母 + 第一个 `-` 还原成 `:`,后续 `-` 还原为 `\`
  String _decodeCwd(String encoded) {
    if (Platform.isWindows && encoded.length >= 2 && encoded[1] == '-') {
      final rest = encoded.substring(2).replaceAll('-', '\\');
      return '${encoded[0]}:\\$rest';
    }
    // unix: 全部 `-` → `/`,首字符前补 `/`
    return '/${encoded.replaceAll('-', '/')}';
  }

  String _claudeProjectsDir() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('Cannot resolve user home directory');
    }
    return p.join(home, '.claude', 'projects');
  }
}

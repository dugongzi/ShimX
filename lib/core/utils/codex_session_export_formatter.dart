import 'package:path/path.dart' as p;
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_message.dart';

class CodexSessionExportFormatter {
  /// Markdown:头部 meta + 按 role 分块
  String renderMarkdown(CodexThreadDetail detail) {
    final buf = StringBuffer();
    final title = detail.title.isEmpty ? detail.id : detail.title;
    buf.writeln('# $title');
    buf.writeln();
    buf.writeln('- id: `${detail.id}`');
    buf.writeln('- cwd: `${detail.cwd}`');
    buf.writeln('- model: `${detail.model}`');
    buf.writeln('- model_provider: `${detail.modelProvider}`');
    buf.writeln('- cli_version: `${detail.cliVersion}`');
    buf.writeln('- created: ${_fmtTime(detail.createdAtMs)}');
    buf.writeln('- updated: ${_fmtTime(detail.updatedAtMs)}');
    buf.writeln('- rollout: `${detail.rolloutPath}`');
    buf.writeln();
    buf.writeln('---');
    buf.writeln();

    for (final m in detail.messages) {
      buf.write(_renderMessage(m));
    }
    return buf.toString();
  }

  String _renderMessage(CodexThreadMessage m) {
    final buf = StringBuffer();
    final heading = _roleHeading(m.role, m.kind);
    buf.writeln('## $heading');
    if (m.timestamp.isNotEmpty) {
      buf.writeln('_${m.timestamp}_');
    }
    buf.writeln();
    if (m.kind == 'tool_use') {
      buf.writeln('```');
      buf.writeln(m.text);
      buf.writeln('```');
    } else if (m.kind == 'tool_result') {
      buf.writeln('<details><summary>tool result</summary>');
      buf.writeln();
      buf.writeln('```');
      buf.writeln(m.text);
      buf.writeln('```');
      buf.writeln();
      buf.writeln('</details>');
    } else {
      buf.writeln(m.text);
    }
    buf.writeln();
    return buf.toString();
  }

  String _roleHeading(String role, String kind) {
    if (kind == 'tool_use') return 'Tool call';
    if (kind == 'tool_result') return 'Tool result';
    switch (role) {
      case 'user':
        return 'User';
      case 'assistant':
        return 'Assistant';
      case 'system':
        return 'System';
      case 'developer':
        return 'Developer';
      default:
        return role.isEmpty ? 'Message' : role;
    }
  }

  String _fmtTime(int ms) {
    if (ms == 0) return '';
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .toIso8601String();
  }

  /// HTML:暗色单页, 内嵌 CSS, tool result 用 `<details>` 折叠。
  /// 内容生成: 头部 meta + 按顺序渲染每条消息。
  String renderHtml(CodexThreadDetail detail) {
    final title = detail.title.isEmpty ? detail.id : detail.title;
    final buf = StringBuffer();
    buf.writeln('<!DOCTYPE html>');
    buf.writeln('<html lang="en"><head><meta charset="utf-8">');
    buf.writeln('<title>${_htmlEscape(title)}</title>');
    buf.writeln('<style>$_htmlStyles</style>');
    buf.writeln('</head><body>');
    buf.writeln('<header class="meta">');
    buf.writeln('<h1>${_htmlEscape(title)}</h1>');
    buf.writeln('<dl>');
    _metaItem(buf, 'id', detail.id);
    _metaItem(buf, 'cwd', detail.cwd);
    _metaItem(buf, 'model', detail.model);
    _metaItem(buf, 'model_provider', detail.modelProvider);
    _metaItem(buf, 'cli_version', detail.cliVersion);
    _metaItem(buf, 'created', _fmtTime(detail.createdAtMs));
    _metaItem(buf, 'updated', _fmtTime(detail.updatedAtMs));
    _metaItem(buf, 'rollout', detail.rolloutPath);
    buf.writeln('</dl>');
    buf.writeln('</header>');
    buf.writeln('<main>');
    for (final m in detail.messages) {
      buf.write(_renderHtmlMessage(m));
    }
    buf.writeln('</main>');
    buf.writeln('</body></html>');
    return buf.toString();
  }

  void _metaItem(StringBuffer buf, String k, String v) {
    buf.writeln(
      '<div><dt>${_htmlEscape(k)}</dt>'
      '<dd>${_htmlEscape(v)}</dd></div>',
    );
  }

  String _renderHtmlMessage(CodexThreadMessage m) {
    final heading = _roleHeading(m.role, m.kind);
    final roleClass = m.kind == 'tool_use' || m.kind == 'tool_result'
        ? 'tool'
        : (m.role.isEmpty ? 'other' : m.role);
    final buf = StringBuffer();
    buf.write('<section class="msg msg-$roleClass">');
    buf.write('<header class="msg-head">');
    buf.write('<span class="role">${_htmlEscape(heading)}</span>');
    if (m.timestamp.isNotEmpty) {
      buf.write('<time>${_htmlEscape(m.timestamp)}</time>');
    }
    buf.write('</header>');
    if (m.kind == 'tool_use') {
      buf.write('<pre class="code">${_htmlEscape(m.text)}</pre>');
    } else if (m.kind == 'tool_result') {
      buf.write(
        '<details><summary>tool result</summary>'
        '<pre class="code">${_htmlEscape(m.text)}</pre>'
        '</details>',
      );
    } else {
      buf.write('<div class="body">${_htmlEscape(m.text)}</div>');
    }
    buf.write('</section>');
    return buf.toString();
  }

  String _htmlEscape(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  static const String _htmlStyles = '''
:root {
  color-scheme: dark;
  --bg: #18181a;
  --bg-elev: #1f1f22;
  --border: rgba(255,255,255,0.08);
  --fg: #e6e6e6;
  --fg-muted: rgba(230,230,230,0.62);
  --accent: #60a5fa;
  --tool: #facc15;
  --user: #93c5fd;
  --assistant: #c4b5fd;
  --code-bg: #111113;
}
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; background: var(--bg); color: var(--fg);
  font: 14px/1.55 ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
main, header.meta { max-width: 880px; margin: 0 auto; padding: 24px; }
header.meta h1 { margin: 0 0 12px; font-size: 22px; font-weight: 600; }
header.meta dl { margin: 0; display: grid; grid-template-columns: auto 1fr; gap: 4px 12px; font-size: 12.5px; color: var(--fg-muted); }
header.meta dl > div { display: contents; }
header.meta dt { color: var(--fg-muted); font-weight: 500; }
header.meta dd { margin: 0; color: var(--fg); font-family: ui-monospace, SFMono-Regular, Menlo, monospace; word-break: break-all; }
section.msg { margin: 14px 0; padding: 14px 16px; background: var(--bg-elev); border: 1px solid var(--border); border-radius: 10px; }
section.msg-head, header.msg-head { display: flex; align-items: baseline; justify-content: space-between; gap: 12px; margin-bottom: 8px; }
.msg-head .role { font-weight: 700; font-size: 12px; letter-spacing: 0.4px; text-transform: uppercase; color: var(--fg-muted); }
.msg-user .role { color: var(--user); }
.msg-assistant .role { color: var(--assistant); }
.msg-tool .role { color: var(--tool); }
.msg-head time { font-size: 11px; color: var(--fg-muted); font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
.body { white-space: pre-wrap; word-break: break-word; }
.code, pre.code { margin: 0; padding: 10px 12px; background: var(--code-bg); border-radius: 6px; font: 12.5px/1.5 ui-monospace, SFMono-Regular, Menlo, monospace; color: var(--fg); white-space: pre-wrap; word-break: break-word; overflow-x: auto; }
details { background: var(--code-bg); border-radius: 6px; padding: 4px 0; }
details summary { padding: 6px 12px; cursor: pointer; color: var(--fg-muted); font-size: 12px; }
details[open] summary { color: var(--fg); }
details pre.code { margin: 0; border-radius: 0 0 6px 6px; }
''';
}

/// 文件名安全化:替换非法字符,截断到 80 字符。
String safeFileBase(String name) {
  final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
  if (cleaned.isEmpty) return 'untitled';
  return cleaned.length > 80 ? cleaned.substring(0, 80) : cleaned;
}

/// zip 内同名时附加 `-2/-3/...` 后缀去重。
String uniqueName(Set<String> used, String name) {
  if (used.add(name)) return name;
  final dot = name.lastIndexOf('.');
  final stem = dot >= 0 ? name.substring(0, dot) : name;
  final ext = dot >= 0 ? name.substring(dot) : '';
  var i = 2;
  while (true) {
    final candidate = '$stem-$i$ext';
    if (used.add(candidate)) return candidate;
    i += 1;
  }
}

/// 按项目导出时的默认 zip 文件名:`<cwd 末段>-<format>.zip`。
String defaultBundleName(String cwd, String format) {
  final base = safeFileBase(p.basename(cwd));
  return '$base-${format == 'raws' ? 'raw' : format}.zip';
}

/// 单条导出时的默认文件名:`<title>.<ext>`。
String defaultFileName(String title, String format) {
  final safe = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return '$safe.${extOfFormat(format)}';
}

/// format → 文件扩展名。
String extOfFormat(String format) {
  switch (format) {
    case 'markdown':
      return 'md';
    case 'raws':
      return 'jsonl';
    case 'html':
      return 'html';
    default:
      return 'txt';
  }
}

/// 取一个路径或文件名的 "stem"(去掉目录 + 去掉最后一个扩展名),作为 thread title。
/// 例如:
///   "rollout-2026-03-05T14-27-01-019cbcad.jsonl" → "rollout-2026-03-05T14-27-01-019cbcad"
///   "exports/2026-03-05/hi.jsonl"               → "hi"
///   "hi"                                         → "hi"
String fileStem(String name) {
  if (name.isEmpty) return '';
  final lastSep = name.lastIndexOf(RegExp(r'[/\\]'));
  final base = lastSep >= 0 ? name.substring(lastSep + 1) : name;
  final dot = base.lastIndexOf('.');
  if (dot <= 0) return base;
  return base.substring(0, dot);
}

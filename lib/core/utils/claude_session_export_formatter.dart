import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_message.dart';

class ClaudeSessionExportFormatter {
  /// Markdown:头部 meta + 按 role 分块
  String renderMarkdown(ClaudeThreadDetail detail) {
    final buf = StringBuffer();
    final title = detail.title.isEmpty ? detail.sessionId : detail.title;
    buf.writeln('# $title');
    buf.writeln();
    buf.writeln('- session: `${detail.sessionId}`');
    buf.writeln('- cwd: `${detail.cwd}`');
    if (detail.gitBranch.isNotEmpty) {
      buf.writeln('- gitBranch: `${detail.gitBranch}`');
    }
    if (detail.cliVersion.isNotEmpty) {
      buf.writeln('- cliVersion: `${detail.cliVersion}`');
    }
    buf.writeln('- created: ${_fmtTime(detail.createdAtMs)}');
    buf.writeln('- updated: ${_fmtTime(detail.updatedAtMs)}');
    buf.writeln('- file: `${detail.jsonlPath}`');
    buf.writeln();
    buf.writeln('---');
    buf.writeln();

    for (final m in detail.messages) {
      buf.write(_renderMessage(m));
    }
    return buf.toString();
  }

  String _renderMessage(ClaudeThreadMessage m) {
    final buf = StringBuffer();
    buf.writeln('## ${_heading(m)}');
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

  String _heading(ClaudeThreadMessage m) {
    if (m.kind == 'tool_use') {
      return m.toolName.isEmpty ? 'Tool call' : 'Tool call: ${m.toolName}';
    }
    if (m.kind == 'tool_result') return 'Tool result';
    switch (m.role) {
      case 'user':
        return 'User';
      case 'assistant':
        return 'Assistant';
      default:
        return m.role.isEmpty ? 'Message' : m.role;
    }
  }

  String _fmtTime(int ms) {
    if (ms == 0) return '';
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .toIso8601String();
  }
}

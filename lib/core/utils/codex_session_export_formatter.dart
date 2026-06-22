import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread_message.dart';

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
}

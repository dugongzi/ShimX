import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/features/claude_session/data/models/claude_thread_detail_dto.dart';

/// 流式逐行解析 jsonl,归一成 ClaudeThreadDetailDto。
///
/// 单行结构(Claude Code 实测):
/// {
///   "type": "user" | "assistant" | "queue-operation" | ...,
///   "message": { "role": ..., "content": string OR list of content_block },
///   "uuid", "parentUuid", "sessionId", "timestamp",
///   "cwd", "gitBranch", "version", ...
/// }
/// content_block: {type: "text"|"tool_use"|"tool_result", text/name/input/content...}
class ClaudeSessionExportDatasource {
  Future<ClaudeThreadDetailDto> loadDetail({required String jsonlPath}) async {
    final file = File(jsonlPath);
    if (!await file.exists()) {
      throw StateError('jsonl not found: $jsonlPath');
    }
    final stat = file.statSync();
    final sessionId = _stripExt(p.basename(jsonlPath));

    String cwd = '';
    String gitBranch = '';
    String cliVersion = '';
    String title = '';
    final messages = <Map<String, dynamic>>[];
    var index = 0;

    await for (final line in file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;
      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(line) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      // 头部元信息(任何一行命中就抓)
      if (cwd.isEmpty) {
        final v = obj['cwd'];
        if (v is String && v.isNotEmpty) cwd = v;
      }
      if (gitBranch.isEmpty) {
        final v = obj['gitBranch'];
        if (v is String && v.isNotEmpty) gitBranch = v;
      }
      if (cliVersion.isEmpty) {
        final v = obj['version'];
        if (v is String && v.isNotEmpty) cliVersion = v;
      }

      final type = obj['type'] as String?;
      final timestamp = obj['timestamp'] as String? ?? '';

      if (type == 'user' || type == 'assistant') {
        final parsed = _parseMessage(obj, type!, timestamp, () => index);
        for (final m in parsed) {
          messages.add(m);
          index++;
        }
        if (title.isEmpty && type == 'user') {
          final firstText = parsed
              .where((m) => m['kind'] == 'text')
              .map((m) => m['text'] as String? ?? '')
              .firstWhere((t) => t.isNotEmpty, orElse: () => '');
          if (firstText.isNotEmpty) {
            title = _truncate(firstText, 60);
          }
        }
      }
      // queue-operation / summary / 其它类型忽略
    }

    return ClaudeThreadDetailDto.fromJson({
      'sessionId': sessionId,
      'title': title,
      'cwd': cwd,
      'gitBranch': gitBranch,
      'cliVersion': cliVersion,
      'jsonlPath': jsonlPath,
      'createdAtMs': stat.changed.millisecondsSinceEpoch,
      'updatedAtMs': stat.modified.millisecondsSinceEpoch,
      'messages': messages,
    });
  }

  /// 把一行(user/assistant)拆成 1~N 条 normalized message
  List<Map<String, dynamic>> _parseMessage(
    Map<String, dynamic> obj,
    String type,
    String timestamp,
    int Function() nextIndex,
  ) {
    final result = <Map<String, dynamic>>[];
    final role = type == 'user' ? 'user' : 'assistant';
    final message = obj['message'];
    if (message is! Map) return result;
    final content = message['content'];

    if (content is String) {
      // 直接字符串内容
      final text = _stripCommandWrap(content).trim();
      if (text.isNotEmpty) {
        result.add({
          'index': nextIndex(),
          'timestamp': timestamp,
          'role': role,
          'kind': 'text',
          'text': text,
        });
      }
      return result;
    }
    if (content is! List) return result;

    final textBuf = StringBuffer();
    for (final c in content) {
      if (c is! Map) continue;
      final ct = c['type'] as String?;
      switch (ct) {
        case 'text':
          final t = c['text'];
          if (t is String) textBuf.write(t);
          break;
        case 'tool_use':
          // 先把累积的文本输出一条
          _flushText(textBuf, result, role, timestamp);
          final name = (c['name'] as String?) ?? '';
          final input = c['input'];
          final inputStr = input == null
              ? ''
              : (input is String ? input : jsonEncode(input));
          result.add({
            'index': 0, // 占位,稍后由 nextIndex 重排
            'timestamp': timestamp,
            'role': role,
            'kind': 'tool_use',
            'text': inputStr,
            'toolName': name,
          });
          break;
        case 'tool_result':
          _flushText(textBuf, result, role, timestamp);
          final inner = c['content'];
          String resultText = '';
          if (inner is String) {
            resultText = inner;
          } else if (inner is List) {
            final sb = StringBuffer();
            for (final ic in inner) {
              if (ic is Map && ic['type'] == 'text' && ic['text'] is String) {
                sb.writeln(ic['text']);
              }
            }
            resultText = sb.toString().trimRight();
          }
          result.add({
            'index': 0,
            'timestamp': timestamp,
            'role': 'tool',
            'kind': 'tool_result',
            'text': resultText,
          });
          break;
        default:
          // image / thinking / 其它块暂时忽略
          break;
      }
    }
    _flushText(textBuf, result, role, timestamp);

    // 重排 index
    final indexed = result.map((m) {
      return {...m, 'index': nextIndex()};
    }).toList();
    return indexed;
  }

  void _flushText(
    StringBuffer buf,
    List<Map<String, dynamic>> out,
    String role,
    String timestamp,
  ) {
    if (buf.isEmpty) return;
    final text = _stripCommandWrap(buf.toString()).trim();
    buf.clear();
    if (text.isEmpty) return;
    out.add({
      'index': 0,
      'timestamp': timestamp,
      'role': role,
      'kind': 'text',
      'text': text,
    });
  }

  String _stripCommandWrap(String s) {
    final tagBlock = RegExp(
      r'<(command-[a-z-]+|local-command-[a-z-]+)[^>]*>[\s\S]*?</\1>',
      multiLine: true,
    );
    return s.replaceAll(tagBlock, '').trim();
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
}

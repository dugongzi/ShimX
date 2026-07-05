// 独立探针: 直接打 shim 本地代理的 /responses,不同 body 组合都试一遍,把
// 上游返回原样 dump 出来。用来验证润色请求哪个字段缺了导致上游只回 reasoning。
//
// 运行: dart run tool/polish_probe.dart
// 前置: shim app 已经跑起来, provider picker 选中的桶就是要测的那个。

import 'dart:convert';
import 'dart:io';

const proxyUrl = 'http://127.0.0.1:8787/v1/responses';

Future<void> main() async {
  final variants = <String, Map<String, Object?>>{
    'min': {
      'model': 'shim-polish',
      'input': [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '把这段改得更简洁: 你好世界这是一段测试文本'},
          ],
        },
      ],
      'stream': false,
    },
    'with_instructions': {
      'model': 'shim-polish',
      'instructions': '你是文本改写助手,只输出改写结果,不解释。',
      'input': [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '把这段改得更简洁: 你好世界这是一段测试文本'},
          ],
        },
      ],
      'stream': false,
    },
    'stream_true': {
      'model': 'shim-polish',
      'instructions': '你是文本改写助手,只输出改写结果,不解释。',
      'input': [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '把这段改得更简洁: 你好世界这是一段测试文本'},
          ],
        },
      ],
      'stream': true,
    },
    'no_reasoning_effort_low': {
      'model': 'shim-polish',
      'instructions': '你是文本改写助手,只输出改写结果,不解释。',
      'reasoning': {'effort': 'low'},
      'input': [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '把这段改得更简洁: 你好世界这是一段测试文本'},
          ],
        },
      ],
      'stream': false,
    },
    'no_reasoning_effort_minimal': {
      'model': 'shim-polish',
      'instructions': '你是文本改写助手,只输出改写结果,不解释。',
      'reasoning': {'effort': 'minimal'},
      'input': [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '把这段改得更简洁: 你好世界这是一段测试文本'},
          ],
        },
      ],
      'stream': false,
    },
    'max_output_tokens_big': {
      'model': 'shim-polish',
      'instructions': '你是文本改写助手,只输出改写结果,不解释。',
      'max_output_tokens': 4096,
      'input': [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '把这段改得更简洁: 你好世界这是一段测试文本'},
          ],
        },
      ],
      'stream': false,
    },
  };

  for (final entry in variants.entries) {
    stdout.writeln('\n===== VARIANT: ${entry.key} =====');
    await _probe(entry.value);
  }
}

Future<void> _probe(Map<String, Object?> body) async {
  final client = HttpClient()
    ..autoUncompress = false
    ..findProxy = (_) => 'DIRECT';
  try {
    final req = await client.postUrl(Uri.parse(proxyUrl));
    final bytes = utf8.encode(jsonEncode(body));
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    req.headers.contentLength = bytes.length;
    req.add(bytes);
    final resp = await req.close().timeout(const Duration(minutes: 3));
    stdout.writeln('status: ${resp.statusCode}');
    stdout.writeln('headers:');
    resp.headers.forEach((k, v) => stdout.writeln('  $k: ${v.join(',')}'));
    final raw = await utf8.decodeStream(resp);
    stdout.writeln('body (${raw.length} chars):');
    stdout.writeln(raw.length > 8000 ? '${raw.substring(0, 8000)}\n...(truncated)' : raw);
  } catch (e, st) {
    stdout.writeln('ERROR: $e');
    stdout.writeln(st);
  } finally {
    client.close(force: true);
  }
}

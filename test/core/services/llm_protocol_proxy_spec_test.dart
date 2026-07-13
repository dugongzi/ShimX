import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shimx/core/services/llm_protocol_converter.dart';
import 'package:shimx/core/services/llm_protocol_proxy_spec.dart';

Map<String, Object?> _convertBody(
  Map<String, Object?> src, {
  required LlmProtocol from,
  required LlmProtocol to,
  LlmRequestConvertOptions options = const LlmRequestConvertOptions(),
}) {
  final bytes = utf8.encode(jsonEncode(src));
  final out = convertLlmProtocolBody(bytes, from: from, to: to, options: options);
  return jsonDecode(utf8.decode(out)) as Map<String, Object?>;
}

void main() {
  group('resolveLlmProtocolSpec', () {
    test('responses keeps request path and passthrough stream', () {
      final spec = resolveLlmProtocolSpec(
        baseUrl: 'https://api.example.com/v1',
        requestUri: Uri.parse('/v1/responses?foo=bar'),
        apiKey: 'sk-test',
        upstreamProtocol: 'responses',
      );

      expect(spec.protocol, LlmProtocol.responses);
      expect(spec.uri.toString(), 'https://api.example.com/v1/responses?foo=bar');
      expect(spec.headers, {'authorization': 'Bearer sk-test'});
      expect(spec.responseStreamKind, LlmResponseStreamKind.passthrough);
    });

    test('chat uses chat completions route and chat stream transformer', () {
      final spec = resolveLlmProtocolSpec(
        baseUrl: 'https://api.example.com/v1/',
        requestUri: Uri.parse('/v1/responses'),
        apiKey: 'sk-test',
        upstreamProtocol: 'chat',
      );

      expect(spec.protocol, LlmProtocol.chat);
      expect(spec.uri.toString(), 'https://api.example.com/v1/chat/completions');
      expect(spec.headers, {'authorization': 'Bearer sk-test'});
      expect(spec.responseStreamKind, LlmResponseStreamKind.chatToResponses);
    });

    test('messages uses messages route anthropic headers and messages stream transformer', () {
      final spec = resolveLlmProtocolSpec(
        baseUrl: 'https://api.example.com/v1/',
        requestUri: Uri.parse('/v1/responses'),
        apiKey: 'sk-test',
        upstreamProtocol: 'messages',
      );

      expect(spec.protocol, LlmProtocol.messages);
      expect(spec.uri.toString(), 'https://api.example.com/v1/messages');
      expect(spec.headers, {
        'authorization': 'Bearer sk-test',
        'x-api-key': 'sk-test',
        'anthropic-version': '2023-06-01',
      });
      expect(spec.responseStreamKind, LlmResponseStreamKind.messagesToResponses);
    });
  });

  group('convertLlmProtocolBody responses->messages', () {
    test('preserves text/tool_use/text order round-trip via responses<->messages', () {
      // 模拟一条 Anthropic 里 assistant 说 "先说明" 再 tool_use 再 "补充"。
      // 走 messages->responses->messages 一圈,顺序不能被改。
      final anthropic = <String, Object?>{
        'model': 'claude-3-5-sonnet',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': 'hi'},
          {
            'role': 'assistant',
            'content': [
              {'type': 'text', 'text': '先说明'},
              {
                'type': 'tool_use',
                'id': 'toolu_1',
                'name': 'get_weather',
                'input': {'city': 'SF'},
              },
              {'type': 'text', 'text': '补充'},
            ],
          },
        ],
      };
      final asResponses = _convertBody(
        anthropic,
        from: LlmProtocol.messages,
        to: LlmProtocol.responses,
      );
      final input = asResponses['input'] as List;
      // 期望顺序:user | assistant "先说明" | function_call | assistant "补充"
      expect(input.length, 4);
      expect((input[0] as Map)['role'], 'user');
      expect((input[1] as Map)['role'], 'assistant');
      expect(
        ((input[1] as Map)['content'] as List).first as Map,
        containsPair('text', '先说明'),
      );
      expect((input[2] as Map)['type'], 'function_call');
      expect((input[2] as Map)['name'], 'get_weather');
      expect((input[3] as Map)['role'], 'assistant');
      expect(
        ((input[3] as Map)['content'] as List).first as Map,
        containsPair('text', '补充'),
      );
    });

    test('parallel_tool_calls=false maps to disable_parallel_tool_use', () {
      final responses = <String, Object?>{
        'model': 'gpt-x',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'hi'},
            ],
          },
        ],
        'tools': [
          {
            'type': 'function',
            'name': 'get_weather',
            'parameters': {'type': 'object', 'properties': <String, Object?>{}},
          },
        ],
        'parallel_tool_calls': false,
      };
      final msgs = _convertBody(
        responses,
        from: LlmProtocol.responses,
        to: LlmProtocol.messages,
      );
      expect(msgs['tool_choice'], {
        'type': 'auto',
        'disable_parallel_tool_use': true,
      });
    });

    test('parallel_tool_calls preserved on chat conversion', () {
      final responses = <String, Object?>{
        'model': 'gpt-x',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'hi'},
            ],
          },
        ],
        'parallel_tool_calls': false,
      };
      final chat = _convertBody(
        responses,
        from: LlmProtocol.responses,
        to: LlmProtocol.chat,
      );
      expect(chat['parallel_tool_calls'], false);
    });

    test('responses tools convert to anthropic tools (flat input_schema)', () {
      final responses = <String, Object?>{
        'model': 'x',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'q'},
            ],
          },
        ],
        'tools': [
          {
            'type': 'function',
            'name': 'lookup',
            'description': 'do lookup',
            'parameters': {
              'type': 'object',
              'properties': {
                'q': {'type': 'string'},
              },
              'required': ['q'],
            },
          },
        ],
      };
      final msgs = _convertBody(
        responses,
        from: LlmProtocol.responses,
        to: LlmProtocol.messages,
      );
      final tools = msgs['tools'] as List;
      expect(tools.length, 1);
      final t = tools.first as Map;
      expect(t['name'], 'lookup');
      expect(t['input_schema'], isA<Map>());
      expect((t['input_schema'] as Map)['type'], 'object');
    });
  });
}

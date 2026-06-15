import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shim/core/services/llm_protocol_converter.dart';

Map<String, Object?> decodeBody(List<int> body) {
  final Object? decoded = jsonDecode(utf8.decode(body));
  expect(decoded, isA<Map>());
  return (decoded as Map).map((key, value) => MapEntry(key.toString(), value));
}

void main() {
  group('convertLlmProtocolBody', () {
    test('responses to responses applies model and reasoning options', () {
      final body = utf8.encode(jsonEncode({
        'model': 'codex-default',
        'input': 'hello',
      }));

      final out = decodeBody(
        convertLlmProtocolBody(
          body,
          from: LlmProtocol.responses,
          to: LlmProtocol.responses,
          options: const LlmRequestConvertOptions(
            overrideModel: 'gpt-5.5',
            reasoningEffort: 'high',
          ),
        ),
      );

      expect(out['model'], 'gpt-5.5');
      expect(out['reasoning'], {'effort': 'high'});
    });

    test('responses to chat maps instructions input tools tokens and reasoning', () {
      final body = utf8.encode(jsonEncode({
        'model': 'codex-default',
        'instructions': 'be precise',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'hello'},
            ],
          },
        ],
        'tools': [
          {
            'type': 'function',
            'name': 'lookup',
            'description': 'Lookup value',
            'parameters': {
              'type': 'object',
              'properties': {'q': {'type': 'string'}},
            },
          },
        ],
        'max_output_tokens': 123,
      }));

      final out = decodeBody(
        convertLlmProtocolBody(
          body,
          from: LlmProtocol.responses,
          to: LlmProtocol.chat,
          options: const LlmRequestConvertOptions(
            overrideModel: 'gpt-5.5',
            reasoningEffort: 'xhigh',
          ),
        ),
      );

      expect(out['model'], 'gpt-5.5');
      expect(out['messages'], [
        {'role': 'system', 'content': 'be precise'},
        {'role': 'user', 'content': 'hello'},
      ]);
      expect(out['max_tokens'], 123);
      expect(out['reasoning_effort'], 'xhigh');
      final tools = out['tools'] as List;
      expect((tools.first as Map)['function']['name'], 'lookup');
      expect((tools.first as Map)['function']['parameters'], isA<Map>());
    });

    test('responses to anthropic messages maps system input and tools without reasoning', () {
      final body = utf8.encode(jsonEncode({
        'model': 'codex-default',
        'instructions': 'be precise',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'hello'},
            ],
          },
        ],
        'tools': [
          {
            'type': 'function',
            'name': 'lookup',
            'parameters': {
              'type': 'object',
              'properties': {'q': {'type': 'string'}},
            },
          },
        ],
        'max_output_tokens': 321,
      }));

      final out = decodeBody(
        convertLlmProtocolBody(
          body,
          from: LlmProtocol.responses,
          to: LlmProtocol.messages,
          options: const LlmRequestConvertOptions(
            overrideModel: 'claude-sonnet',
            reasoningEffort: 'high',
          ),
        ),
      );

      expect(out['model'], 'claude-sonnet');
      expect(out['system'], 'be precise');
      expect(out['messages'], [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'hello'},
          ],
        },
      ]);
      final tools = out['tools'] as List;
      expect((tools.first as Map)['input_schema'], isA<Map>());
      expect(out.containsKey('reasoning_effort'), isFalse);
      expect(out.containsKey('reasoning'), isFalse);
    });

    test('chat to responses maps system tool calls and tool outputs', () {
      final body = utf8.encode(jsonEncode({
        'model': 'chat-model',
        'messages': [
          {'role': 'system', 'content': 'be precise'},
          {'role': 'user', 'content': 'hello'},
          {
            'role': 'assistant',
            'content': null,
            'tool_calls': [
              {
                'id': 'call_1',
                'type': 'function',
                'function': {'name': 'lookup', 'arguments': '{"q":"x"}'},
              },
            ],
          },
          {'role': 'tool', 'tool_call_id': 'call_1', 'content': 'ok'},
        ],
        'max_tokens': 42,
      }));

      final out = decodeBody(
        convertLlmProtocolBody(
          body,
          from: LlmProtocol.chat,
          to: LlmProtocol.responses,
        ),
      );

      expect(out['instructions'], 'be precise');
      final input = out['input'] as List;
      expect((input[1] as Map)['type'], 'function_call');
      expect((input[1] as Map)['name'], 'lookup');
      expect((input[2] as Map)['type'], 'function_call_output');
      expect((input[2] as Map)['output'], 'ok');
      expect(out['max_output_tokens'], 42);
    });

    test('anthropic messages to responses maps text tool_use and tool_result', () {
      final body = utf8.encode(jsonEncode({
        'model': 'claude',
        'system': 'be precise',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'hello'},
            ],
          },
          {
            'role': 'assistant',
            'content': [
              {
                'type': 'tool_use',
                'id': 'toolu_1',
                'name': 'lookup',
                'input': {'q': 'x'},
              },
            ],
          },
          {
            'role': 'user',
            'content': [
              {'type': 'tool_result', 'tool_use_id': 'toolu_1', 'content': 'ok'},
            ],
          },
        ],
      }));

      final out = decodeBody(
        convertLlmProtocolBody(
          body,
          from: LlmProtocol.messages,
          to: LlmProtocol.responses,
        ),
      );

      expect(out['instructions'], 'be precise');
      final input = out['input'] as List;
      expect((input[0] as Map)['content'], isA<List>());
      expect((input[1] as Map)['type'], 'function_call');
      expect((input[1] as Map)['call_id'], 'toolu_1');
      expect((input[2] as Map)['type'], 'function_call_output');
      expect((input[2] as Map)['output'], 'ok');
    });
  });
}

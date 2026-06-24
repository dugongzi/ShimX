import 'dart:convert';

enum LlmProtocol {
  responses,
  chat,
  messages,
}

LlmProtocol parseLlmProtocol(String value) {
  switch (value) {
    case 'chat':
      return LlmProtocol.chat;
    case 'messages':
      return LlmProtocol.messages;
    case 'responses':
    default:
      return LlmProtocol.responses;
  }
}

String llmProtocolStorageValue(LlmProtocol protocol) {
  switch (protocol) {
    case LlmProtocol.responses:
      return 'responses';
    case LlmProtocol.chat:
      return 'chat';
    case LlmProtocol.messages:
      return 'messages';
  }
}

class LlmRequestConvertOptions {
  const LlmRequestConvertOptions({
    this.overrideModel,
    this.reasoningEffort,
    this.prependSystemMessage,
  });

  final String? overrideModel;
  final String? reasoningEffort;

  /// 在 input 首部插一条 role=system 的 message,用于注入"接续 Claude 会话"等运行时指引。
  /// 空/null = 不插。
  final String? prependSystemMessage;
}

List<int> convertLlmProtocolBody(
  List<int> bodyBytes, {
  required LlmProtocol from,
  required LlmProtocol to,
  LlmRequestConvertOptions options = const LlmRequestConvertOptions(),
}) {
  final responsesBody = _toResponses(bodyBytes, from);
  if (responsesBody == null) return bodyBytes;

  final prepared = _applyRequestOptionsToResponses(responsesBody, options);
  switch (to) {
    case LlmProtocol.responses:
      return _encodeJsonObject(prepared);
    case LlmProtocol.chat:
      return _encodeJsonObject(_convertResponsesToChat(prepared));
    case LlmProtocol.messages:
      return _encodeJsonObject(_convertResponsesToAnthropicMessages(prepared));
  }
}

Map<String, Object?>? _toResponses(List<int> bodyBytes, LlmProtocol from) {
  switch (from) {
    case LlmProtocol.responses:
      return _decodeJsonObject(bodyBytes);
    case LlmProtocol.chat:
      final src = _decodeJsonObject(bodyBytes);
      return src == null ? null : _convertChatToResponses(src);
    case LlmProtocol.messages:
      final src = _decodeJsonObject(bodyBytes);
      return src == null ? null : _convertAnthropicMessagesToResponses(src);
  }
}

Map<String, Object?> _applyRequestOptionsToResponses(
  Map<String, Object?> source,
  LlmRequestConvertOptions options,
) {
  final out = Map<String, Object?>.from(source);
  final overrideModel = options.overrideModel;
  if (overrideModel != null && overrideModel.isNotEmpty) {
    out['model'] = overrideModel;
  }

  final effort = options.reasoningEffort;
  if (_isSupportedReasoningEffort(effort)) {
    final existing = out['reasoning'];
    final reasoning = existing is Map
        ? _stringKeyedMap(existing)
        : <String, Object?>{};
    reasoning['effort'] = effort;
    out['reasoning'] = reasoning;
  }

  final prepend = options.prependSystemMessage;
  if (prepend != null && prepend.isNotEmpty) {
    // role 跟 codex 自己发的保持一致:codex 用 'developer' 当 system 角色
    // (Responses API 新规范),所以这里也用 developer,避免中转网关因 role
    // 不在白名单里直接 502。messages 协议转换那边的 _convertResponsesToAnthropicMessages
    // 已经把 developer 当 system 收口。
    final injected = <String, Object?>{
      'type': 'message',
      'role': 'developer',
      'content': [
        {'type': 'input_text', 'text': prepend},
      ],
    };
    final existingInput = out['input'];
    if (existingInput is List) {
      // 插在"最后一条 role=user message"之前。这样能避开 input 头部可能存在的
      // reasoning/assistant 配对(它们必须保持相邻顺序,中间硬塞 system 会让
      // 网关/Responses API 认为结构错乱直接 502)。
      // 找不到 user message 就退回到尾部追加,而不是头部前插。
      final list = List<Object?>.from(existingInput);
      var insertIndex = -1;
      for (var i = list.length - 1; i >= 0; i--) {
        final item = list[i];
        if (item is Map && item['role'] == 'user') {
          insertIndex = i;
          break;
        }
      }
      if (insertIndex >= 0) {
        list.insert(insertIndex, injected);
      } else {
        list.add(injected);
      }
      out['input'] = list;
    } else if (existingInput is String && existingInput.isNotEmpty) {
      out['input'] = [
        injected,
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': existingInput},
          ],
        },
      ];
    } else {
      out['input'] = [injected];
    }
  }
  return out;
}

bool _isSupportedReasoningEffort(String? effort) {
  return effort == 'low' ||
      effort == 'medium' ||
      effort == 'high' ||
      effort == 'xhigh';
}

Map<String, Object?> _convertResponsesToChat(Map<String, Object?> src) {
  final messages = <Map<String, Object?>>[];
  final systemParts = <String>[];
  _appendInstructionParts(systemParts, src['instructions']);

  final body = <Map<String, Object?>>[];
  final input = src['input'];
  if (input is String && input.isNotEmpty) {
    body.add({'role': 'user', 'content': input});
  } else if (input is List) {
    for (final raw in input) {
      if (raw is! Map) continue;
      final item = _stringKeyedMap(raw);
      final type = item['type'];
      if (type == 'reasoning') {
        continue;
      }
      if (type == 'function_call') {
        body.add({
          'role': 'assistant',
          'content': null,
          'tool_calls': [
            {
              'id': item['call_id'] ?? item['id'] ?? '',
              'type': 'function',
              'function': {
                'name': item['name'] ?? '',
                'arguments': item['arguments'] ?? '',
              },
            },
          ],
        });
        continue;
      }
      if (type == 'function_call_output') {
        body.add({
          'role': 'tool',
          'tool_call_id': item['call_id'] ?? '',
          'content': _stringifyContent(item['output']),
        });
        continue;
      }

      final role = item['role'];
      if (role is! String) continue;
      final text = _stringifyContent(item['content']);
      if (role == 'developer' || role == 'system') {
        if (text.isNotEmpty) systemParts.add(text);
      } else if (text.isNotEmpty) {
        body.add({'role': _chatRole(role), 'content': text});
      }
    }
  }

  if (systemParts.isNotEmpty) {
    messages.add({'role': 'system', 'content': systemParts.join('\n\n')});
  }
  messages.addAll(body);

  final out = <String, Object?>{
    'model': src['model'],
    'messages': messages,
    'stream': true,
    'stream_options': {'include_usage': true},
  };

  final tools = _responsesToolsToChat(src['tools']);
  if (tools.isNotEmpty) out['tools'] = tools;
  if (src['tool_choice'] != null) out['tool_choice'] = src['tool_choice'];

  final maxOut = src['max_output_tokens'];
  if (maxOut is int) out['max_tokens'] = maxOut;
  if (src['temperature'] != null) out['temperature'] = src['temperature'];
  if (src['top_p'] != null) out['top_p'] = src['top_p'];

  final reasoning = src['reasoning'];
  if (reasoning is Map) {
    final effort = _stringKeyedMap(reasoning)['effort'];
    if (effort is String && _isSupportedReasoningEffort(effort)) {
      out['reasoning_effort'] = effort;
    }
  }

  return out;
}

Map<String, Object?> _convertResponsesToAnthropicMessages(
  Map<String, Object?> src,
) {
  final systemParts = <String>[];
  _appendInstructionParts(systemParts, src['instructions']);

  final messages = <Map<String, Object?>>[];
  final input = src['input'];
  if (input is String && input.isNotEmpty) {
    _appendAnthropicMessage(messages, 'user', [_anthropicTextBlock(input)]);
  } else if (input is List) {
    for (final raw in input) {
      if (raw is! Map) continue;
      final item = _stringKeyedMap(raw);
      final type = item['type'];
      if (type == 'reasoning') continue;

      if (type == 'function_call') {
        _appendAnthropicMessage(messages, 'assistant', [
          {
            'type': 'tool_use',
            'id': item['call_id'] ?? item['id'] ?? '',
            'name': item['name'] ?? '',
            'input': _parseArgumentsObject(item['arguments']),
          },
        ]);
        continue;
      }

      if (type == 'function_call_output') {
        _appendAnthropicMessage(messages, 'user', [
          {
            'type': 'tool_result',
            'tool_use_id': item['call_id'] ?? '',
            'content': _stringifyContent(item['output']),
          },
        ]);
        continue;
      }

      final role = item['role'];
      if (role is! String) continue;
      final text = _stringifyContent(item['content']);
      if (role == 'developer' || role == 'system') {
        if (text.isNotEmpty) systemParts.add(text);
      } else if (text.isNotEmpty) {
        _appendAnthropicMessage(
          messages,
          role == 'assistant' ? 'assistant' : 'user',
          [_anthropicTextBlock(text)],
        );
      }
    }
  }

  final out = <String, Object?>{
    'model': src['model'],
    'messages': messages,
    'stream': true,
    'max_tokens': _resolveAnthropicMaxTokens(src),
  };
  if (systemParts.isNotEmpty) out['system'] = systemParts.join('\n\n');

  final tools = _responsesToolsToAnthropic(src['tools']);
  if (tools.isNotEmpty) out['tools'] = tools;

  final toolChoice = _responsesToolChoiceToAnthropic(src['tool_choice']);
  if (toolChoice != null) out['tool_choice'] = toolChoice;
  if (src['temperature'] != null) out['temperature'] = src['temperature'];
  if (src['top_p'] != null) out['top_p'] = src['top_p'];

  return out;
}

Map<String, Object?> _convertChatToResponses(Map<String, Object?> src) {
  final instructions = <String>[];
  final input = <Map<String, Object?>>[];
  final messages = src['messages'];
  if (messages is List) {
    for (final raw in messages) {
      if (raw is! Map) continue;
      final message = _stringKeyedMap(raw);
      final role = message['role'];
      if (role is! String) continue;

      if (role == 'system' || role == 'developer') {
        final text = _stringifyContent(message['content']);
        if (text.isNotEmpty) instructions.add(text);
        continue;
      }

      final toolCalls = message['tool_calls'];
      if (role == 'assistant' && toolCalls is List) {
        for (final rawCall in toolCalls) {
          if (rawCall is! Map) continue;
          final call = _stringKeyedMap(rawCall);
          final function = call['function'];
          final fn = function is Map ? _stringKeyedMap(function) : null;
          input.add({
            'type': 'function_call',
            'call_id': call['id'] ?? '',
            'name': fn?['name'] ?? '',
            'arguments': fn?['arguments'] ?? '',
          });
        }
      }

      if (role == 'tool') {
        input.add({
          'type': 'function_call_output',
          'call_id': message['tool_call_id'] ?? '',
          'output': _stringifyContent(message['content']),
        });
        continue;
      }

      final text = _stringifyContent(message['content']);
      if (text.isNotEmpty) {
        input.add({
          'role': role == 'assistant' ? 'assistant' : 'user',
          'content': [
            {
              'type': role == 'assistant' ? 'output_text' : 'input_text',
              'text': text,
            },
          ],
        });
      }
    }
  }

  final out = <String, Object?>{
    'model': src['model'],
    'input': input,
  };
  if (instructions.isNotEmpty) out['instructions'] = instructions.join('\n\n');

  final tools = _chatToolsToResponses(src['tools']);
  if (tools.isNotEmpty) out['tools'] = tools;

  final maxTokens = src['max_tokens'];
  if (maxTokens is int) out['max_output_tokens'] = maxTokens;
  if (src['temperature'] != null) out['temperature'] = src['temperature'];
  if (src['top_p'] != null) out['top_p'] = src['top_p'];
  if (src['stream'] != null) out['stream'] = src['stream'];
  if (src['tool_choice'] != null) out['tool_choice'] = src['tool_choice'];

  final effort = src['reasoning_effort'];
  if (effort is String && _isSupportedReasoningEffort(effort)) {
    out['reasoning'] = {'effort': effort};
  }

  return out;
}

Map<String, Object?> _convertAnthropicMessagesToResponses(
  Map<String, Object?> src,
) {
  final input = <Map<String, Object?>>[];
  final messages = src['messages'];
  if (messages is List) {
    for (final raw in messages) {
      if (raw is! Map) continue;
      final message = _stringKeyedMap(raw);
      final role = message['role'];
      if (role is! String) continue;
      _appendAnthropicContentToResponsesInput(input, role, message['content']);
    }
  }

  final out = <String, Object?>{
    'model': src['model'],
    'input': input,
  };

  final system = src['system'];
  if (system is String && system.isNotEmpty) out['instructions'] = system;

  final tools = _anthropicToolsToResponses(src['tools']);
  if (tools.isNotEmpty) out['tools'] = tools;

  final maxTokens = src['max_tokens'];
  if (maxTokens is int) out['max_output_tokens'] = maxTokens;
  if (src['temperature'] != null) out['temperature'] = src['temperature'];
  if (src['top_p'] != null) out['top_p'] = src['top_p'];
  if (src['stream'] != null) out['stream'] = src['stream'];
  if (src['tool_choice'] != null) out['tool_choice'] = src['tool_choice'];

  return out;
}

Map<String, Object?>? _decodeJsonObject(List<int> bodyBytes) {
  if (bodyBytes.isEmpty) return null;
  try {
    final Object? decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map) return null;
    return _stringKeyedMap(decoded);
  } catch (_) {
    return null;
  }
}

List<int> _encodeJsonObject(Map<String, Object?> value) {
  return utf8.encode(jsonEncode(value));
}

Map<String, Object?> _stringKeyedMap(Map source) {
  return source.map((key, value) => MapEntry(key.toString(), value));
}

void _appendInstructionParts(List<String> target, Object? instructions) {
  if (instructions is String && instructions.isNotEmpty) {
    target.add(instructions);
  } else if (instructions is List) {
    for (final raw in instructions) {
      final text = _stringifyContent(raw);
      if (text.isNotEmpty) target.add(text);
    }
  }
}

String _chatRole(String role) {
  switch (role) {
    case 'assistant':
      return 'assistant';
    case 'developer':
    case 'system':
      return 'system';
    default:
      return 'user';
  }
}

String _stringifyContent(Object? content) {
  if (content is String) return content;
  if (content is List) {
    final buffer = StringBuffer();
    for (final part in content) {
      if (part is Map) {
        final text = _stringKeyedMap(part)['text'];
        if (text is String) buffer.write(text);
      } else if (part is String) {
        buffer.write(part);
      }
    }
    return buffer.toString();
  }
  return content?.toString() ?? '';
}

List<Map<String, Object?>> _responsesToolsToChat(Object? tools) {
  if (tools is! List) return const <Map<String, Object?>>[];
  final out = <Map<String, Object?>>[];
  for (final raw in tools) {
    if (raw is! Map) continue;
    final tool = _stringKeyedMap(raw);
    if (tool['function'] is Map) {
      out.add(tool);
      continue;
    }
    if (tool['type'] == 'function' && tool['name'] != null) {
      out.add({
        'type': 'function',
        'function': {
          'name': tool['name'],
          if (tool['description'] != null) 'description': tool['description'],
          if (tool['parameters'] != null) 'parameters': tool['parameters'],
        },
      });
    }
  }
  return out;
}

List<Map<String, Object?>> _responsesToolsToAnthropic(Object? tools) {
  if (tools is! List) return const <Map<String, Object?>>[];
  final converted = <Map<String, Object?>>[];
  for (final raw in tools) {
    if (raw is! Map) continue;
    final tool = _stringKeyedMap(raw);

    final inputSchema = tool['input_schema'];
    if (tool['name'] is String && inputSchema is Map) {
      converted.add(tool);
      continue;
    }

    final function = tool['function'];
    if (function is Map) {
      final fn = _stringKeyedMap(function);
      if (fn['name'] is String) {
        converted.add({
          'name': fn['name'],
          if (fn['description'] != null) 'description': fn['description'],
          'input_schema': fn['parameters'] ?? _emptyObjectSchema(),
        });
      }
      continue;
    }

    if (tool['type'] == 'function' && tool['name'] is String) {
      converted.add({
        'name': tool['name'],
        if (tool['description'] != null) 'description': tool['description'],
        'input_schema': tool['parameters'] ?? _emptyObjectSchema(),
      });
    }
  }
  return converted;
}

List<Map<String, Object?>> _chatToolsToResponses(Object? tools) {
  if (tools is! List) return const <Map<String, Object?>>[];
  final out = <Map<String, Object?>>[];
  for (final raw in tools) {
    if (raw is! Map) continue;
    final tool = _stringKeyedMap(raw);
    final function = tool['function'];
    if (function is Map) {
      final fn = _stringKeyedMap(function);
      out.add({
        'type': 'function',
        'name': fn['name'] ?? '',
        if (fn['description'] != null) 'description': fn['description'],
        if (fn['parameters'] != null) 'parameters': fn['parameters'],
      });
    } else if (tool['type'] == 'function' && tool['name'] is String) {
      out.add(tool);
    }
  }
  return out;
}

List<Map<String, Object?>> _anthropicToolsToResponses(Object? tools) {
  if (tools is! List) return const <Map<String, Object?>>[];
  final out = <Map<String, Object?>>[];
  for (final raw in tools) {
    if (raw is! Map) continue;
    final tool = _stringKeyedMap(raw);
    final name = tool['name'];
    if (name is! String) continue;
    out.add({
      'type': 'function',
      'name': name,
      if (tool['description'] != null) 'description': tool['description'],
      if (tool['input_schema'] != null) 'parameters': tool['input_schema'],
    });
  }
  return out;
}

Map<String, Object?> _emptyObjectSchema() {
  return {'type': 'object', 'properties': <String, Object?>{}};
}

Map<String, Object?> _anthropicTextBlock(String text) {
  return {'type': 'text', 'text': text};
}

void _appendAnthropicMessage(
  List<Map<String, Object?>> messages,
  String role,
  List<Map<String, Object?>> content,
) {
  if (content.isEmpty) return;
  if (messages.isNotEmpty && messages.last['role'] == role) {
    final existing = messages.last['content'];
    if (existing is List) {
      existing.addAll(content);
      return;
    }
  }
  messages.add({'role': role, 'content': content});
}

Object _parseArgumentsObject(Object? arguments) {
  if (arguments is Map) return _stringKeyedMap(arguments);
  if (arguments is String && arguments.trim().isNotEmpty) {
    try {
      final Object? decoded = jsonDecode(arguments);
      if (decoded is Map) return _stringKeyedMap(decoded);
    } catch (_) {
      return <String, Object?>{};
    }
  }
  return <String, Object?>{};
}

int _resolveAnthropicMaxTokens(Map<String, Object?> src) {
  final maxOutput = src['max_output_tokens'];
  if (maxOutput is int && maxOutput > 0) return maxOutput;
  final maxTokens = src['max_tokens'];
  if (maxTokens is int && maxTokens > 0) return maxTokens;
  return 4096;
}

Map<String, Object?>? _responsesToolChoiceToAnthropic(Object? toolChoice) {
  if (toolChoice == null) return null;
  if (toolChoice is String) {
    switch (toolChoice) {
      case 'auto':
      case 'any':
      case 'none':
        return {'type': toolChoice};
      case 'required':
        return {'type': 'any'};
      default:
        return null;
    }
  }
  if (toolChoice is Map) {
    final choice = _stringKeyedMap(toolChoice);
    final type = choice['type'];
    if (type == 'auto' || type == 'any' || type == 'none') {
      return {'type': type};
    }
    if (type == 'required') return {'type': 'any'};
    if (type == 'tool' && choice['name'] is String) {
      return {'type': 'tool', 'name': choice['name']};
    }
    if (type == 'function') {
      final function = choice['function'];
      final name = function is Map ? _stringKeyedMap(function)['name'] : null;
      if (name is String && name.isNotEmpty) {
        return {'type': 'tool', 'name': name};
      }
    }
  }
  return null;
}

void _appendAnthropicContentToResponsesInput(
  List<Map<String, Object?>> input,
  String role,
  Object? content,
) {
  if (content is String) {
    if (content.isNotEmpty) {
      input.add({
        'role': role == 'assistant' ? 'assistant' : 'user',
        'content': [
          {
            'type': role == 'assistant' ? 'output_text' : 'input_text',
            'text': content,
          },
        ],
      });
    }
    return;
  }

  if (content is! List) return;
  final textParts = <String>[];
  for (final rawPart in content) {
    if (rawPart is! Map) continue;
    final part = _stringKeyedMap(rawPart);
    final type = part['type'];
    if (type == 'text') {
      final text = part['text'];
      if (text is String && text.isNotEmpty) textParts.add(text);
    } else if (type == 'tool_use') {
      input.add({
        'type': 'function_call',
        'call_id': part['id'] ?? '',
        'name': part['name'] ?? '',
        'arguments': jsonEncode(part['input'] ?? <String, Object?>{}),
      });
    } else if (type == 'tool_result') {
      input.add({
        'type': 'function_call_output',
        'call_id': part['tool_use_id'] ?? '',
        'output': _stringifyContent(part['content']),
      });
    }
  }

  if (textParts.isNotEmpty) {
    input.add({
      'role': role == 'assistant' ? 'assistant' : 'user',
      'content': [
        {
          'type': role == 'assistant' ? 'output_text' : 'input_text',
          'text': textParts.join('\n\n'),
        },
      ],
    });
  }
}

import 'dart:convert';
import 'dart:io';

List<int> convertResponsesBodyToAnthropicMessages(
  List<int> bodyBytes,
  String? overrideModel,
) {
  Map<String, dynamic> src;
  try {
    final decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map<String, dynamic>) return bodyBytes;
    src = decoded;
  } catch (_) {
    return bodyBytes;
  }

  final systemParts = <String>[];
  final instructions = src['instructions'];
  if (instructions is String && instructions.isNotEmpty) {
    systemParts.add(instructions);
  }

  final messages = <Map<String, dynamic>>[];
  final input = src['input'];
  if (input is String && input.isNotEmpty) {
    _appendMessage(messages, 'user', [_textBlock(input)]);
  } else if (input is List) {
    for (final raw in input) {
      if (raw is! Map<String, dynamic>) continue;
      final type = raw['type'];
      if (type == 'reasoning') continue;

      if (type == 'function_call') {
        _appendMessage(messages, 'assistant', [
          {
            'type': 'tool_use',
            'id': raw['call_id'] ?? raw['id'] ?? '',
            'name': raw['name'] ?? '',
            'input': _parseArgumentsObject(raw['arguments']),
          },
        ]);
        continue;
      }

      if (type == 'function_call_output') {
        _appendMessage(messages, 'user', [
          {
            'type': 'tool_result',
            'tool_use_id': raw['call_id'] ?? '',
            'content': _stringifyContent(raw['output']),
          },
        ]);
        continue;
      }

      final role = raw['role'];
      if (role is! String) continue;
      final text = _stringifyContent(raw['content']);
      if (role == 'developer' || role == 'system') {
        if (text.isNotEmpty) systemParts.add(text);
      } else if (text.isNotEmpty) {
        _appendMessage(messages, role == 'assistant' ? 'assistant' : 'user', [
          _textBlock(text),
        ]);
      }
    }
  }

  final out = <String, dynamic>{
    'model': (overrideModel != null && overrideModel.isNotEmpty)
        ? overrideModel
        : src['model'],
    'messages': messages,
    'stream': true,
    'max_tokens': _resolveMaxTokens(src),
  };
  if (systemParts.isNotEmpty) out['system'] = systemParts.join('\n\n');

  final tools = _convertTools(src['tools']);
  if (tools.isNotEmpty) out['tools'] = tools;

  final toolChoice = _convertToolChoice(src['tool_choice']);
  if (toolChoice != null) out['tool_choice'] = toolChoice;

  if (src['temperature'] != null) out['temperature'] = src['temperature'];
  if (src['top_p'] != null) out['top_p'] = src['top_p'];

  return utf8.encode(jsonEncode(out));
}

int _resolveMaxTokens(Map<String, dynamic> src) {
  final maxOutput = src['max_output_tokens'];
  if (maxOutput is int && maxOutput > 0) return maxOutput;
  final maxTokens = src['max_tokens'];
  if (maxTokens is int && maxTokens > 0) return maxTokens;
  return 4096;
}

List<Map<String, dynamic>> _convertTools(dynamic tools) {
  if (tools is! List || tools.isEmpty) return const [];
  final converted = <Map<String, dynamic>>[];
  for (final raw in tools) {
    if (raw is! Map<String, dynamic>) continue;

    if (raw['name'] is String && raw['input_schema'] is Map) {
      converted.add(raw);
      continue;
    }

    final function = raw['function'];
    if (function is Map<String, dynamic> && function['name'] is String) {
      converted.add({
        'name': function['name'],
        if (function['description'] != null)
          'description': function['description'],
        'input_schema': function['parameters'] ?? _emptyObjectSchema(),
      });
      continue;
    }

    if (raw['type'] == 'function' && raw['name'] is String) {
      converted.add({
        'name': raw['name'],
        if (raw['description'] != null) 'description': raw['description'],
        'input_schema': raw['parameters'] ?? _emptyObjectSchema(),
      });
    }
  }
  return converted;
}

Map<String, dynamic>? _convertToolChoice(dynamic toolChoice) {
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
  if (toolChoice is Map<String, dynamic>) {
    final type = toolChoice['type'];
    if (type == 'auto' || type == 'any' || type == 'none') {
      return {'type': type};
    }
    if (type == 'required') return {'type': 'any'};
    if (type == 'tool' && toolChoice['name'] is String) {
      return {'type': 'tool', 'name': toolChoice['name']};
    }
    if (type == 'function') {
      final function = toolChoice['function'];
      final name = function is Map ? function['name'] : null;
      if (name is String && name.isNotEmpty) {
        return {'type': 'tool', 'name': name};
      }
    }
  }
  return null;
}

Map<String, dynamic> _emptyObjectSchema() {
  return {'type': 'object', 'properties': <String, dynamic>{}};
}

Map<String, dynamic> _textBlock(String text) {
  return {'type': 'text', 'text': text};
}

void _appendMessage(
  List<Map<String, dynamic>> messages,
  String role,
  List<Map<String, dynamic>> content,
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

dynamic _parseArgumentsObject(dynamic arguments) {
  if (arguments is Map<String, dynamic>) return arguments;
  if (arguments is Map) return Map<String, dynamic>.from(arguments);
  if (arguments is String && arguments.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(arguments);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
  return <String, dynamic>{};
}

String _stringifyContent(dynamic content) {
  if (content is String) return content;
  if (content is List) {
    final buf = StringBuffer();
    for (final part in content) {
      if (part is Map) {
        final text = part['text'];
        if (text is String) buf.write(text);
      }
    }
    return buf.toString();
  }
  return content?.toString() ?? '';
}

class _AnthropicToolState {
  int? outputIndex;
  String itemId = '';
  String callId = '';
  String name = '';
  final StringBuffer arguments = StringBuffer();
  bool added = false;
}

class AnthropicMessagesToResponsesTransformer {
  String _responseId = '';
  String _model = '';
  int _createdAt = 0;
  bool _responseStarted = false;
  var _nextOutputIndex = 0;

  int? _textOutputIndex;
  String _textItemId = '';
  final StringBuffer _textBuf = StringBuffer();
  var _textAdded = false;

  int? _reasoningOutputIndex;
  String _reasoningItemId = '';
  final StringBuffer _reasoningBuf = StringBuffer();
  var _reasoningAdded = false;

  final Map<int, _AnthropicToolState> _tools = {};

  String? _stopReason;
  int _inputTokens = 0;
  int _outputTokens = 0;
  var _finalized = false;

  int _takeIndex() => _nextOutputIndex++;

  Future<void> transform(
    HttpClientResponse upstream,
    HttpResponse downstream,
  ) async {
    downstream.headers.contentType =
        ContentType('text', 'event-stream', charset: 'utf-8');
    downstream.headers.set('cache-control', 'no-cache');

    try {
      await upstream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) => _handleLine(line, downstream));
    } catch (e, st) {
      // ignore: avoid_print
      print('[AnthropicTransform] error: $e\n$st');
    }

    _finalize(downstream);
    await downstream.flush();
    await downstream.close();
  }

  void _handleLine(String line, HttpResponse out) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('data:')) return;
    final payload = trimmed.substring(5).trim();
    if (payload.isEmpty || payload == '[DONE]') return;

    Map<String, dynamic> event;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return;
      event = decoded;
    } catch (_) {
      return;
    }
    _handleEvent(event, out);
  }

  void _handleEvent(Map<String, dynamic> event, HttpResponse out) {
    final type = event['type'];
    if (type == 'message_start') {
      _handleMessageStart(event, out);
    } else if (type == 'content_block_start') {
      _handleContentBlockStart(event, out);
    } else if (type == 'content_block_delta') {
      _handleContentBlockDelta(event, out);
    } else if (type == 'message_delta') {
      _handleMessageDelta(event);
    } else if (type == 'message_stop') {
      _finalize(out);
    } else if (type == 'error') {
      // ignore: avoid_print
      print('[AnthropicTransform] upstream error: $event');
    }
  }

  void _handleMessageStart(Map<String, dynamic> event, HttpResponse out) {
    final message = event['message'];
    if (message is Map<String, dynamic>) {
      final id = message['id'];
      _responseId = 'resp_${id is String ? id : ''}';
      _model = message['model'] is String ? message['model'] as String : _model;
      final usage = message['usage'];
      if (usage is Map<String, dynamic>) _captureUsage(usage);
    }
    _createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _textItemId = '${_responseId}_msg';
    _reasoningItemId = 'rs_$_responseId';
    _emitResponseStarted(out);
    _responseStarted = true;
  }

  void _handleContentBlockStart(Map<String, dynamic> event, HttpResponse out) {
    _ensureStarted(out);
    final index = event['index'];
    final blockIndex = index is int ? index : 0;
    final block = event['content_block'];
    if (block is! Map<String, dynamic>) return;

    final type = block['type'];
    if (type == 'text') {
      final text = block['text'];
      if (text is String && text.isNotEmpty) _appendText(text, out);
    } else if (type == 'thinking') {
      final thinking = block['thinking'];
      if (thinking is String && thinking.isNotEmpty) {
        _appendReasoning(thinking, out);
      }
    } else if (type == 'tool_use') {
      final state = _tools.putIfAbsent(
        blockIndex,
        () => _AnthropicToolState(),
      );
      state.callId = block['id'] is String ? block['id'] as String : '';
      state.name = block['name'] is String ? block['name'] as String : '';
      state.itemId = 'fc_${state.callId}';
      state.outputIndex = _takeIndex();
      state.added = true;
      final input = block['input'];
      if (input is Map && input.isNotEmpty) {
        state.arguments.write(jsonEncode(input));
      }
      _emit(out, 'response.output_item.added', {
        'type': 'response.output_item.added',
        'output_index': state.outputIndex,
        'item': {
          'id': state.itemId,
          'type': 'function_call',
          'status': 'in_progress',
          'call_id': state.callId,
          'name': state.name,
          'arguments': '',
        },
      });
    }
  }

  void _handleContentBlockDelta(Map<String, dynamic> event, HttpResponse out) {
    _ensureStarted(out);
    final delta = event['delta'];
    if (delta is! Map<String, dynamic>) return;

    final type = delta['type'];
    if (type == 'text_delta') {
      final text = delta['text'];
      if (text is String && text.isNotEmpty) _appendText(text, out);
    } else if (type == 'thinking_delta') {
      final thinking = delta['thinking'];
      if (thinking is String && thinking.isNotEmpty) {
        _appendReasoning(thinking, out);
      }
    } else if (type == 'input_json_delta') {
      final index = event['index'];
      final blockIndex = index is int ? index : 0;
      final state = _tools.putIfAbsent(
        blockIndex,
        () => _AnthropicToolState(),
      );
      final partial = delta['partial_json'];
      if (partial is String && partial.isNotEmpty && state.added) {
        state.arguments.write(partial);
        _emit(out, 'response.function_call_arguments.delta', {
          'type': 'response.function_call_arguments.delta',
          'item_id': state.itemId,
          'output_index': state.outputIndex,
          'delta': partial,
        });
      }
    }
  }

  void _handleMessageDelta(Map<String, dynamic> event) {
    final delta = event['delta'];
    if (delta is Map<String, dynamic>) {
      final stopReason = delta['stop_reason'];
      if (stopReason is String) _stopReason = stopReason;
    }
    final usage = event['usage'];
    if (usage is Map<String, dynamic>) _captureUsage(usage);
  }

  void _captureUsage(Map<String, dynamic> usage) {
    final input = usage['input_tokens'];
    if (input is num) _inputTokens = input.toInt();
    final output = usage['output_tokens'];
    if (output is num) _outputTokens = output.toInt();
  }

  void _appendText(String text, HttpResponse out) {
    _ensureTextItem(out);
    _textBuf.write(text);
    _emit(out, 'response.output_text.delta', {
      'type': 'response.output_text.delta',
      'item_id': _textItemId,
      'output_index': _textOutputIndex,
      'content_index': 0,
      'delta': text,
    });
  }

  void _appendReasoning(String text, HttpResponse out) {
    _ensureReasoningItem(out);
    _reasoningBuf.write(text);
    _emit(out, 'response.reasoning_summary_text.delta', {
      'type': 'response.reasoning_summary_text.delta',
      'item_id': _reasoningItemId,
      'output_index': _reasoningOutputIndex,
      'summary_index': 0,
      'delta': text,
    });
  }

  void _ensureStarted(HttpResponse out) {
    if (_responseStarted) return;
    _responseId = _responseId.isEmpty ? 'resp_anthropic' : _responseId;
    _createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _textItemId = '${_responseId}_msg';
    _reasoningItemId = 'rs_$_responseId';
    _emitResponseStarted(out);
    _responseStarted = true;
  }

  void _ensureTextItem(HttpResponse out) {
    if (_textAdded) return;
    _textOutputIndex = _takeIndex();
    _textAdded = true;
    _emit(out, 'response.output_item.added', {
      'type': 'response.output_item.added',
      'output_index': _textOutputIndex,
      'item': {
        'id': _textItemId,
        'type': 'message',
        'status': 'in_progress',
        'role': 'assistant',
        'content': [],
      },
    });
    _emit(out, 'response.content_part.added', {
      'type': 'response.content_part.added',
      'item_id': _textItemId,
      'output_index': _textOutputIndex,
      'content_index': 0,
      'part': {'type': 'output_text', 'text': '', 'annotations': []},
    });
  }

  void _ensureReasoningItem(HttpResponse out) {
    if (_reasoningAdded) return;
    _reasoningOutputIndex = _takeIndex();
    _reasoningAdded = true;
    _emit(out, 'response.output_item.added', {
      'type': 'response.output_item.added',
      'output_index': _reasoningOutputIndex,
      'item': {
        'id': _reasoningItemId,
        'type': 'reasoning',
        'status': 'in_progress',
        'summary': [],
      },
    });
    _emit(out, 'response.reasoning_summary_part.added', {
      'type': 'response.reasoning_summary_part.added',
      'item_id': _reasoningItemId,
      'output_index': _reasoningOutputIndex,
      'summary_index': 0,
      'part': {'type': 'summary_text', 'text': ''},
    });
  }

  void _finalize(HttpResponse out) {
    if (_finalized) return;
    _finalized = true;
    _ensureStarted(out);

    final output = <Map<String, dynamic>>[];
    _finishReasoning(out, output);
    _finishText(out, output);
    _finishTools(out, output);

    final status = _stopReason == 'max_tokens' ? 'incomplete' : 'completed';
    final response = _baseResponse()
      ..['status'] = status
      ..['output'] = output
      ..['usage'] = _normalizedUsage();
    _emit(out, 'response.completed', {
      'type': 'response.completed',
      'response': response,
    });
  }

  void _finishReasoning(HttpResponse out, List<Map<String, dynamic>> output) {
    if (!_reasoningAdded) return;
    final text = _reasoningBuf.toString();
    _emit(out, 'response.reasoning_summary_text.done', {
      'type': 'response.reasoning_summary_text.done',
      'item_id': _reasoningItemId,
      'output_index': _reasoningOutputIndex,
      'summary_index': 0,
      'text': text,
    });
    _emit(out, 'response.reasoning_summary_part.done', {
      'type': 'response.reasoning_summary_part.done',
      'item_id': _reasoningItemId,
      'output_index': _reasoningOutputIndex,
      'summary_index': 0,
      'part': {'type': 'summary_text', 'text': text},
    });
    final item = {
      'id': _reasoningItemId,
      'type': 'reasoning',
      'summary': [
        {'type': 'summary_text', 'text': text},
      ],
    };
    _emit(out, 'response.output_item.done', {
      'type': 'response.output_item.done',
      'output_index': _reasoningOutputIndex,
      'item': item,
    });
    output.add(item);
  }

  void _finishText(HttpResponse out, List<Map<String, dynamic>> output) {
    if (!_textAdded) return;
    final text = _textBuf.toString();
    _emit(out, 'response.output_text.done', {
      'type': 'response.output_text.done',
      'item_id': _textItemId,
      'output_index': _textOutputIndex,
      'content_index': 0,
      'text': text,
    });
    _emit(out, 'response.content_part.done', {
      'type': 'response.content_part.done',
      'item_id': _textItemId,
      'output_index': _textOutputIndex,
      'content_index': 0,
      'part': {'type': 'output_text', 'text': text, 'annotations': []},
    });
    final item = {
      'id': _textItemId,
      'type': 'message',
      'status': 'completed',
      'role': 'assistant',
      'content': [
        {'type': 'output_text', 'text': text, 'annotations': []},
      ],
    };
    _emit(out, 'response.output_item.done', {
      'type': 'response.output_item.done',
      'output_index': _textOutputIndex,
      'item': item,
    });
    output.add(item);
  }

  void _finishTools(HttpResponse out, List<Map<String, dynamic>> output) {
    final toolStates = _tools.values.where((t) => t.added).toList()
      ..sort((a, b) => (a.outputIndex ?? 0).compareTo(b.outputIndex ?? 0));
    for (final t in toolStates) {
      final argStr = t.arguments.toString();
      _emit(out, 'response.function_call_arguments.done', {
        'type': 'response.function_call_arguments.done',
        'item_id': t.itemId,
        'output_index': t.outputIndex,
        'arguments': argStr,
      });
      final item = {
        'id': t.itemId,
        'type': 'function_call',
        'status': 'completed',
        'call_id': t.callId,
        'name': t.name,
        'arguments': argStr,
      };
      _emit(out, 'response.output_item.done', {
        'type': 'response.output_item.done',
        'output_index': t.outputIndex,
        'item': item,
      });
      output.add(item);
    }
  }

  void _emitResponseStarted(HttpResponse out) {
    final base = _baseResponse();
    _emit(out, 'response.created', {
      'type': 'response.created',
      'response': base,
    });
    _emit(out, 'response.in_progress', {
      'type': 'response.in_progress',
      'response': base,
    });
  }

  Map<String, dynamic> _baseResponse() {
    return {
      'id': _responseId,
      'object': 'response',
      'created_at': _createdAt,
      'status': 'in_progress',
      'model': _model,
      'output': [],
      'usage': _normalizedUsage(),
    };
  }

  Map<String, dynamic> _normalizedUsage() {
    return {
      'input_tokens': _inputTokens,
      'output_tokens': _outputTokens,
      'total_tokens': _inputTokens + _outputTokens,
      'output_tokens_details': {'reasoning_tokens': 0},
    };
  }

  void _emit(HttpResponse out, String event, Map<String, dynamic> data) {
    // ignore: avoid_print
    print('[AnthropicTransform] -> $event');
    out.write('event: $event\n');
    out.write('data: ${jsonEncode(data)}\n\n');
  }
}

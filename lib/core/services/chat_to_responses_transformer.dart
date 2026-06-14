import 'dart:convert';
import 'dart:io';

/// 把 Codex 的 Responses API 请求体转成 Chat Completions 请求体。
///
/// Codex 发的是 `{model, instructions, input:[...], tools, max_output_tokens, ...}`，
/// 上游 chat 端点要的是 `{model, messages:[...], tools, max_tokens, stream}`。
/// model 用传入的 override（非空时覆盖）。
List<int> convertResponsesBodyToChat(List<int> bodyBytes, String? overrideModel) {
  Map<String, dynamic> src;
  try {
    final decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map<String, dynamic>) return bodyBytes;
    src = decoded;
  } catch (_) {
    return bodyBytes;
  }

  // 调试：打印原始请求体结构（input 各项的 type/role/content 形态）
  // ignore: avoid_print
  print('[ReqConvert] keys=${src.keys.toList()}');
  final dbgInput = src['input'];
  if (dbgInput is List) {
    for (var i = 0; i < dbgInput.length; i++) {
      final it = dbgInput[i];
      if (it is Map) {
        final c = it['content'];
        final cDesc = c is List
            ? 'List[${c.map((e) => e is Map ? e['type'] : e.runtimeType).toList()}]'
            : c.runtimeType.toString();
        // ignore: avoid_print
        print('[ReqConvert] input[$i] type=${it['type']} role=${it['role']} content=$cDesc');
      }
    }
  }

  final messages = <Map<String, dynamic>>[];

  // 所有 system/developer 文本合并到开头一条 system，避免中间 system 让模型行为异常
  final systemParts = <String>[];
  final instructions = src['instructions'];
  if (instructions is String && instructions.isNotEmpty) {
    systemParts.add(instructions);
  }

  final body = <Map<String, dynamic>>[];
  final input = src['input'];
  if (input is String && input.isNotEmpty) {
    body.add({'role': 'user', 'content': input});
  } else if (input is List) {
    for (final raw in input) {
      if (raw is! Map<String, dynamic>) continue;
      final type = raw['type'];
      if (type == 'reasoning') {
        continue; // 推理项不回传给上游
      } else if (type == 'function_call') {
        body.add({
          'role': 'assistant',
          'content': null,
          'tool_calls': [
            {
              'id': raw['call_id'] ?? raw['id'] ?? '',
              'type': 'function',
              'function': {
                'name': raw['name'] ?? '',
                'arguments': raw['arguments'] ?? '',
              },
            },
          ],
        });
      } else if (type == 'function_call_output') {
        body.add({
          'role': 'tool',
          'tool_call_id': raw['call_id'] ?? '',
          'content': _stringifyContent(raw['output']),
        });
      } else {
        final role = raw['role'];
        if (role is! String) continue;
        final text = _stringifyContent(raw['content']);
        if (role == 'developer' || role == 'system') {
          // 收集到 system，不在中间产出
          if (text.isNotEmpty) systemParts.add(text);
        } else {
          body.add({'role': _mapRole(role), 'content': text});
        }
      }
    }
  }

  if (systemParts.isNotEmpty) {
    messages.add({'role': 'system', 'content': systemParts.join('\n\n')});
  }
  messages.addAll(body);

  final out = <String, dynamic>{
    'model': (overrideModel != null && overrideModel.isNotEmpty)
        ? overrideModel
        : src['model'],
    'messages': messages,
    'stream': true,
    'stream_options': {'include_usage': true},
  };

  // tools：Responses 扁平格式 → Chat 嵌套格式
  final tools = src['tools'];
  if (tools is List && tools.isNotEmpty) {
    final converted = <Map<String, dynamic>>[];
    for (final t in tools) {
      if (t is! Map<String, dynamic>) continue;
      // 已是 Chat 嵌套格式（含 function 字段）则原样保留
      if (t['function'] is Map) {
        converted.add(t);
        continue;
      }
      // Responses 扁平 function：{type, name, description, parameters}
      if (t['type'] == 'function' && t['name'] != null) {
        converted.add({
          'type': 'function',
          'function': {
            'name': t['name'],
            if (t['description'] != null) 'description': t['description'],
            if (t['parameters'] != null) 'parameters': t['parameters'],
          },
        });
      } else {
        converted.add(t);
      }
    }
    if (converted.isNotEmpty) out['tools'] = converted;
  }
  if (src['tool_choice'] != null) out['tool_choice'] = src['tool_choice'];
  // max_output_tokens → max_tokens
  final maxOut = src['max_output_tokens'];
  if (maxOut is int) out['max_tokens'] = maxOut;
  if (src['temperature'] != null) out['temperature'] = src['temperature'];

  return utf8.encode(jsonEncode(out));
}

String _mapRole(String role) {
  switch (role) {
    case 'developer':
    case 'system':
      return 'system';
    case 'assistant':
      return 'assistant';
    default:
      return 'user';
  }
}

/// Responses 的 content 可能是 string，也可能是 [{type, text}] 数组。
String _stringifyContent(dynamic content) {
  if (content is String) return content;
  if (content is List) {
    final buf = StringBuffer();
    for (final part in content) {
      if (part is Map) {
        final t = part['text'];
        if (t is String) buf.write(t);
      }
    }
    return buf.toString();
  }
  return content?.toString() ?? '';
}

/// 单个 tool_call 的累积状态（arguments 跨 chunk 拼接）。
class _ToolCallState {
  int? outputIndex;
  String itemId = '';
  String callId = '';
  String name = '';
  final StringBuffer arguments = StringBuffer();
  bool added = false;
}

/// 把上游 Chat Completions 的 SSE 流实时转换成 Codex 要的 Responses API SSE 流。
///
/// Codex app-server 只认 Responses 协议（`event: response.output_text.delta` …），
/// 而中转站把 Claude 等模型包成 Chat Completions（`chat.completion.chunk`）。
/// 本类逐行消费 Chat chunk，按状态机产出对应的 Responses 事件写回下游。
class ChatToResponsesTransformer {
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

  final Map<int, _ToolCallState> _tools = {};

  String? _finishReason;
  Map<String, dynamic>? _latestUsage;
  var _finalized = false;

  int _takeIndex() => _nextOutputIndex++;

  Future<void> transform(
    HttpClientResponse upstream,
    HttpResponse downstream,
  ) async {
    downstream.headers.contentType =
        ContentType('text', 'event-stream', charset: 'utf-8');
    downstream.headers.set('cache-control', 'no-cache');

    var lineCount = 0;
    try {
      await upstream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) {
        lineCount++;
        _handleLine(line, downstream);
      });
      // ignore: avoid_print
      print('[Transform] 上游流结束, 共 $lineCount 行, started=$_responseStarted');
    } catch (e, st) {
      // ignore: avoid_print
      print('[Transform] ❌ 处理异常 (第 $lineCount 行附近): $e\n$st');
    }

    _finalize(downstream);
    await downstream.flush();
    await downstream.close();
    // ignore: avoid_print
    print('[Transform] finalize 完成（响应已关闭）');
  }

  void _handleLine(String line, HttpResponse out) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.startsWith('data:')) return;
    final payload = trimmed.substring(5).trim();
    if (payload.isEmpty) return;
    if (payload == '[DONE]') {
      _finalize(out);
      return;
    }
    Map<String, dynamic> chunk;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return;
      chunk = decoded;
    } catch (_) {
      return;
    }
    _handleChunk(chunk, out);
  }

  void _handleChunk(Map<String, dynamic> chunk, HttpResponse out) {
    // 首块初始化 id/model/created
    if (!_responseStarted) {
      final chatId = chunk['id'];
      _responseId = 'resp_${chatId is String ? chatId : ''}';
      _model = chunk['model'] is String ? chunk['model'] as String : _model;
      final created = chunk['created'];
      _createdAt = created is int ? created : _createdAt;
      _textItemId = '${_responseId}_msg';
      _reasoningItemId = 'rs_$_responseId';
      _emitResponseStarted(out);
      _responseStarted = true;
    }

    final usage = chunk['usage'];
    if (usage is Map<String, dynamic>) _latestUsage = usage;

    final choices = chunk['choices'];
    if (choices is! List || choices.isEmpty) return;
    final choice = choices.first;
    if (choice is! Map<String, dynamic>) return;

    final delta = choice['delta'];
    if (delta is Map<String, dynamic>) {
      _handleReasoning(delta, out);
      _handleContent(delta, out);
      _handleToolCalls(delta, out);
    }

    final fr = choice['finish_reason'];
    if (fr is String) _finishReason = fr;
  }

  // ---------- reasoning ----------

  void _handleReasoning(Map<String, dynamic> delta, HttpResponse out) {
    final r = delta['reasoning_content'] ?? delta['reasoning'];
    if (r is! String || r.isEmpty) return;

    if (!_reasoningAdded) {
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

    _reasoningBuf.write(r);
    _emit(out, 'response.reasoning_summary_text.delta', {
      'type': 'response.reasoning_summary_text.delta',
      'item_id': _reasoningItemId,
      'output_index': _reasoningOutputIndex,
      'summary_index': 0,
      'delta': r,
    });
  }

  // ---------- content ----------

  void _handleContent(Map<String, dynamic> delta, HttpResponse out) {
    final c = delta['content'];
    if (c is! String || c.isEmpty) return;

    if (!_textAdded) {
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

    _textBuf.write(c);
    _emit(out, 'response.output_text.delta', {
      'type': 'response.output_text.delta',
      'item_id': _textItemId,
      'output_index': _textOutputIndex,
      'content_index': 0,
      'delta': c,
    });
  }

  // ---------- tool calls ----------

  void _handleToolCalls(Map<String, dynamic> delta, HttpResponse out) {
    final calls = delta['tool_calls'];
    if (calls is! List) return;
    for (final raw in calls) {
      if (raw is! Map<String, dynamic>) continue;
      final idx = raw['index'];
      final index = idx is int ? idx : 0;
      final state = _tools.putIfAbsent(index, () => _ToolCallState());

      final fn = raw['function'];
      final id = raw['id'];
      final name = (fn is Map && fn['name'] is String)
          ? fn['name'] as String
          : '';

      if (!state.added && ((id is String && id.isNotEmpty) || name.isNotEmpty)) {
        state.callId = id is String ? id : '';
        state.name = name;
        state.itemId = 'fc_${state.callId}';
        state.outputIndex = _takeIndex();
        state.added = true;
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

      final args = (fn is Map && fn['arguments'] is String)
          ? fn['arguments'] as String
          : '';
      if (args.isNotEmpty && state.added) {
        state.arguments.write(args);
        _emit(out, 'response.function_call_arguments.delta', {
          'type': 'response.function_call_arguments.delta',
          'item_id': state.itemId,
          'output_index': state.outputIndex,
          'delta': args,
        });
      }
    }
  }

  // ---------- finalize ----------

  void _finalize(HttpResponse out) {
    if (_finalized) return;
    _finalized = true;
    if (!_responseStarted) {
      // 上游没产出任何有效 chunk，发个最小 completed 收尾
      _responseId = _responseId.isEmpty ? 'resp_empty' : _responseId;
      _emitResponseStarted(out);
    }

    final output = <Map<String, dynamic>>[];

    // reasoning done
    if (_reasoningAdded) {
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

    // text done
    if (_textAdded) {
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

    // tool calls done（按 outputIndex 顺序）
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

    final status = _finishReason == 'length' ? 'incomplete' : 'completed';
    final response = _baseResponse()
      ..['status'] = status
      ..['output'] = output
      ..['usage'] = _normalizedUsage();
    _emit(out, 'response.completed', {
      'type': 'response.completed',
      'response': response,
    });
  }

  // ---------- helpers ----------

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
    final u = _latestUsage;
    final input = (u?['prompt_tokens'] as num?)?.toInt() ?? 0;
    final outputT = (u?['completion_tokens'] as num?)?.toInt() ?? 0;
    final total = (u?['total_tokens'] as num?)?.toInt() ?? (input + outputT);
    return {
      'input_tokens': input,
      'output_tokens': outputT,
      'total_tokens': total,
      'output_tokens_details': {'reasoning_tokens': 0},
    };
  }

  void _emit(HttpResponse out, String event, Map<String, dynamic> data) {
    // ignore: avoid_print
    print('[Transform] → $event');
    out.write('event: $event\n');
    out.write('data: ${jsonEncode(data)}\n\n');
  }
}

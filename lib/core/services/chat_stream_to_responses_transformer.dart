import 'dart:convert';
import 'dart:io';

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
class ChatStreamToResponsesTransformer {
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


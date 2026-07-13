import 'dart:convert';
import 'dart:io';

class _AnthropicToolState {
  int? outputIndex;
  String itemId = '';
  String callId = '';
  String name = '';
  final StringBuffer arguments = StringBuffer();
  bool added = false;
  bool finished = false;
}

class AnthropicMessagesStreamToResponsesTransformer {
  String _responseId = '';
  String _model = '';
  int _createdAt = 0;
  bool _responseStarted = false;
  var _nextOutputIndex = 0;

  int? _textOutputIndex;
  String _textItemId = '';
  final StringBuffer _textBuf = StringBuffer();
  var _textAdded = false;
  var _textFinished = false;

  int? _reasoningOutputIndex;
  String _reasoningItemId = '';
  final StringBuffer _reasoningBuf = StringBuffer();
  var _reasoningAdded = false;
  var _reasoningFinished = false;

  /// 已经作为最终 output 数组元素累积起来的 item,按到达顺序。
  /// content_block_stop 时收尾的 item 立即入队,_finalize 直接用。
  final List<Map<String, dynamic>> _finishedItems = [];

  final Map<int, _AnthropicToolState> _tools = {};

  /// 按 Anthropic 的 content block index 记录 block 类型,便于 content_block_stop
  /// 时把工具的 arguments.done 提前刷出去,让 codex 尽早看到工具结束。
  final Map<int, String> _blockKind = {};

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
    } else if (type == 'content_block_stop') {
      _handleContentBlockStop(event, out);
    } else if (type == 'message_delta') {
      _handleMessageDelta(event);
    } else if (type == 'message_stop') {
      _finalize(out);
    } else if (type == 'error') {
      _emitUpstreamError(event, out);
    } else if (type == 'ping') {
      // 保活,忽略
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
    if (type is String) _blockKind[blockIndex] = type;
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
      // Anthropic 规范:content_block_start 里 tool_use.input 恒为 {},完整 JSON
      // 由后续 input_json_delta.partial_json 拼出。这里不能把 {} encode 塞进
      // arguments,否则最终 arguments = "{}" + partial_json 变成非法 JSON,
      // codex 侧 JSON.parse 失败,tool 直接空转。
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

  void _handleContentBlockStop(Map<String, dynamic> event, HttpResponse out) {
    _ensureStarted(out);
    final index = event['index'];
    final blockIndex = index is int ? index : 0;
    final kind = _blockKind[blockIndex];
    if (kind == 'tool_use') {
      final state = _tools[blockIndex];
      if (state != null && state.added && !state.finished) {
        _finishToolState(out, state);
      }
    } else if (kind == 'text') {
      // Anthropic 一个 message 可能出现多个 text block,但 Responses 侧当前
      // 用单一 message item 累积所有文本。文本 block 结束不立即关 message item,
      // 保留到 _finalize 里统一 done —— 否则下一个 text block 又要开新 item。
    } else if (kind == 'thinking') {
      // 同上,reasoning summary 里可能有多段。保留累计到 _finalize。
    }
  }

  void _emitUpstreamError(Map<String, dynamic> event, HttpResponse out) {
    _ensureStarted(out);
    final err = event['error'];
    final message = err is Map ? '${err['message'] ?? err}' : '$event';
    final errType = err is Map && err['type'] is String
        ? err['type'] as String
        : 'upstream_error';
    // 先 emit 一个 Responses 风格的 error 事件,codex 那边可能忽略但至少不吊死。
    _emit(out, 'response.error', {
      'type': 'error',
      'code': errType,
      'message': message,
      'param': null,
      'sequence_number': 0,
    });
    // 强制走 failed 收尾路径,别让流一直挂着。
    _stopReason = 'error';
    _finalize(out, failed: true, errorMessage: message);
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

  void _finalize(
    HttpResponse out, {
    bool failed = false,
    String? errorMessage,
  }) {
    if (_finalized) return;
    _finalized = true;
    _ensureStarted(out);

    _finishReasoning(out);
    _finishText(out);
    // 还没在 content_block_stop 里收尾的 tool 补收尾(比如流被截断)。
    for (final t in _tools.values.toList()
      ..sort((a, b) => (a.outputIndex ?? 0).compareTo(b.outputIndex ?? 0))) {
      if (t.added && !t.finished) _finishToolState(out, t);
    }

    final String status;
    if (failed) {
      status = 'failed';
    } else if (_stopReason == 'max_tokens') {
      status = 'incomplete';
    } else {
      status = 'completed';
    }
    final response = _baseResponse()
      ..['status'] = status
      ..['output'] = List<Map<String, dynamic>>.from(_finishedItems)
      ..['usage'] = _normalizedUsage();
    if (failed && errorMessage != null) {
      response['error'] = {
        'code': 'upstream_error',
        'message': errorMessage,
      };
    }
    final eventName = failed ? 'response.failed' : 'response.completed';
    _emit(out, eventName, {
      'type': eventName,
      'response': response,
    });
  }

  void _finishReasoning(HttpResponse out) {
    if (!_reasoningAdded || _reasoningFinished) return;
    _reasoningFinished = true;
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
    _finishedItems.add(item);
  }

  void _finishText(HttpResponse out) {
    if (!_textAdded || _textFinished) return;
    _textFinished = true;
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
    _finishedItems.add(item);
  }

  /// 单个 tool_use block 结束时收尾:emit arguments.done + output_item.done,
  /// 并把 item 加入 _finishedItems 以进入最终 response.output。
  void _finishToolState(HttpResponse out, _AnthropicToolState t) {
    if (t.finished) return;
    t.finished = true;
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
    _finishedItems.add(item);
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


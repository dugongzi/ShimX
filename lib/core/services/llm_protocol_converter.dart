import 'dart:convert';

import 'package:shim/core/services/anthropic_messages_transformer.dart';
import 'package:shim/core/services/chat_to_responses_transformer.dart';

enum LlmWireProtocol {
  responses,
  chat,
  messages,
}

LlmWireProtocol parseLlmWireProtocol(String value) {
  switch (value) {
    case 'chat':
      return LlmWireProtocol.chat;
    case 'messages':
      return LlmWireProtocol.messages;
    case 'responses':
    default:
      return LlmWireProtocol.responses;
  }
}

String llmWireProtocolName(LlmWireProtocol protocol) {
  switch (protocol) {
    case LlmWireProtocol.responses:
      return 'responses';
    case LlmWireProtocol.chat:
      return 'chat';
    case LlmWireProtocol.messages:
      return 'messages';
  }
}

List<int> convertLlmProtocolBody(
  List<int> bodyBytes, {
  required LlmWireProtocol from,
  required LlmWireProtocol to,
  String? overrideModel,
}) {
  if (from == to) {
    return overrideModel == null || overrideModel.isEmpty
        ? bodyBytes
        : rewriteJsonModel(bodyBytes, overrideModel);
  }

  final responsesBody = from == LlmWireProtocol.responses
      ? bodyBytes
      : from == LlmWireProtocol.chat
          ? convertChatBodyToResponses(bodyBytes, overrideModel)
          : convertAnthropicMessagesBodyToResponses(bodyBytes, overrideModel);

  return to == LlmWireProtocol.responses
      ? responsesBody
      : to == LlmWireProtocol.chat
          ? convertResponsesBodyToChat(responsesBody, overrideModel)
          : convertResponsesBodyToAnthropicMessages(responsesBody, overrideModel);
}

List<int> rewriteJsonModel(List<int> bodyBytes, String? model) {
  if (model == null || model.isEmpty || bodyBytes.isEmpty) return bodyBytes;
  try {
    final decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map<String, dynamic>) return bodyBytes;
    decoded['model'] = model;
    return utf8.encode(jsonEncode(decoded));
  } catch (_) {
    return bodyBytes;
  }
}

List<int> convertChatBodyToAnthropicMessages(
  List<int> bodyBytes,
  String? overrideModel,
) {
  return convertLlmProtocolBody(
    bodyBytes,
    from: LlmWireProtocol.chat,
    to: LlmWireProtocol.messages,
    overrideModel: overrideModel,
  );
}

List<int> convertAnthropicMessagesBodyToChat(
  List<int> bodyBytes,
  String? overrideModel,
) {
  return convertLlmProtocolBody(
    bodyBytes,
    from: LlmWireProtocol.messages,
    to: LlmWireProtocol.chat,
    overrideModel: overrideModel,
  );
}

List<int> convertChatBodyToResponses(List<int> bodyBytes, String? overrideModel) {
  Map<String, dynamic> src;
  try {
    final decoded = jsonDecode(utf8.decode(bodyBytes));
    if (decoded is! Map<String, dynamic>) return bodyBytes;
    src = decoded;
  } catch (_) {
    return bodyBytes;
  }

  final instructions = <String>[];
  final input = <Map<String, dynamic>>[];
  final messages = src['messages'];
  if (messages is List) {
    for (final raw in messages) {
      if (raw is! Map<String, dynamic>) continue;
      final role = raw['role'];
      if (role is! String) continue;

      if (role == 'system' || role == 'developer') {
        final text = _chatContentToText(raw['content']);
        if (text.isNotEmpty) instructions.add(text);
        continue;
      }

      final toolCalls = raw['tool_calls'];
      if (role == 'assistant' && toolCalls is List) {
        for (final call in toolCalls) {
          if (call is! Map<String, dynamic>) continue;
          final function = call['function'];
          input.add({
            'type': 'function_call',
            'call_id': call['id'] ?? '',
            'name': function is Map ? function['name'] ?? '' : '',
            'arguments': function is Map ? function['arguments'] ?? '' : '',
          });
        }
      }

      if (role == 'tool') {
        input.add({
          'type': 'function_call_output',
          'call_id': raw['tool_call_id'] ?? '',
          'output': _chatContentToText(raw['content']),
        });
        continue;
      }

      final text = _chatContentToText(raw['content']);
      if (text.isNotEmpty) {
        input.add({
          'role': role == 'assistant' ? 'assistant' : 'user',
          'content': [
            {'type': role == 'assistant' ? 'output_text' : 'input_text', 'text': text},
          ],
        });
      }
    }
  }

  final out = <String, dynamic>{
    'model': (overrideModel != null && overrideModel.isNotEmpty)
        ? overrideModel
        : src['model'],
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

  return utf8.encode(jsonEncode(out));
}

List<int> convertAnthropicMessagesBodyToResponses(
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

  final input = <Map<String, dynamic>>[];
  final messages = src['messages'];
  if (messages is List) {
    for (final raw in messages) {
      if (raw is! Map<String, dynamic>) continue;
      final role = raw['role'];
      if (role is! String) continue;
      _appendAnthropicContentToResponsesInput(input, role, raw['content']);
    }
  }

  final out = <String, dynamic>{
    'model': (overrideModel != null && overrideModel.isNotEmpty)
        ? overrideModel
        : src['model'],
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

  return utf8.encode(jsonEncode(out));
}

String _chatContentToText(dynamic content) {
  if (content is String) return content;
  if (content is List) {
    final buffer = StringBuffer();
    for (final part in content) {
      if (part is Map) {
        final text = part['text'];
        if (text is String) buffer.write(text);
      }
    }
    return buffer.toString();
  }
  return content?.toString() ?? '';
}

List<Map<String, dynamic>> _chatToolsToResponses(dynamic tools) {
  if (tools is! List) return const [];
  final out = <Map<String, dynamic>>[];
  for (final raw in tools) {
    if (raw is! Map<String, dynamic>) continue;
    final function = raw['function'];
    if (function is Map) {
      out.add({
        'type': 'function',
        'name': function['name'] ?? '',
        if (function['description'] != null) 'description': function['description'],
        if (function['parameters'] != null) 'parameters': function['parameters'],
      });
    } else if (raw['type'] == 'function' && raw['name'] is String) {
      out.add(raw);
    }
  }
  return out;
}

List<Map<String, dynamic>> _anthropicToolsToResponses(dynamic tools) {
  if (tools is! List) return const [];
  final out = <Map<String, dynamic>>[];
  for (final raw in tools) {
    if (raw is! Map<String, dynamic>) continue;
    final name = raw['name'];
    if (name is! String) continue;
    out.add({
      'type': 'function',
      'name': name,
      if (raw['description'] != null) 'description': raw['description'],
      if (raw['input_schema'] != null) 'parameters': raw['input_schema'],
    });
  }
  return out;
}

void _appendAnthropicContentToResponsesInput(
  List<Map<String, dynamic>> input,
  String role,
  dynamic content,
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
  for (final part in content) {
    if (part is! Map<String, dynamic>) continue;
    final type = part['type'];
    if (type == 'text') {
      final text = part['text'];
      if (text is String && text.isNotEmpty) textParts.add(text);
    } else if (type == 'tool_use') {
      input.add({
        'type': 'function_call',
        'call_id': part['id'] ?? '',
        'name': part['name'] ?? '',
        'arguments': jsonEncode(part['input'] ?? <String, dynamic>{}),
      });
    } else if (type == 'tool_result') {
      input.add({
        'type': 'function_call_output',
        'call_id': part['tool_use_id'] ?? '',
        'output': _chatContentToText(part['content']),
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

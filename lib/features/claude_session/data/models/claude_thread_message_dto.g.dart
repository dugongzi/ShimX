// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_thread_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClaudeThreadMessageDto _$ClaudeThreadMessageDtoFromJson(
  Map<String, dynamic> json,
) => _ClaudeThreadMessageDto(
  index: (json['index'] as num?)?.toInt() ?? 0,
  timestamp: json['timestamp'] as String? ?? '',
  role: json['role'] as String? ?? '',
  kind: json['kind'] as String? ?? 'text',
  text: json['text'] as String? ?? '',
  toolName: json['toolName'] as String? ?? '',
);

Map<String, dynamic> _$ClaudeThreadMessageDtoToJson(
  _ClaudeThreadMessageDto instance,
) => <String, dynamic>{
  'index': instance.index,
  'timestamp': instance.timestamp,
  'role': instance.role,
  'kind': instance.kind,
  'text': instance.text,
  'toolName': instance.toolName,
};

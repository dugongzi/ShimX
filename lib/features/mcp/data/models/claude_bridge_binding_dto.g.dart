// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_bridge_binding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClaudeBridgeBindingDto _$ClaudeBridgeBindingDtoFromJson(
  Map<String, dynamic> json,
) => _ClaudeBridgeBindingDto(
  codexThreadId: json['codexThreadId'] as String,
  sessionId: json['sessionId'] as String? ?? '',
  jsonlPath: json['jsonlPath'] as String? ?? '',
  title: json['title'] as String?,
);

Map<String, dynamic> _$ClaudeBridgeBindingDtoToJson(
  _ClaudeBridgeBindingDto instance,
) => <String, dynamic>{
  'codexThreadId': instance.codexThreadId,
  'sessionId': instance.sessionId,
  'jsonlPath': instance.jsonlPath,
  'title': instance.title,
};

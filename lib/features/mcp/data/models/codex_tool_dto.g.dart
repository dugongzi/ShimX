// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_tool_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexToolDto _$CodexToolDtoFromJson(Map<String, dynamic> json) =>
    _CodexToolDto(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? CodexToolKind.mcpServer,
      bodyText: json['bodyText'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      managedByShim: json['managedByShim'] as bool? ?? false,
      readOnly: json['readOnly'] as bool? ?? true,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CodexToolDtoToJson(_CodexToolDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'bodyText': instance.bodyText,
      'enabled': instance.enabled,
      'managedByShim': instance.managedByShim,
      'readOnly': instance.readOnly,
      'name': instance.name,
      'description': instance.description,
    };

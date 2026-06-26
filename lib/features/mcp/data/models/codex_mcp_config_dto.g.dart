// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_mcp_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexMcpConfigDto _$CodexMcpConfigDtoFromJson(Map<String, dynamic> json) =>
    _CodexMcpConfigDto(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? CodexMcpConfigKind.mcpServer,
      bodyText: json['bodyText'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      managedByShim: json['managedByShim'] as bool? ?? false,
      readOnly: json['readOnly'] as bool? ?? true,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CodexMcpConfigDtoToJson(_CodexMcpConfigDto instance) =>
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

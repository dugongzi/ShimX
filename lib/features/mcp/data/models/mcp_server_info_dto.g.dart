// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_McpServerInfoDto _$McpServerInfoDtoFromJson(Map<String, dynamic> json) =>
    _McpServerInfoDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      status: json['status'] as String? ?? 'stopped',
      statusDetail: json['statusDetail'] as String? ?? '',
      toolCount: (json['toolCount'] as num?)?.toInt() ?? 0,
      registeredInCodex: json['registeredInCodex'] as bool? ?? false,
    );

Map<String, dynamic> _$McpServerInfoDtoToJson(_McpServerInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'status': instance.status,
      'statusDetail': instance.statusDetail,
      'toolCount': instance.toolCount,
      'registeredInCodex': instance.registeredInCodex,
    };

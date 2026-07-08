// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_script_catalog_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteScriptCatalogDto _$RemoteScriptCatalogDtoFromJson(
  Map<String, dynamic> json,
) => _RemoteScriptCatalogDto(
  version: (json['version'] as num?)?.toInt() ?? 1,
  updatedAt: json['updatedAt'] as String? ?? '',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RemoteScriptDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RemoteScriptCatalogDtoToJson(
  _RemoteScriptCatalogDto instance,
) => <String, dynamic>{
  'version': instance.version,
  'updatedAt': instance.updatedAt,
  'items': instance.items,
};

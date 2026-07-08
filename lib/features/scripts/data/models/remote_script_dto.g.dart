// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_script_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteScriptDto _$RemoteScriptDtoFromJson(Map<String, dynamic> json) =>
    _RemoteScriptDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      version: json['version'] as String? ?? '',
      author: json['author'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      sha256: json['sha256'] as String? ?? '',
    );

Map<String, dynamic> _$RemoteScriptDtoToJson(_RemoteScriptDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'version': instance.version,
      'author': instance.author,
      'fileName': instance.fileName,
      'downloadUrl': instance.downloadUrl,
      'sha256': instance.sha256,
    };

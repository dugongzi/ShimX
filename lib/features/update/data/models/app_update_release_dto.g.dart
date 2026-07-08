// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_release_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUpdateReleaseDto _$AppUpdateReleaseDtoFromJson(Map<String, dynamic> json) =>
    _AppUpdateReleaseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      version: json['version'] as String? ?? '',
      versionCode: (json['versionCode'] as num?)?.toInt() ?? 0,
      system: json['system'] as String? ?? '',
      changelog: json['changelog'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      minSupportedVersion: json['minSupportedVersion'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      sha256: json['sha256'] as String? ?? '',
      status: json['status'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$AppUpdateReleaseDtoToJson(
  _AppUpdateReleaseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'version': instance.version,
  'versionCode': instance.versionCode,
  'system': instance.system,
  'changelog': instance.changelog,
  'downloadUrl': instance.downloadUrl,
  'forceUpdate': instance.forceUpdate,
  'minSupportedVersion': instance.minSupportedVersion,
  'fileSize': instance.fileSize,
  'sha256': instance.sha256,
  'status': instance.status,
  'publishedAt': instance.publishedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

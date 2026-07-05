// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_bucket_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexBucketDto _$CodexBucketDtoFromJson(Map<String, dynamic> json) =>
    _CodexBucketDto(
      bucket: json['bucket'] as String? ?? '',
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
      lastActiveMs: (json['lastActiveMs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CodexBucketDtoToJson(_CodexBucketDto instance) =>
    <String, dynamic>{
      'bucket': instance.bucket,
      'sessionCount': instance.sessionCount,
      'lastActiveMs': instance.lastActiveMs,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_backup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexBackupDto _$CodexBackupDtoFromJson(Map<String, dynamic> json) =>
    _CodexBackupDto(
      backupId: json['backupId'] as String? ?? '',
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      threadCount: (json['threadCount'] as num?)?.toInt() ?? 0,
      originalProviders:
          (json['originalProviders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CodexBackupDtoToJson(_CodexBackupDto instance) =>
    <String, dynamic>{
      'backupId': instance.backupId,
      'createdAtMs': instance.createdAtMs,
      'threadCount': instance.threadCount,
      'originalProviders': instance.originalProviders,
    };

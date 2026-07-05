// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_backup_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexBackupDetailDto _$CodexBackupDetailDtoFromJson(
  Map<String, dynamic> json,
) => _CodexBackupDetailDto(
  backupId: json['backupId'] as String? ?? '',
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => CodexBackupEntryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CodexBackupEntryDto>[],
);

Map<String, dynamic> _$CodexBackupDetailDtoToJson(
  _CodexBackupDetailDto instance,
) => <String, dynamic>{
  'backupId': instance.backupId,
  'createdAtMs': instance.createdAtMs,
  'entries': instance.entries,
};

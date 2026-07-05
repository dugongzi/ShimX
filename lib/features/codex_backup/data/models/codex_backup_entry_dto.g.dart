// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_backup_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexBackupEntryDto _$CodexBackupEntryDtoFromJson(Map<String, dynamic> json) =>
    _CodexBackupEntryDto(
      threadId: json['threadId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cwd: json['cwd'] as String? ?? '',
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
      originalProvider: json['originalProvider'] as String? ?? '',
      jsonlFilename: json['jsonlFilename'] as String? ?? '',
    );

Map<String, dynamic> _$CodexBackupEntryDtoToJson(
  _CodexBackupEntryDto instance,
) => <String, dynamic>{
  'threadId': instance.threadId,
  'title': instance.title,
  'cwd': instance.cwd,
  'updatedAtMs': instance.updatedAtMs,
  'originalProvider': instance.originalProvider,
  'jsonlFilename': instance.jsonlFilename,
};

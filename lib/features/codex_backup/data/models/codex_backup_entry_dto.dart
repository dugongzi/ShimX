import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shim/features/codex_backup/domain/models/codex_backup_entry.dart';

part 'codex_backup_entry_dto.freezed.dart';
part 'codex_backup_entry_dto.g.dart';

@freezed
abstract class CodexBackupEntryDto with _$CodexBackupEntryDto {
  const CodexBackupEntryDto._();

  const factory CodexBackupEntryDto({
    @Default('') String threadId,
    @Default('') String title,
    @Default('') String cwd,
    @Default(0) int updatedAtMs,
    @Default('') String originalProvider,
    @Default('') String jsonlFilename,
  }) = _CodexBackupEntryDto;

  factory CodexBackupEntryDto.fromJson(Map<String, dynamic> json) =>
      _$CodexBackupEntryDtoFromJson(json);

  CodexBackupEntry toEntity() => CodexBackupEntry(
        threadId: threadId,
        title: title,
        cwd: cwd,
        updatedAtMs: updatedAtMs,
        originalProvider: originalProvider,
        jsonlFilename: jsonlFilename,
      );
}

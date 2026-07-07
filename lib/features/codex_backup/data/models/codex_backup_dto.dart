import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shimx/features/codex_backup/domain/models/codex_backup.dart';

part 'codex_backup_dto.freezed.dart';
part 'codex_backup_dto.g.dart';

@freezed
abstract class CodexBackupDto with _$CodexBackupDto {
  const CodexBackupDto._();

  const factory CodexBackupDto({
    @Default('') String backupId,
    @Default(0) int createdAtMs,
    @Default(0) int threadCount,
    @Default(<String>[]) List<String> originalProviders,
  }) = _CodexBackupDto;

  factory CodexBackupDto.fromJson(Map<String, dynamic> json) =>
      _$CodexBackupDtoFromJson(json);

  CodexBackup toEntity() => CodexBackup(
        backupId: backupId,
        createdAtMs: createdAtMs,
        threadCount: threadCount,
        originalProviders: originalProviders,
      );
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shimx/features/codex_backup/data/models/codex_backup_entry_dto.dart';
import 'package:shimx/features/codex_backup/domain/models/codex_backup_detail.dart';

part 'codex_backup_detail_dto.freezed.dart';
part 'codex_backup_detail_dto.g.dart';

@freezed
abstract class CodexBackupDetailDto with _$CodexBackupDetailDto {
  const CodexBackupDetailDto._();

  const factory CodexBackupDetailDto({
    @Default('') String backupId,
    @Default(0) int createdAtMs,
    @Default(<CodexBackupEntryDto>[]) List<CodexBackupEntryDto> entries,
  }) = _CodexBackupDetailDto;

  factory CodexBackupDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CodexBackupDetailDtoFromJson(json);

  CodexBackupDetail toEntity() => CodexBackupDetail(
        backupId: backupId,
        createdAtMs: createdAtMs,
        entries: entries.map((e) => e.toEntity()).toList(),
      );
}

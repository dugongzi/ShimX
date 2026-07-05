import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shim/features/codex_backup/domain/models/codex_backup_entry.dart';

part 'codex_backup_detail.freezed.dart';

@freezed
abstract class CodexBackupDetail with _$CodexBackupDetail {
  const CodexBackupDetail._();

  const factory CodexBackupDetail({
    required String backupId,
    required int createdAtMs,
    required List<CodexBackupEntry> entries,
  }) = _CodexBackupDetail;
}

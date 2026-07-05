import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_backup_entry.freezed.dart';

/// 单条被备份的会话元信息。UI 展开备份详情时展示。
@freezed
abstract class CodexBackupEntry with _$CodexBackupEntry {
  const CodexBackupEntry._();

  const factory CodexBackupEntry({
    required String threadId,
    required String title,
    required String cwd,
    required int updatedAtMs,
    required String originalProvider,
    required String jsonlFilename,
  }) = _CodexBackupEntry;
}

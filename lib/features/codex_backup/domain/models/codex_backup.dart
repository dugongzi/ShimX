import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_backup.freezed.dart';

/// 备份库列表条目。同一次「备份选中」产生一条,包含时间戳 + 条数 + 涉及的原桶列表。
@freezed
abstract class CodexBackup with _$CodexBackup {
  const CodexBackup._();

  const factory CodexBackup({
    required String backupId,
    required int createdAtMs,
    required int threadCount,
    required List<String> originalProviders,
  }) = _CodexBackup;
}

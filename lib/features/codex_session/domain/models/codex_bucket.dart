import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_bucket.freezed.dart';

/// codex threads 表按 `model_provider` 分组后的桶。
///
/// `bucket` 直接用 `model_provider` 字段字符串;空/null 归一到空串。
@freezed
abstract class CodexBucket with _$CodexBucket {
  const CodexBucket._();

  const factory CodexBucket({
    required String bucket,
    required int sessionCount,
    required int lastActiveMs,
  }) = _CodexBucket;
}

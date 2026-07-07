import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shimx/features/codex_session/domain/models/codex_bucket.dart';

part 'codex_bucket_dto.freezed.dart';
part 'codex_bucket_dto.g.dart';

@freezed
abstract class CodexBucketDto with _$CodexBucketDto {
  const CodexBucketDto._();

  const factory CodexBucketDto({
    @Default('') String bucket,
    @Default(0) int sessionCount,
    @Default(0) int lastActiveMs,
  }) = _CodexBucketDto;

  factory CodexBucketDto.fromJson(Map<String, dynamic> json) =>
      _$CodexBucketDtoFromJson(json);

  CodexBucket toEntity() => CodexBucket(
        bucket: bucket,
        sessionCount: sessionCount,
        lastActiveMs: lastActiveMs,
      );
}

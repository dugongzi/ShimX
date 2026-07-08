import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';

part 'app_update_release_dto.freezed.dart';
part 'app_update_release_dto.g.dart';

@freezed
abstract class AppUpdateReleaseDto with _$AppUpdateReleaseDto {
  const AppUpdateReleaseDto._();

  const factory AppUpdateReleaseDto({
    @Default(0) int id,
    @Default('') String version,
    @Default(0) int versionCode,
    @Default('') String system,
    @Default('') String changelog,
    @Default('') String downloadUrl,
    @Default(false) bool forceUpdate,
    @Default('') String minSupportedVersion,
    @Default(0) int fileSize,
    @Default('') String sha256,
    @Default('') String status,
    @Default('') String publishedAt,
    @Default('') String createdAt,
    @Default('') String updatedAt,
  }) = _AppUpdateReleaseDto;

  factory AppUpdateReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$AppUpdateReleaseDtoFromJson(json);

  AppUpdateRelease toEntity() {
    return AppUpdateRelease(
      id: id,
      version: version,
      versionCode: versionCode,
      system: AppUpdateSystem.fromCode(system) ?? AppUpdateSystem.win,
      changelog: changelog,
      downloadUrl: downloadUrl,
      forceUpdate: forceUpdate,
      minSupportedVersion: minSupportedVersion,
      fileSize: fileSize,
      sha256: sha256,
      status: status,
      publishedAt: _parseDate(publishedAt),
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
    );
  }
}

DateTime _parseDate(String value) {
  if (value.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
  return DateTime.tryParse(value)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

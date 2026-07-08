import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';

part 'app_update_release.freezed.dart';

/// 后台发布的一条客户端版本记录。
@freezed
abstract class AppUpdateRelease with _$AppUpdateRelease {
  const AppUpdateRelease._();

  const factory AppUpdateRelease({
    required int id,
    required String version,
    required int versionCode,
    required AppUpdateSystem system,
    required String changelog,
    required String downloadUrl,
    required bool forceUpdate,
    required String minSupportedVersion,
    required int fileSize,
    required String sha256,
    required String status,
    required DateTime publishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUpdateRelease;

  bool get canDownload => downloadUrl.trim().isNotEmpty;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';

part 'app_update_check.freezed.dart';

/// 当前客户端和后台最新版本的对比结果。
@freezed
abstract class AppUpdateCheck with _$AppUpdateCheck {
  const AppUpdateCheck._();

  const factory AppUpdateCheck({
    required bool hasUpdate,
    required String currentVersion,
    required String latestVersion,
    required AppUpdateSystem system,
    required AppUpdateRelease item,
  }) = _AppUpdateCheck;

  bool get canDownload => hasUpdate && item.canDownload;
}

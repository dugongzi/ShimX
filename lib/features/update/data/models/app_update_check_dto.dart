import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/update/data/models/app_update_release_dto.dart';
import 'package:shimx/features/update/domain/models/app_update_check.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';

part 'app_update_check_dto.freezed.dart';
part 'app_update_check_dto.g.dart';

@freezed
abstract class AppUpdateCheckDto with _$AppUpdateCheckDto {
  const AppUpdateCheckDto._();

  const factory AppUpdateCheckDto({
    @Default(false) bool hasUpdate,
    @Default('') String currentVersion,
    @Default('') String latestVersion,
    @Default(AppUpdateReleaseDto()) AppUpdateReleaseDto item,
  }) = _AppUpdateCheckDto;

  factory AppUpdateCheckDto.fromJson(Map<String, dynamic> json) =>
      _$AppUpdateCheckDtoFromJson(json);

  AppUpdateCheck toEntity(AppUpdateSystem system) {
    return AppUpdateCheck(
      hasUpdate: hasUpdate,
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      system: system,
      item: item.toEntity(),
    );
  }
}

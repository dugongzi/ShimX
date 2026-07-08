// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_check_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUpdateCheckDto _$AppUpdateCheckDtoFromJson(Map<String, dynamic> json) =>
    _AppUpdateCheckDto(
      hasUpdate: json['hasUpdate'] as bool? ?? false,
      currentVersion: json['currentVersion'] as String? ?? '',
      latestVersion: json['latestVersion'] as String? ?? '',
      item: json['item'] == null
          ? const AppUpdateReleaseDto()
          : AppUpdateReleaseDto.fromJson(json['item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppUpdateCheckDtoToJson(_AppUpdateCheckDto instance) =>
    <String, dynamic>{
      'hasUpdate': instance.hasUpdate,
      'currentVersion': instance.currentVersion,
      'latestVersion': instance.latestVersion,
      'item': instance.item,
    };

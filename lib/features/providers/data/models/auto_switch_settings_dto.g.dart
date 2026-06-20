// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_switch_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutoSwitchSettingsDto _$AutoSwitchSettingsDtoFromJson(
  Map<String, dynamic> json,
) => _AutoSwitchSettingsDto(
  strategy: json['strategy'] as String? ?? 'manual',
  scope: json['scope'] as String? ?? 'same-type',
  failureThreshold: (json['failureThreshold'] as num?)?.toInt() ?? 3,
  fastestMarginMs: (json['fastestMarginMs'] as num?)?.toInt() ?? 200,
  cooldownSeconds: (json['cooldownSeconds'] as num?)?.toInt() ?? 10,
  probeIntervalSeconds: (json['probeIntervalSeconds'] as num?)?.toInt() ?? 300,
);

Map<String, dynamic> _$AutoSwitchSettingsDtoToJson(
  _AutoSwitchSettingsDto instance,
) => <String, dynamic>{
  'strategy': instance.strategy,
  'scope': instance.scope,
  'failureThreshold': instance.failureThreshold,
  'fastestMarginMs': instance.fastestMarginMs,
  'cooldownSeconds': instance.cooldownSeconds,
  'probeIntervalSeconds': instance.probeIntervalSeconds,
};

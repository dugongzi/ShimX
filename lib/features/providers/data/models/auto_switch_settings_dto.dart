import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';

part 'auto_switch_settings_dto.freezed.dart';
part 'auto_switch_settings_dto.g.dart';

@freezed
abstract class AutoSwitchSettingsDto with _$AutoSwitchSettingsDto {
  const AutoSwitchSettingsDto._();

  const factory AutoSwitchSettingsDto({
    @Default('manual') String strategy,
    @Default('same-type') String scope,
    @Default(3) int failureThreshold,
    @Default(200) int fastestMarginMs,
    @Default(10) int cooldownSeconds,
    @Default(300) int probeIntervalSeconds,
    @Default(20) int slowRequestTimeoutSeconds,
    @Default(1) int slowRequestSwitchThreshold,
  }) = _AutoSwitchSettingsDto;

  factory AutoSwitchSettingsDto.fromJson(Map<String, Object?> json) =>
      _$AutoSwitchSettingsDtoFromJson(json);

  factory AutoSwitchSettingsDto.fromEntity(AutoSwitchSettings entity) {
    return AutoSwitchSettingsDto(
      strategy: entity.strategy,
      scope: entity.scope,
      failureThreshold: entity.failureThreshold,
      fastestMarginMs: entity.fastestMarginMs,
      cooldownSeconds: entity.cooldownSeconds,
      probeIntervalSeconds: entity.probeIntervalSeconds,
      slowRequestTimeoutSeconds: entity.slowRequestTimeoutSeconds,
      slowRequestSwitchThreshold: entity.slowRequestSwitchThreshold,
    );
  }

  AutoSwitchSettings toEntity() {
    return AutoSwitchSettings(
      strategy: strategy,
      scope: scope,
      failureThreshold: failureThreshold,
      fastestMarginMs: fastestMarginMs,
      cooldownSeconds: cooldownSeconds,
      probeIntervalSeconds: probeIntervalSeconds,
      slowRequestTimeoutSeconds: slowRequestTimeoutSeconds,
      slowRequestSwitchThreshold: slowRequestSwitchThreshold,
    );
  }
}

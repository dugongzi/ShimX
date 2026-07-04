import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shim/features/plugins/domain/models/plugin_marketplace_status.dart';

part 'plugin_marketplace_status_dto.freezed.dart';
part 'plugin_marketplace_status_dto.g.dart';

@freezed
abstract class PluginMarketplaceStatusDto with _$PluginMarketplaceStatusDto {
  const PluginMarketplaceStatusDto._();

  const factory PluginMarketplaceStatusDto({
    @Default(false) bool installed,
    @Default(false) bool configured,
    @Default(0) int pluginCount,
    @Default('') String codexHome,
  }) = _PluginMarketplaceStatusDto;

  factory PluginMarketplaceStatusDto.fromJson(Map<String, dynamic> json) =>
      _$PluginMarketplaceStatusDtoFromJson(json);

  PluginMarketplaceStatus toEntity() => PluginMarketplaceStatus(
        installed: installed,
        configured: configured,
        pluginCount: pluginCount,
        codexHome: codexHome,
      );
}

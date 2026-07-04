// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_marketplace_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PluginMarketplaceStatusDto _$PluginMarketplaceStatusDtoFromJson(
  Map<String, dynamic> json,
) => _PluginMarketplaceStatusDto(
  installed: json['installed'] as bool? ?? false,
  configured: json['configured'] as bool? ?? false,
  pluginCount: (json['pluginCount'] as num?)?.toInt() ?? 0,
  codexHome: json['codexHome'] as String? ?? '',
);

Map<String, dynamic> _$PluginMarketplaceStatusDtoToJson(
  _PluginMarketplaceStatusDto instance,
) => <String, dynamic>{
  'installed': instance.installed,
  'configured': instance.configured,
  'pluginCount': instance.pluginCount,
  'codexHome': instance.codexHome,
};

import 'package:freezed_annotation/freezed_annotation.dart';

part 'plugin_marketplace_status.freezed.dart';

/// codex 官方 curated 插件 marketplace 的当前状态。
///
/// - [installed]: `<codex_home>/.tmp/plugins/.agents/plugins/marketplace.json` 存在
/// - [configured]: `<codex_home>/config.toml` 里 3 个 marketplace 段都指向本地目录
/// - [pluginCount]: 本地目录 `plugins/*` 下带合法 `.codex-plugin/plugin.json` 的目录数
/// - [codexHome]: 本次解析出来的 codex 主目录(便于 UI 展示 / 排错)
@freezed
abstract class PluginMarketplaceStatus with _$PluginMarketplaceStatus {
  const PluginMarketplaceStatus._();

  const factory PluginMarketplaceStatus({
    required bool installed,
    required bool configured,
    required int pluginCount,
    required String codexHome,
  }) = _PluginMarketplaceStatus;
}

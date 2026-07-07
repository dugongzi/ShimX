// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_bridge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 注册 codex 页面「插件解锁」浮层用到的 bridge 路由。
///
/// - `/plugin/status`              → 读磁盘 + config,返回 marketplace 状态
/// - `/plugin/install-from-github` → 拉 openai/plugins zip,落盘 + 写 config
/// - `/plugin/install-from-local`  → 用户传 `zipPath` 或 `dirPath`,落盘 + 写 config
///
/// GitHub 下载期间通过 [BridgeService.dispatchEvent] 主动推
/// `/plugin/download-progress` 事件,JS 侧用 `window.__shimxOn` 订阅。

@ProviderFor(pluginBridgeRouteRegistration)
const pluginBridgeRouteRegistrationProvider =
    PluginBridgeRouteRegistrationProvider._();

/// 注册 codex 页面「插件解锁」浮层用到的 bridge 路由。
///
/// - `/plugin/status`              → 读磁盘 + config,返回 marketplace 状态
/// - `/plugin/install-from-github` → 拉 openai/plugins zip,落盘 + 写 config
/// - `/plugin/install-from-local`  → 用户传 `zipPath` 或 `dirPath`,落盘 + 写 config
///
/// GitHub 下载期间通过 [BridgeService.dispatchEvent] 主动推
/// `/plugin/download-progress` 事件,JS 侧用 `window.__shimxOn` 订阅。

final class PluginBridgeRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册 codex 页面「插件解锁」浮层用到的 bridge 路由。
  ///
  /// - `/plugin/status`              → 读磁盘 + config,返回 marketplace 状态
  /// - `/plugin/install-from-github` → 拉 openai/plugins zip,落盘 + 写 config
  /// - `/plugin/install-from-local`  → 用户传 `zipPath` 或 `dirPath`,落盘 + 写 config
  ///
  /// GitHub 下载期间通过 [BridgeService.dispatchEvent] 主动推
  /// `/plugin/download-progress` 事件,JS 侧用 `window.__shimxOn` 订阅。
  const PluginBridgeRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginBridgeRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginBridgeRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return pluginBridgeRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pluginBridgeRouteRegistrationHash() =>
    r'60d49bdf3df1726112cbf1f4aa9328546cf2d84e';

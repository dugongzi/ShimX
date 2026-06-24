// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_bridge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 注册 Claude 桥控制路由:
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为接续上下文,
///                          后续每次代理转发都会在 input 首部插一条 system message
/// `/claude-bridge/unbind` — 解绑
/// `/claude-bridge/state`  — 读当前绑定(JS 侧用来初始化 chip)
///
/// 数据存在 [LocalProxyService] 的 [LocalProxyService.claudeBinding],
/// 单例,全局只能绑一条。

@ProviderFor(claudeBridgeRouteRegistration)
const claudeBridgeRouteRegistrationProvider =
    ClaudeBridgeRouteRegistrationProvider._();

/// 注册 Claude 桥控制路由:
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为接续上下文,
///                          后续每次代理转发都会在 input 首部插一条 system message
/// `/claude-bridge/unbind` — 解绑
/// `/claude-bridge/state`  — 读当前绑定(JS 侧用来初始化 chip)
///
/// 数据存在 [LocalProxyService] 的 [LocalProxyService.claudeBinding],
/// 单例,全局只能绑一条。

final class ClaudeBridgeRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册 Claude 桥控制路由:
  ///
  /// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为接续上下文,
  ///                          后续每次代理转发都会在 input 首部插一条 system message
  /// `/claude-bridge/unbind` — 解绑
  /// `/claude-bridge/state`  — 读当前绑定(JS 侧用来初始化 chip)
  ///
  /// 数据存在 [LocalProxyService] 的 [LocalProxyService.claudeBinding],
  /// 单例,全局只能绑一条。
  const ClaudeBridgeRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeBridgeRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeBridgeRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return claudeBridgeRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$claudeBridgeRouteRegistrationHash() =>
    r'9a726b9326dce723a82ad53404b74268964a0030';

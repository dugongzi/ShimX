// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_bridge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 注册 Claude 桥控制路由。
///
/// 绑定按 codex thread id 隔离 —— codex 侧栏每条对话各自有一个 Claude 桥状态。
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为当前 codex thread 的接续上下文
/// `/claude-bridge/unbind` — 解除当前 codex thread 的绑定
/// `/claude-bridge/state`  — 读某个 codex thread 的绑定状态(JS chip 初始化用)
///
/// 数据存在 [LocalProxyService] 的 `_claudeBindings`(`Map<threadId, binding>`),
/// 仅内存态,shim 重启清空。

@ProviderFor(claudeBridgeRouteRegistration)
const claudeBridgeRouteRegistrationProvider =
    ClaudeBridgeRouteRegistrationProvider._();

/// 注册 Claude 桥控制路由。
///
/// 绑定按 codex thread id 隔离 —— codex 侧栏每条对话各自有一个 Claude 桥状态。
///
/// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为当前 codex thread 的接续上下文
/// `/claude-bridge/unbind` — 解除当前 codex thread 的绑定
/// `/claude-bridge/state`  — 读某个 codex thread 的绑定状态(JS chip 初始化用)
///
/// 数据存在 [LocalProxyService] 的 `_claudeBindings`(`Map<threadId, binding>`),
/// 仅内存态,shim 重启清空。

final class ClaudeBridgeRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册 Claude 桥控制路由。
  ///
  /// 绑定按 codex thread id 隔离 —— codex 侧栏每条对话各自有一个 Claude 桥状态。
  ///
  /// `/claude-bridge/bind`   — 绑定一条 Claude 会话作为当前 codex thread 的接续上下文
  /// `/claude-bridge/unbind` — 解除当前 codex thread 的绑定
  /// `/claude-bridge/state`  — 读某个 codex thread 的绑定状态(JS chip 初始化用)
  ///
  /// 数据存在 [LocalProxyService] 的 `_claudeBindings`(`Map<threadId, binding>`),
  /// 仅内存态,shim 重启清空。
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
    r'e71a92138fedd57f0e8614ae456ca0623115a37d';

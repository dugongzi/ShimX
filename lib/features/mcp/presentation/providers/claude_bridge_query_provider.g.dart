// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_bridge_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// query 与 action 共享同一个 controller —— 内存状态(hydrated / proxy snapshot)
/// 必须单一源,所以 keepAlive。

@ProviderFor(claudeBridgeStateController)
const claudeBridgeStateControllerProvider =
    ClaudeBridgeStateControllerProvider._();

/// query 与 action 共享同一个 controller —— 内存状态(hydrated / proxy snapshot)
/// 必须单一源,所以 keepAlive。

final class ClaudeBridgeStateControllerProvider
    extends
        $FunctionalProvider<
          ClaudeBridgeStateController,
          ClaudeBridgeStateController,
          ClaudeBridgeStateController
        >
    with $Provider<ClaudeBridgeStateController> {
  /// query 与 action 共享同一个 controller —— 内存状态(hydrated / proxy snapshot)
  /// 必须单一源,所以 keepAlive。
  const ClaudeBridgeStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeBridgeStateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeBridgeStateControllerHash();

  @$internal
  @override
  $ProviderElement<ClaudeBridgeStateController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClaudeBridgeStateController create(Ref ref) {
    return claudeBridgeStateController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaudeBridgeStateController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaudeBridgeStateController>(value),
    );
  }
}

String _$claudeBridgeStateControllerHash() =>
    r'082d22b1b97a3056655303c9aa64ec286aeab589';

@ProviderFor(claudeBridgeQueryRepository)
const claudeBridgeQueryRepositoryProvider =
    ClaudeBridgeQueryRepositoryProvider._();

final class ClaudeBridgeQueryRepositoryProvider
    extends
        $FunctionalProvider<
          ClaudeBridgeQueryRepository,
          ClaudeBridgeQueryRepository,
          ClaudeBridgeQueryRepository
        >
    with $Provider<ClaudeBridgeQueryRepository> {
  const ClaudeBridgeQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeBridgeQueryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeBridgeQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClaudeBridgeQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClaudeBridgeQueryRepository create(Ref ref) {
    return claudeBridgeQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaudeBridgeQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaudeBridgeQueryRepository>(value),
    );
  }
}

String _$claudeBridgeQueryRepositoryHash() =>
    r'b552d6a3107d2d42813b03c532f18b1b75ef9162';

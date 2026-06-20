// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providerHealthRepository)
const providerHealthRepositoryProvider = ProviderHealthRepositoryProvider._();

final class ProviderHealthRepositoryProvider
    extends
        $FunctionalProvider<
          ProviderHealthRepository,
          ProviderHealthRepository,
          ProviderHealthRepository
        >
    with $Provider<ProviderHealthRepository> {
  const ProviderHealthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerHealthRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerHealthRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProviderHealthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderHealthRepository create(Ref ref) {
    return providerHealthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderHealthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderHealthRepository>(value),
    );
  }
}

String _$providerHealthRepositoryHash() =>
    r'05d891cce4e6092568a2d51124740d6b023f7d9e';

@ProviderFor(providerHealthProbeService)
const providerHealthProbeServiceProvider =
    ProviderHealthProbeServiceProvider._();

final class ProviderHealthProbeServiceProvider
    extends
        $FunctionalProvider<
          ProviderHealthProbeService,
          ProviderHealthProbeService,
          ProviderHealthProbeService
        >
    with $Provider<ProviderHealthProbeService> {
  const ProviderHealthProbeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerHealthProbeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerHealthProbeServiceHash();

  @$internal
  @override
  $ProviderElement<ProviderHealthProbeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderHealthProbeService create(Ref ref) {
    return providerHealthProbeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderHealthProbeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderHealthProbeService>(value),
    );
  }
}

String _$providerHealthProbeServiceHash() =>
    r'77707991f060a8be547997a26ae61341484ffbcb';

/// 订阅式快照，给 UI 用。

@ProviderFor(providerHealthStream)
const providerHealthStreamProvider = ProviderHealthStreamProvider._();

/// 订阅式快照，给 UI 用。

final class ProviderHealthStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, ProviderHealth>>,
          Map<String, ProviderHealth>,
          Stream<Map<String, ProviderHealth>>
        >
    with
        $FutureModifier<Map<String, ProviderHealth>>,
        $StreamProvider<Map<String, ProviderHealth>> {
  /// 订阅式快照，给 UI 用。
  const ProviderHealthStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerHealthStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerHealthStreamHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, ProviderHealth>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, ProviderHealth>> create(Ref ref) {
    return providerHealthStream(ref);
  }
}

String _$providerHealthStreamHash() =>
    r'48e8daf5706fbec6752f6d9e5e936a5cb167a4d8';

/// 把测速相关路由注册到 bridge。注入时 watch 一次让它生效。
///
/// /provider/health/refresh — 触发一次按需测速。
///   payload.id    指定测哪家;不传 = 测当前选中那家(默认行为,最省请求)
///   payload.scope 'selected' (默认) | 'all' (用户主动点"刷新全部"才传)
///   payload.force 跳过 60s cooldown(用户手动刷新才传)

@ProviderFor(providerHealthRouteRegistration)
const providerHealthRouteRegistrationProvider =
    ProviderHealthRouteRegistrationProvider._();

/// 把测速相关路由注册到 bridge。注入时 watch 一次让它生效。
///
/// /provider/health/refresh — 触发一次按需测速。
///   payload.id    指定测哪家;不传 = 测当前选中那家(默认行为,最省请求)
///   payload.scope 'selected' (默认) | 'all' (用户主动点"刷新全部"才传)
///   payload.force 跳过 60s cooldown(用户手动刷新才传)

final class ProviderHealthRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把测速相关路由注册到 bridge。注入时 watch 一次让它生效。
  ///
  /// /provider/health/refresh — 触发一次按需测速。
  ///   payload.id    指定测哪家;不传 = 测当前选中那家(默认行为,最省请求)
  ///   payload.scope 'selected' (默认) | 'all' (用户主动点"刷新全部"才传)
  ///   payload.force 跳过 60s cooldown(用户手动刷新才传)
  const ProviderHealthRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerHealthRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerHealthRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return providerHealthRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$providerHealthRouteRegistrationHash() =>
    r'295f0124ad842b3beb7fef2589d62d09a6decac4';

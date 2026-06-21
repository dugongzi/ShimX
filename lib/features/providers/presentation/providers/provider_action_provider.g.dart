// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providerActionRepository)
const providerActionRepositoryProvider = ProviderActionRepositoryProvider._();

final class ProviderActionRepositoryProvider
    extends
        $FunctionalProvider<
          ProviderActionRepository,
          ProviderActionRepository,
          ProviderActionRepository
        >
    with $Provider<ProviderActionRepository> {
  const ProviderActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProviderActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderActionRepository create(Ref ref) {
    return providerActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderActionRepository>(value),
    );
  }
}

String _$providerActionRepositoryHash() =>
    r'52fae25a25078a67d38c0aadcd1c47b3610796bd';

/// 注册 JS 侧供应商/模型选择路由。
///
/// 通过 @Riverpod(keepAlive: true) 包一层 provider,任何持有 Ref 或 WidgetRef
/// 的地方都可以 `ref.read(providerActionRouteRegistrationProvider)` 触发注册。

@ProviderFor(providerActionRouteRegistration)
const providerActionRouteRegistrationProvider =
    ProviderActionRouteRegistrationProvider._();

/// 注册 JS 侧供应商/模型选择路由。
///
/// 通过 @Riverpod(keepAlive: true) 包一层 provider,任何持有 Ref 或 WidgetRef
/// 的地方都可以 `ref.read(providerActionRouteRegistrationProvider)` 触发注册。

final class ProviderActionRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册 JS 侧供应商/模型选择路由。
  ///
  /// 通过 @Riverpod(keepAlive: true) 包一层 provider,任何持有 Ref 或 WidgetRef
  /// 的地方都可以 `ref.read(providerActionRouteRegistrationProvider)` 触发注册。
  const ProviderActionRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerActionRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerActionRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return providerActionRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$providerActionRouteRegistrationHash() =>
    r'6cf01c8d5d2bf6a95ee3d9f0e2e88ba3acdea05f';

/// 供应商相关写操作的命令面板。
///
/// 用 Notifier 而不是一堆 family-Future provider:
/// - family-Future provider 按参数缓存(`addProviderProvider(provider: X)` 算一个 key),
///   同 key 第二次 `ref.read(...future)` 拿到的是上次的 completed Future,根本不重跑。
/// - 没人 watch 时 family 会被 auto-dispose,正在跑的 await 后续用 ref 直接抛
///   "Cannot use the Ref ... after it has been disposed"。
/// - Notifier 是单例 + keepAlive,方法每次调用都重新执行,没有缓存复用问题,
///   ref 也不会在异步 gap 后被销毁。

@ProviderFor(ProviderActions)
const providerActionsProvider = ProviderActionsProvider._();

/// 供应商相关写操作的命令面板。
///
/// 用 Notifier 而不是一堆 family-Future provider:
/// - family-Future provider 按参数缓存(`addProviderProvider(provider: X)` 算一个 key),
///   同 key 第二次 `ref.read(...future)` 拿到的是上次的 completed Future,根本不重跑。
/// - 没人 watch 时 family 会被 auto-dispose,正在跑的 await 后续用 ref 直接抛
///   "Cannot use the Ref ... after it has been disposed"。
/// - Notifier 是单例 + keepAlive,方法每次调用都重新执行,没有缓存复用问题,
///   ref 也不会在异步 gap 后被销毁。
final class ProviderActionsProvider
    extends $NotifierProvider<ProviderActions, void> {
  /// 供应商相关写操作的命令面板。
  ///
  /// 用 Notifier 而不是一堆 family-Future provider:
  /// - family-Future provider 按参数缓存(`addProviderProvider(provider: X)` 算一个 key),
  ///   同 key 第二次 `ref.read(...future)` 拿到的是上次的 completed Future,根本不重跑。
  /// - 没人 watch 时 family 会被 auto-dispose,正在跑的 await 后续用 ref 直接抛
  ///   "Cannot use the Ref ... after it has been disposed"。
  /// - Notifier 是单例 + keepAlive,方法每次调用都重新执行,没有缓存复用问题,
  ///   ref 也不会在异步 gap 后被销毁。
  const ProviderActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerActionsHash();

  @$internal
  @override
  ProviderActions create() => ProviderActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$providerActionsHash() => r'a0fd17bd2677a74878606206efdb800e1bbbc1a4';

/// 供应商相关写操作的命令面板。
///
/// 用 Notifier 而不是一堆 family-Future provider:
/// - family-Future provider 按参数缓存(`addProviderProvider(provider: X)` 算一个 key),
///   同 key 第二次 `ref.read(...future)` 拿到的是上次的 completed Future,根本不重跑。
/// - 没人 watch 时 family 会被 auto-dispose,正在跑的 await 后续用 ref 直接抛
///   "Cannot use the Ref ... after it has been disposed"。
/// - Notifier 是单例 + keepAlive,方法每次调用都重新执行,没有缓存复用问题,
///   ref 也不会在异步 gap 后被销毁。

abstract class _$ProviderActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。

@ProviderFor(proxyAutoStart)
const proxyAutoStartProvider = ProxyAutoStartProvider._();

/// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。

final class ProxyAutoStartProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
  /// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。
  const ProxyAutoStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyAutoStartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyAutoStartHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return proxyAutoStart(ref);
  }
}

String _$proxyAutoStartHash() => r'973f32c132a08a8c53a23a1c2ea3fe46ff9a1633';

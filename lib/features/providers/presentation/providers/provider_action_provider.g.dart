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

String _$providerActionsHash() => r'00d82ead20b02025e7871a11a427e0d8e891c450';

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_switch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(autoSwitchRepository)
const autoSwitchRepositoryProvider = AutoSwitchRepositoryProvider._();

final class AutoSwitchRepositoryProvider
    extends
        $FunctionalProvider<
          AutoSwitchRepository,
          AutoSwitchRepository,
          AutoSwitchRepository
        >
    with $Provider<AutoSwitchRepository> {
  const AutoSwitchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSwitchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSwitchRepositoryHash();

  @$internal
  @override
  $ProviderElement<AutoSwitchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoSwitchRepository create(Ref ref) {
    return autoSwitchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoSwitchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoSwitchRepository>(value),
    );
  }
}

String _$autoSwitchRepositoryHash() =>
    r'339fcd8fd1a6cedf5f6d61a45d60a7e4a56b92ea';

@ProviderFor(autoSwitchSettings)
const autoSwitchSettingsProvider = AutoSwitchSettingsProvider._();

final class AutoSwitchSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AutoSwitchSettings>,
          AutoSwitchSettings,
          FutureOr<AutoSwitchSettings>
        >
    with
        $FutureModifier<AutoSwitchSettings>,
        $FutureProvider<AutoSwitchSettings> {
  const AutoSwitchSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSwitchSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSwitchSettingsHash();

  @$internal
  @override
  $FutureProviderElement<AutoSwitchSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AutoSwitchSettings> create(Ref ref) {
    return autoSwitchSettings(ref);
  }
}

String _$autoSwitchSettingsHash() =>
    r'8255c996529913cca5475d32d2a08eac0f2deb9c';

@ProviderFor(autoSwitchService)
const autoSwitchServiceProvider = AutoSwitchServiceProvider._();

final class AutoSwitchServiceProvider
    extends
        $FunctionalProvider<
          AutoSwitchService,
          AutoSwitchService,
          AutoSwitchService
        >
    with $Provider<AutoSwitchService> {
  const AutoSwitchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSwitchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSwitchServiceHash();

  @$internal
  @override
  $ProviderElement<AutoSwitchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoSwitchService create(Ref ref) {
    return autoSwitchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoSwitchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoSwitchService>(value),
    );
  }
}

String _$autoSwitchServiceHash() => r'72f8d3c4a28cd86f758da3b1d814f31b48e92ab8';

/// 把自动切换路由注册到 bridge。
///
/// /auto-switch/get — 读当前设置
/// /auto-switch/set — 写设置(整份覆盖)

@ProviderFor(autoSwitchRouteRegistration)
const autoSwitchRouteRegistrationProvider =
    AutoSwitchRouteRegistrationProvider._();

/// 把自动切换路由注册到 bridge。
///
/// /auto-switch/get — 读当前设置
/// /auto-switch/set — 写设置(整份覆盖)

final class AutoSwitchRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把自动切换路由注册到 bridge。
  ///
  /// /auto-switch/get — 读当前设置
  /// /auto-switch/set — 写设置(整份覆盖)
  const AutoSwitchRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSwitchRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSwitchRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return autoSwitchRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoSwitchRouteRegistrationHash() =>
    r'aad4343244a3a6f68ca51b2b0d7cc4491adb4178';

/// 监听 health 变化 + 设置变化,自动评估切换。

@ProviderFor(autoSwitchWatcher)
const autoSwitchWatcherProvider = AutoSwitchWatcherProvider._();

/// 监听 health 变化 + 设置变化,自动评估切换。

final class AutoSwitchWatcherProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 监听 health 变化 + 设置变化,自动评估切换。
  const AutoSwitchWatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSwitchWatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSwitchWatcherHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return autoSwitchWatcher(ref);
  }
}

String _$autoSwitchWatcherHash() => r'02700877bf963cc8c8ae466cb7ec18d42ee80b85';

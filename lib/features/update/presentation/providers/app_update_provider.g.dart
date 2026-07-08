// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUpdateQueryRepository)
const appUpdateQueryRepositoryProvider = AppUpdateQueryRepositoryProvider._();

final class AppUpdateQueryRepositoryProvider
    extends
        $FunctionalProvider<
          AppUpdateQueryRepository,
          AppUpdateQueryRepository,
          AppUpdateQueryRepository
        >
    with $Provider<AppUpdateQueryRepository> {
  const AppUpdateQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppUpdateQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppUpdateQueryRepository create(Ref ref) {
    return appUpdateQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateQueryRepository>(value),
    );
  }
}

String _$appUpdateQueryRepositoryHash() =>
    r'8e0b69b20dd39272b5fb69e9dde26d933a89ba05';

@ProviderFor(appUpdateActionRepository)
const appUpdateActionRepositoryProvider = AppUpdateActionRepositoryProvider._();

final class AppUpdateActionRepositoryProvider
    extends
        $FunctionalProvider<
          AppUpdateActionRepository,
          AppUpdateActionRepository,
          AppUpdateActionRepository
        >
    with $Provider<AppUpdateActionRepository> {
  const AppUpdateActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppUpdateActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppUpdateActionRepository create(Ref ref) {
    return appUpdateActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateActionRepository>(value),
    );
  }
}

String _$appUpdateActionRepositoryHash() =>
    r'e1536fedfc1e44f1843227e92bb7c6d4857efb12';

@ProviderFor(currentAppUpdateSystem)
const currentAppUpdateSystemProvider = CurrentAppUpdateSystemProvider._();

final class CurrentAppUpdateSystemProvider
    extends
        $FunctionalProvider<
          AppUpdateSystem?,
          AppUpdateSystem?,
          AppUpdateSystem?
        >
    with $Provider<AppUpdateSystem?> {
  const CurrentAppUpdateSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAppUpdateSystemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAppUpdateSystemHash();

  @$internal
  @override
  $ProviderElement<AppUpdateSystem?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppUpdateSystem? create(Ref ref) {
    return currentAppUpdateSystem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateSystem? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateSystem?>(value),
    );
  }
}

String _$currentAppUpdateSystemHash() =>
    r'aad7a32f96d07e37ad2d4921cf9fb7185f882d03';

@ProviderFor(appUpdateCheck)
const appUpdateCheckProvider = AppUpdateCheckProvider._();

final class AppUpdateCheckProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppUpdateCheck?>,
          AppUpdateCheck?,
          FutureOr<AppUpdateCheck?>
        >
    with $FutureModifier<AppUpdateCheck?>, $FutureProvider<AppUpdateCheck?> {
  const AppUpdateCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateCheckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateCheckHash();

  @$internal
  @override
  $FutureProviderElement<AppUpdateCheck?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppUpdateCheck?> create(Ref ref) {
    return appUpdateCheck(ref);
  }
}

String _$appUpdateCheckHash() => r'3168b866c23f91178f57e68387fc136a2d0b0d22';

@ProviderFor(appUpdateLogs)
const appUpdateLogsProvider = AppUpdateLogsFamily._();

final class AppUpdateLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppUpdateRelease>>,
          List<AppUpdateRelease>,
          FutureOr<List<AppUpdateRelease>>
        >
    with
        $FutureModifier<List<AppUpdateRelease>>,
        $FutureProvider<List<AppUpdateRelease>> {
  const AppUpdateLogsProvider._({
    required AppUpdateLogsFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'appUpdateLogsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appUpdateLogsHash();

  @override
  String toString() {
    return r'appUpdateLogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AppUpdateRelease>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppUpdateRelease>> create(Ref ref) {
    final argument = this.argument as bool;
    return appUpdateLogs(ref, currentSystemOnly: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AppUpdateLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appUpdateLogsHash() => r'eacf3a14904d89076d083295dabb6eab08651601';

final class AppUpdateLogsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AppUpdateRelease>>, bool> {
  const AppUpdateLogsFamily._()
    : super(
        retry: null,
        name: r'appUpdateLogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AppUpdateLogsProvider call({bool currentSystemOnly = true}) =>
      AppUpdateLogsProvider._(argument: currentSystemOnly, from: this);

  @override
  String toString() => r'appUpdateLogsProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polish_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(polishActionDatasource)
const polishActionDatasourceProvider = PolishActionDatasourceProvider._();

final class PolishActionDatasourceProvider
    extends
        $FunctionalProvider<
          PolishActionDatasource,
          PolishActionDatasource,
          PolishActionDatasource
        >
    with $Provider<PolishActionDatasource> {
  const PolishActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'polishActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$polishActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<PolishActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PolishActionDatasource create(Ref ref) {
    return polishActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolishActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolishActionDatasource>(value),
    );
  }
}

String _$polishActionDatasourceHash() =>
    r'8c5cdef5a22c7fd60ea36ceb03f6027dee2b0ef6';

@ProviderFor(polishActionRepository)
const polishActionRepositoryProvider = PolishActionRepositoryProvider._();

final class PolishActionRepositoryProvider
    extends
        $FunctionalProvider<
          PolishActionRepository,
          PolishActionRepository,
          PolishActionRepository
        >
    with $Provider<PolishActionRepository> {
  const PolishActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'polishActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$polishActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PolishActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PolishActionRepository create(Ref ref) {
    return polishActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolishActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolishActionRepository>(value),
    );
  }
}

String _$polishActionRepositoryHash() =>
    r'aff194f683a3a03fe8098b2a9d805adcfa9d925b';

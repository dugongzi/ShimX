// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_script_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteScriptQueryRepository)
const remoteScriptQueryRepositoryProvider =
    RemoteScriptQueryRepositoryProvider._();

final class RemoteScriptQueryRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteScriptQueryRepository,
          RemoteScriptQueryRepository,
          RemoteScriptQueryRepository
        >
    with $Provider<RemoteScriptQueryRepository> {
  const RemoteScriptQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteScriptQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteScriptQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteScriptQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteScriptQueryRepository create(Ref ref) {
    return remoteScriptQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteScriptQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteScriptQueryRepository>(value),
    );
  }
}

String _$remoteScriptQueryRepositoryHash() =>
    r'4729dd2d543a3cdfacf56eed81b4c6f61d4fb13c';

@ProviderFor(remoteScriptCatalog)
const remoteScriptCatalogProvider = RemoteScriptCatalogProvider._();

final class RemoteScriptCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<RemoteScriptCatalog>,
          RemoteScriptCatalog,
          FutureOr<RemoteScriptCatalog>
        >
    with
        $FutureModifier<RemoteScriptCatalog>,
        $FutureProvider<RemoteScriptCatalog> {
  const RemoteScriptCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteScriptCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteScriptCatalogHash();

  @$internal
  @override
  $FutureProviderElement<RemoteScriptCatalog> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RemoteScriptCatalog> create(Ref ref) {
    return remoteScriptCatalog(ref);
  }
}

String _$remoteScriptCatalogHash() =>
    r'ebb0a1f8ea8625465944ebc689f2efec425e3ad6';

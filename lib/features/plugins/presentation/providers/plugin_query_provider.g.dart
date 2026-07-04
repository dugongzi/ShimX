// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pluginQueryDatasource)
const pluginQueryDatasourceProvider = PluginQueryDatasourceProvider._();

final class PluginQueryDatasourceProvider
    extends
        $FunctionalProvider<
          PluginQueryDatasource,
          PluginQueryDatasource,
          PluginQueryDatasource
        >
    with $Provider<PluginQueryDatasource> {
  const PluginQueryDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginQueryDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginQueryDatasourceHash();

  @$internal
  @override
  $ProviderElement<PluginQueryDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PluginQueryDatasource create(Ref ref) {
    return pluginQueryDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PluginQueryDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PluginQueryDatasource>(value),
    );
  }
}

String _$pluginQueryDatasourceHash() =>
    r'7e9cb81e0f20cb49fdd322c6ce178861fe664a95';

@ProviderFor(pluginQueryRepository)
const pluginQueryRepositoryProvider = PluginQueryRepositoryProvider._();

final class PluginQueryRepositoryProvider
    extends
        $FunctionalProvider<
          PluginQueryRepository,
          PluginQueryRepository,
          PluginQueryRepository
        >
    with $Provider<PluginQueryRepository> {
  const PluginQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<PluginQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PluginQueryRepository create(Ref ref) {
    return pluginQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PluginQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PluginQueryRepository>(value),
    );
  }
}

String _$pluginQueryRepositoryHash() =>
    r'6396dfdca78e2bc9ee6c6dee5b98a8a56c81052b';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pluginActionDatasource)
const pluginActionDatasourceProvider = PluginActionDatasourceProvider._();

final class PluginActionDatasourceProvider
    extends
        $FunctionalProvider<
          PluginActionDatasource,
          PluginActionDatasource,
          PluginActionDatasource
        >
    with $Provider<PluginActionDatasource> {
  const PluginActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<PluginActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PluginActionDatasource create(Ref ref) {
    return pluginActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PluginActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PluginActionDatasource>(value),
    );
  }
}

String _$pluginActionDatasourceHash() =>
    r'4993a3b0c8fb65316e526bf3c7433f655121a864';

@ProviderFor(pluginActionRepository)
const pluginActionRepositoryProvider = PluginActionRepositoryProvider._();

final class PluginActionRepositoryProvider
    extends
        $FunctionalProvider<
          PluginActionRepository,
          PluginActionRepository,
          PluginActionRepository
        >
    with $Provider<PluginActionRepository> {
  const PluginActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PluginActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PluginActionRepository create(Ref ref) {
    return pluginActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PluginActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PluginActionRepository>(value),
    );
  }
}

String _$pluginActionRepositoryHash() =>
    r'bc93cd3514dacbf8a65ba105d936e000f252f150';

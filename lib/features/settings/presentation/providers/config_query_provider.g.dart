// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(configQueryRepository)
const configQueryRepositoryProvider = ConfigQueryRepositoryProvider._();

final class ConfigQueryRepositoryProvider
    extends
        $FunctionalProvider<
          ConfigQueryRepository,
          ConfigQueryRepository,
          ConfigQueryRepository
        >
    with $Provider<ConfigQueryRepository> {
  const ConfigQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConfigQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConfigQueryRepository create(Ref ref) {
    return configQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigQueryRepository>(value),
    );
  }
}

String _$configQueryRepositoryHash() =>
    r'0aa545c891010f537b840121ef43fd927bfc4c43';

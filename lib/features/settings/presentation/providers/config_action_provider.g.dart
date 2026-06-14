// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(configActionRepository)
const configActionRepositoryProvider = ConfigActionRepositoryProvider._();

final class ConfigActionRepositoryProvider
    extends
        $FunctionalProvider<
          ConfigActionRepository,
          ConfigActionRepository,
          ConfigActionRepository
        >
    with $Provider<ConfigActionRepository> {
  const ConfigActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConfigActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConfigActionRepository create(Ref ref) {
    return configActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigActionRepository>(value),
    );
  }
}

String _$configActionRepositoryHash() =>
    r'd9dd5c3f71da31bd2a737b488775901df3e9c3f5';

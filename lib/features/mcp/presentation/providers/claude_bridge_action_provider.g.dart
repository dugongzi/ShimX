// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_bridge_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(claudeBridgeActionRepository)
const claudeBridgeActionRepositoryProvider =
    ClaudeBridgeActionRepositoryProvider._();

final class ClaudeBridgeActionRepositoryProvider
    extends
        $FunctionalProvider<
          ClaudeBridgeActionRepository,
          ClaudeBridgeActionRepository,
          ClaudeBridgeActionRepository
        >
    with $Provider<ClaudeBridgeActionRepository> {
  const ClaudeBridgeActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeBridgeActionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeBridgeActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClaudeBridgeActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClaudeBridgeActionRepository create(Ref ref) {
    return claudeBridgeActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaudeBridgeActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaudeBridgeActionRepository>(value),
    );
  }
}

String _$claudeBridgeActionRepositoryHash() =>
    r'f1fe1af66fc5a90cf7ae542e26ef10fc633d56e7';

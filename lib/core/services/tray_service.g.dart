// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tray_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trayService)
const trayServiceProvider = TrayServiceProvider._();

final class TrayServiceProvider
    extends $FunctionalProvider<TrayService, TrayService, TrayService>
    with $Provider<TrayService> {
  const TrayServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayServiceHash();

  @$internal
  @override
  $ProviderElement<TrayService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrayService create(Ref ref) {
    return trayService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrayService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrayService>(value),
    );
  }
}

String _$trayServiceHash() => r'9b9dcbf48f52d6c0f255afd9aa4f20ee91e1b8a5';

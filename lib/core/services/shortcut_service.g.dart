// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shortcutService)
const shortcutServiceProvider = ShortcutServiceProvider._();

final class ShortcutServiceProvider
    extends
        $FunctionalProvider<ShortcutService, ShortcutService, ShortcutService>
    with $Provider<ShortcutService> {
  const ShortcutServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shortcutServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shortcutServiceHash();

  @$internal
  @override
  $ProviderElement<ShortcutService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShortcutService create(Ref ref) {
    return shortcutService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShortcutService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShortcutService>(value),
    );
  }
}

String _$shortcutServiceHash() => r'ad31e617b78736532fcdb469d5c555d35ae21fe8';

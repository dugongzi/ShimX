// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_args_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// app 启动时由 main(args) 通过 ProviderScope.overrides 注入。

@ProviderFor(launchArgs)
const launchArgsProvider = LaunchArgsProvider._();

/// app 启动时由 main(args) 通过 ProviderScope.overrides 注入。

final class LaunchArgsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// app 启动时由 main(args) 通过 ProviderScope.overrides 注入。
  const LaunchArgsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchArgsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchArgsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return launchArgs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$launchArgsHash() => r'f64661385608484d1a439e52550a7a0196733f23';

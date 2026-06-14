// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_launcher_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexLauncherService)
const codexLauncherServiceProvider = CodexLauncherServiceProvider._();

final class CodexLauncherServiceProvider
    extends
        $FunctionalProvider<
          CodexLauncherService,
          CodexLauncherService,
          CodexLauncherService
        >
    with $Provider<CodexLauncherService> {
  const CodexLauncherServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexLauncherServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexLauncherServiceHash();

  @$internal
  @override
  $ProviderElement<CodexLauncherService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexLauncherService create(Ref ref) {
    return codexLauncherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexLauncherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexLauncherService>(value),
    );
  }
}

String _$codexLauncherServiceHash() =>
    r'dc0e3df04bf95051dc9bf0334d7a29e03cf43683';

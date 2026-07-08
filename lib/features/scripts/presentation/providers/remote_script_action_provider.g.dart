// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_script_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteScriptActionRepository)
const remoteScriptActionRepositoryProvider =
    RemoteScriptActionRepositoryProvider._();

final class RemoteScriptActionRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteScriptActionRepository,
          RemoteScriptActionRepository,
          RemoteScriptActionRepository
        >
    with $Provider<RemoteScriptActionRepository> {
  const RemoteScriptActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteScriptActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteScriptActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteScriptActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteScriptActionRepository create(Ref ref) {
    return remoteScriptActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteScriptActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteScriptActionRepository>(value),
    );
  }
}

String _$remoteScriptActionRepositoryHash() =>
    r'888a9c8151bb31cf92146b29a85d533cd4aa8764';

@ProviderFor(installRemoteScript)
const installRemoteScriptProvider = InstallRemoteScriptFamily._();

final class InstallRemoteScriptProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const InstallRemoteScriptProvider._({
    required InstallRemoteScriptFamily super.from,
    required RemoteScript super.argument,
  }) : super(
         retry: null,
         name: r'installRemoteScriptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$installRemoteScriptHash();

  @override
  String toString() {
    return r'installRemoteScriptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as RemoteScript;
    return installRemoteScript(ref, script: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InstallRemoteScriptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$installRemoteScriptHash() =>
    r'e1440b10eed77ad62a096c088baf057e7fbec5a4';

final class InstallRemoteScriptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, RemoteScript> {
  const InstallRemoteScriptFamily._()
    : super(
        retry: null,
        name: r'installRemoteScriptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InstallRemoteScriptProvider call({required RemoteScript script}) =>
      InstallRemoteScriptProvider._(argument: script, from: this);

  @override
  String toString() => r'installRemoteScriptProvider';
}

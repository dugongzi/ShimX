// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_session_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexSessionActionRepository)
const codexSessionActionRepositoryProvider =
    CodexSessionActionRepositoryProvider._();

final class CodexSessionActionRepositoryProvider
    extends
        $FunctionalProvider<
          CodexSessionActionRepository,
          CodexSessionActionRepository,
          CodexSessionActionRepository
        >
    with $Provider<CodexSessionActionRepository> {
  const CodexSessionActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSessionActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexSessionActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexSessionActionRepository create(Ref ref) {
    return codexSessionActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexSessionActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexSessionActionRepository>(value),
    );
  }
}

String _$codexSessionActionRepositoryHash() =>
    r'537c8c6ded7d01a606535fe30ebb4bed57a96ca5';

@ProviderFor(deleteCodexThread)
const deleteCodexThreadProvider = DeleteCodexThreadFamily._();

final class DeleteCodexThreadProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const DeleteCodexThreadProvider._({
    required DeleteCodexThreadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteCodexThreadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteCodexThreadHash();

  @override
  String toString() {
    return r'deleteCodexThreadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return deleteCodexThread(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteCodexThreadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteCodexThreadHash() => r'da1a52fa7057ae1e9de99f43f7e938605d713c1a';

final class DeleteCodexThreadFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  const DeleteCodexThreadFamily._()
    : super(
        retry: null,
        name: r'deleteCodexThreadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteCodexThreadProvider call({required String id}) =>
      DeleteCodexThreadProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteCodexThreadProvider';
}

/// 把 action 路由注册到 bridge

@ProviderFor(codexSessionActionRouteRegistration)
const codexSessionActionRouteRegistrationProvider =
    CodexSessionActionRouteRegistrationProvider._();

/// 把 action 路由注册到 bridge

final class CodexSessionActionRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把 action 路由注册到 bridge
  const CodexSessionActionRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionActionRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$codexSessionActionRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return codexSessionActionRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$codexSessionActionRouteRegistrationHash() =>
    r'a829f6e5839bad2b9a30847804e7d52e9122f6ae';

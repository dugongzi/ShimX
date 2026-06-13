// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_session_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexSessionQueryRepository)
const codexSessionQueryRepositoryProvider =
    CodexSessionQueryRepositoryProvider._();

final class CodexSessionQueryRepositoryProvider
    extends
        $FunctionalProvider<
          CodexSessionQueryRepository,
          CodexSessionQueryRepository,
          CodexSessionQueryRepository
        >
    with $Provider<CodexSessionQueryRepository> {
  const CodexSessionQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSessionQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexSessionQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexSessionQueryRepository create(Ref ref) {
    return codexSessionQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexSessionQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexSessionQueryRepository>(value),
    );
  }
}

String _$codexSessionQueryRepositoryHash() =>
    r'b991697497ea805d33facc97a29fdd7bd7764733';

@ProviderFor(listCodexThreads)
const listCodexThreadsProvider = ListCodexThreadsFamily._();

final class ListCodexThreadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexThread>>,
          List<CodexThread>,
          FutureOr<List<CodexThread>>
        >
    with
        $FutureModifier<List<CodexThread>>,
        $FutureProvider<List<CodexThread>> {
  const ListCodexThreadsProvider._({
    required ListCodexThreadsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'listCodexThreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listCodexThreadsHash();

  @override
  String toString() {
    return r'listCodexThreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CodexThread>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexThread>> create(Ref ref) {
    final argument = this.argument as int;
    return listCodexThreads(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListCodexThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listCodexThreadsHash() => r'60cde98762e09286f9254eeb0ddf3187f841c8a0';

final class ListCodexThreadsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CodexThread>>, int> {
  const ListCodexThreadsFamily._()
    : super(
        retry: null,
        name: r'listCodexThreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ListCodexThreadsProvider call({int limit = 100}) =>
      ListCodexThreadsProvider._(argument: limit, from: this);

  @override
  String toString() => r'listCodexThreadsProvider';
}

/// 把会话相关路由注册到 bridge。在 app 启动时 watch 一次让它生效。

@ProviderFor(codexSessionRouteRegistration)
const codexSessionRouteRegistrationProvider =
    CodexSessionRouteRegistrationProvider._();

/// 把会话相关路由注册到 bridge。在 app 启动时 watch 一次让它生效。

final class CodexSessionRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把会话相关路由注册到 bridge。在 app 启动时 watch 一次让它生效。
  const CodexSessionRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSessionRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return codexSessionRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$codexSessionRouteRegistrationHash() =>
    r'9627ef006af689f1c8814f21a53c916832485766';

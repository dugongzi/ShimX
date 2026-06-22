// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_session_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(claudeSessionQueryRepository)
const claudeSessionQueryRepositoryProvider =
    ClaudeSessionQueryRepositoryProvider._();

final class ClaudeSessionQueryRepositoryProvider
    extends
        $FunctionalProvider<
          ClaudeSessionQueryRepository,
          ClaudeSessionQueryRepository,
          ClaudeSessionQueryRepository
        >
    with $Provider<ClaudeSessionQueryRepository> {
  const ClaudeSessionQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeSessionQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeSessionQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClaudeSessionQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClaudeSessionQueryRepository create(Ref ref) {
    return claudeSessionQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaudeSessionQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaudeSessionQueryRepository>(value),
    );
  }
}

String _$claudeSessionQueryRepositoryHash() =>
    r'33da621e8253caea6f44368fea2e821f7e8701f0';

@ProviderFor(listClaudeProjects)
const listClaudeProjectsProvider = ListClaudeProjectsProvider._();

final class ListClaudeProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClaudeProject>>,
          List<ClaudeProject>,
          FutureOr<List<ClaudeProject>>
        >
    with
        $FutureModifier<List<ClaudeProject>>,
        $FutureProvider<List<ClaudeProject>> {
  const ListClaudeProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listClaudeProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listClaudeProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<ClaudeProject>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ClaudeProject>> create(Ref ref) {
    return listClaudeProjects(ref);
  }
}

String _$listClaudeProjectsHash() =>
    r'1ebab49acc4e5caee3bdefb838cebed98082a39a';

@ProviderFor(listClaudeThreads)
const listClaudeThreadsProvider = ListClaudeThreadsFamily._();

final class ListClaudeThreadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClaudeThread>>,
          List<ClaudeThread>,
          FutureOr<List<ClaudeThread>>
        >
    with
        $FutureModifier<List<ClaudeThread>>,
        $FutureProvider<List<ClaudeThread>> {
  const ListClaudeThreadsProvider._({
    required ListClaudeThreadsFamily super.from,
    required ({String encodedDir, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'listClaudeThreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listClaudeThreadsHash();

  @override
  String toString() {
    return r'listClaudeThreadsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ClaudeThread>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ClaudeThread>> create(Ref ref) {
    final argument = this.argument as ({String encodedDir, int limit});
    return listClaudeThreads(
      ref,
      encodedDir: argument.encodedDir,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ListClaudeThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listClaudeThreadsHash() => r'e32cd21ce0eead9ac00d36463dfed56092ab93d1';

final class ListClaudeThreadsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ClaudeThread>>,
          ({String encodedDir, int limit})
        > {
  const ListClaudeThreadsFamily._()
    : super(
        retry: null,
        name: r'listClaudeThreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ListClaudeThreadsProvider call({
    required String encodedDir,
    int limit = 200,
  }) => ListClaudeThreadsProvider._(
    argument: (encodedDir: encodedDir, limit: limit),
    from: this,
  );

  @override
  String toString() => r'listClaudeThreadsProvider';
}

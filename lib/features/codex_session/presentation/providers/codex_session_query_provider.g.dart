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

/// 按 cwd 分组的项目左栏列表。

@ProviderFor(listCodexProjects)
const listCodexProjectsProvider = ListCodexProjectsProvider._();

/// 按 cwd 分组的项目左栏列表。

final class ListCodexProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexProject>>,
          List<CodexProject>,
          FutureOr<List<CodexProject>>
        >
    with
        $FutureModifier<List<CodexProject>>,
        $FutureProvider<List<CodexProject>> {
  /// 按 cwd 分组的项目左栏列表。
  const ListCodexProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listCodexProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listCodexProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<CodexProject>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexProject>> create(Ref ref) {
    return listCodexProjects(ref);
  }
}

String _$listCodexProjectsHash() => r'601869bb35188d772840147a040f0b6d1dc7a055';

/// 完整加载 thread:sqlite 元数据 + rollout JSONL。详情视图与导出共用。

@ProviderFor(codexThreadDetail)
const codexThreadDetailProvider = CodexThreadDetailFamily._();

/// 完整加载 thread:sqlite 元数据 + rollout JSONL。详情视图与导出共用。

final class CodexThreadDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CodexThreadDetail>,
          CodexThreadDetail,
          FutureOr<CodexThreadDetail>
        >
    with
        $FutureModifier<CodexThreadDetail>,
        $FutureProvider<CodexThreadDetail> {
  /// 完整加载 thread:sqlite 元数据 + rollout JSONL。详情视图与导出共用。
  const CodexThreadDetailProvider._({
    required CodexThreadDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'codexThreadDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$codexThreadDetailHash();

  @override
  String toString() {
    return r'codexThreadDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CodexThreadDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CodexThreadDetail> create(Ref ref) {
    final argument = this.argument as String;
    return codexThreadDetail(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CodexThreadDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$codexThreadDetailHash() => r'b8ee110830f0f9c325ac5b51bacf0871eba2c83c';

/// 完整加载 thread:sqlite 元数据 + rollout JSONL。详情视图与导出共用。

final class CodexThreadDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CodexThreadDetail>, String> {
  const CodexThreadDetailFamily._()
    : super(
        retry: null,
        name: r'codexThreadDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 完整加载 thread:sqlite 元数据 + rollout JSONL。详情视图与导出共用。

  CodexThreadDetailProvider call({required String id}) =>
      CodexThreadDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'codexThreadDetailProvider';
}

/// 首页顶部按桶分组的桶列表。

@ProviderFor(codexBuckets)
const codexBucketsProvider = CodexBucketsProvider._();

/// 首页顶部按桶分组的桶列表。

final class CodexBucketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexBucket>>,
          List<CodexBucket>,
          FutureOr<List<CodexBucket>>
        >
    with
        $FutureModifier<List<CodexBucket>>,
        $FutureProvider<List<CodexBucket>> {
  /// 首页顶部按桶分组的桶列表。
  const CodexBucketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexBucketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexBucketsHash();

  @$internal
  @override
  $FutureProviderElement<List<CodexBucket>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexBucket>> create(Ref ref) {
    return codexBuckets(ref);
  }
}

String _$codexBucketsHash() => r'bd6336a4cae37ec946633e3d9a6dd8ce8d9e7d5d';

/// 首页单桶的会话列表(family: bucket key + 分页)。

@ProviderFor(codexBucketThreads)
const codexBucketThreadsProvider = CodexBucketThreadsFamily._();

/// 首页单桶的会话列表(family: bucket key + 分页)。

final class CodexBucketThreadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexThread>>,
          List<CodexThread>,
          FutureOr<List<CodexThread>>
        >
    with
        $FutureModifier<List<CodexThread>>,
        $FutureProvider<List<CodexThread>> {
  /// 首页单桶的会话列表(family: bucket key + 分页)。
  const CodexBucketThreadsProvider._({
    required CodexBucketThreadsFamily super.from,
    required ({String bucket, int limit, int offset}) super.argument,
  }) : super(
         retry: null,
         name: r'codexBucketThreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$codexBucketThreadsHash();

  @override
  String toString() {
    return r'codexBucketThreadsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<CodexThread>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexThread>> create(Ref ref) {
    final argument = this.argument as ({String bucket, int limit, int offset});
    return codexBucketThreads(
      ref,
      bucket: argument.bucket,
      limit: argument.limit,
      offset: argument.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CodexBucketThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$codexBucketThreadsHash() =>
    r'9f03f72ced31b3f7f7ac45d922bf7a8febc50924';

/// 首页单桶的会话列表(family: bucket key + 分页)。

final class CodexBucketThreadsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CodexThread>>,
          ({String bucket, int limit, int offset})
        > {
  const CodexBucketThreadsFamily._()
    : super(
        retry: null,
        name: r'codexBucketThreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 首页单桶的会话列表(family: bucket key + 分页)。

  CodexBucketThreadsProvider call({
    required String bucket,
    int limit = 30,
    int offset = 0,
  }) => CodexBucketThreadsProvider._(
    argument: (bucket: bucket, limit: limit, offset: offset),
    from: this,
  );

  @override
  String toString() => r'codexBucketThreadsProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_backup_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexBackupQueryDatasource)
const codexBackupQueryDatasourceProvider =
    CodexBackupQueryDatasourceProvider._();

final class CodexBackupQueryDatasourceProvider
    extends
        $FunctionalProvider<
          CodexBackupQueryDatasource,
          CodexBackupQueryDatasource,
          CodexBackupQueryDatasource
        >
    with $Provider<CodexBackupQueryDatasource> {
  const CodexBackupQueryDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexBackupQueryDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexBackupQueryDatasourceHash();

  @$internal
  @override
  $ProviderElement<CodexBackupQueryDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexBackupQueryDatasource create(Ref ref) {
    return codexBackupQueryDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexBackupQueryDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexBackupQueryDatasource>(value),
    );
  }
}

String _$codexBackupQueryDatasourceHash() =>
    r'4f4876f129f18c254704eeeeea52033f468205ec';

@ProviderFor(codexBackupQueryRepository)
const codexBackupQueryRepositoryProvider =
    CodexBackupQueryRepositoryProvider._();

final class CodexBackupQueryRepositoryProvider
    extends
        $FunctionalProvider<
          CodexBackupQueryRepository,
          CodexBackupQueryRepository,
          CodexBackupQueryRepository
        >
    with $Provider<CodexBackupQueryRepository> {
  const CodexBackupQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexBackupQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexBackupQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexBackupQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexBackupQueryRepository create(Ref ref) {
    return codexBackupQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexBackupQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexBackupQueryRepository>(value),
    );
  }
}

String _$codexBackupQueryRepositoryHash() =>
    r'5a1800a416d6f7e0d5c244ec2c59d7e6ab2bde92';

/// 首屏拿分页后的 backupId,不打开 manifest。列表 tile 各自异步拉自己的 summary。

@ProviderFor(codexBackupIds)
const codexBackupIdsProvider = CodexBackupIdsFamily._();

/// 首屏拿分页后的 backupId,不打开 manifest。列表 tile 各自异步拉自己的 summary。

final class CodexBackupIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// 首屏拿分页后的 backupId,不打开 manifest。列表 tile 各自异步拉自己的 summary。
  const CodexBackupIdsProvider._({
    required CodexBackupIdsFamily super.from,
    required ({int limit, int offset}) super.argument,
  }) : super(
         retry: null,
         name: r'codexBackupIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$codexBackupIdsHash();

  @override
  String toString() {
    return r'codexBackupIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as ({int limit, int offset});
    return codexBackupIds(ref, limit: argument.limit, offset: argument.offset);
  }

  @override
  bool operator ==(Object other) {
    return other is CodexBackupIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$codexBackupIdsHash() => r'820720819310ee00428857eaaea522f92d43a2e7';

/// 首屏拿分页后的 backupId,不打开 manifest。列表 tile 各自异步拉自己的 summary。

final class CodexBackupIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<String>>,
          ({int limit, int offset})
        > {
  const CodexBackupIdsFamily._()
    : super(
        retry: null,
        name: r'codexBackupIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 首屏拿分页后的 backupId,不打开 manifest。列表 tile 各自异步拉自己的 summary。

  CodexBackupIdsProvider call({int limit = 30, int offset = 0}) =>
      CodexBackupIdsProvider._(
        argument: (limit: limit, offset: offset),
        from: this,
      );

  @override
  String toString() => r'codexBackupIdsProvider';
}

/// 单条备份的摘要(不含 entries),用于列表 tile 头部显示。

@ProviderFor(codexBackupSummary)
const codexBackupSummaryProvider = CodexBackupSummaryFamily._();

/// 单条备份的摘要(不含 entries),用于列表 tile 头部显示。

final class CodexBackupSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CodexBackup?>,
          CodexBackup?,
          FutureOr<CodexBackup?>
        >
    with $FutureModifier<CodexBackup?>, $FutureProvider<CodexBackup?> {
  /// 单条备份的摘要(不含 entries),用于列表 tile 头部显示。
  const CodexBackupSummaryProvider._({
    required CodexBackupSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'codexBackupSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$codexBackupSummaryHash();

  @override
  String toString() {
    return r'codexBackupSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CodexBackup?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CodexBackup?> create(Ref ref) {
    final argument = this.argument as String;
    return codexBackupSummary(ref, backupId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CodexBackupSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$codexBackupSummaryHash() =>
    r'98279af41d8a1f3d209027396d0968408eb63a13';

/// 单条备份的摘要(不含 entries),用于列表 tile 头部显示。

final class CodexBackupSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CodexBackup?>, String> {
  const CodexBackupSummaryFamily._()
    : super(
        retry: null,
        name: r'codexBackupSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 单条备份的摘要(不含 entries),用于列表 tile 头部显示。

  CodexBackupSummaryProvider call({required String backupId}) =>
      CodexBackupSummaryProvider._(argument: backupId, from: this);

  @override
  String toString() => r'codexBackupSummaryProvider';
}

/// 单条备份的详情(含 entries),只在展开 tile 时才用。

@ProviderFor(codexBackupDetail)
const codexBackupDetailProvider = CodexBackupDetailFamily._();

/// 单条备份的详情(含 entries),只在展开 tile 时才用。

final class CodexBackupDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CodexBackupDetail?>,
          CodexBackupDetail?,
          FutureOr<CodexBackupDetail?>
        >
    with
        $FutureModifier<CodexBackupDetail?>,
        $FutureProvider<CodexBackupDetail?> {
  /// 单条备份的详情(含 entries),只在展开 tile 时才用。
  const CodexBackupDetailProvider._({
    required CodexBackupDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'codexBackupDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$codexBackupDetailHash();

  @override
  String toString() {
    return r'codexBackupDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CodexBackupDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CodexBackupDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return codexBackupDetail(ref, backupId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CodexBackupDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$codexBackupDetailHash() => r'a304c561ac6ef04a38d5e4026c83b6af07d735c4';

/// 单条备份的详情(含 entries),只在展开 tile 时才用。

final class CodexBackupDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CodexBackupDetail?>, String> {
  const CodexBackupDetailFamily._()
    : super(
        retry: null,
        name: r'codexBackupDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 单条备份的详情(含 entries),只在展开 tile 时才用。

  CodexBackupDetailProvider call({required String backupId}) =>
      CodexBackupDetailProvider._(argument: backupId, from: this);

  @override
  String toString() => r'codexBackupDetailProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_session_export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(claudeSessionExportRepository)
const claudeSessionExportRepositoryProvider =
    ClaudeSessionExportRepositoryProvider._();

final class ClaudeSessionExportRepositoryProvider
    extends
        $FunctionalProvider<
          ClaudeSessionExportRepository,
          ClaudeSessionExportRepository,
          ClaudeSessionExportRepository
        >
    with $Provider<ClaudeSessionExportRepository> {
  const ClaudeSessionExportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeSessionExportRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeSessionExportRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClaudeSessionExportRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClaudeSessionExportRepository create(Ref ref) {
    return claudeSessionExportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaudeSessionExportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaudeSessionExportRepository>(
        value,
      ),
    );
  }
}

String _$claudeSessionExportRepositoryHash() =>
    r'be88c4642bc00378600990bce8995bc81417959b';

/// 完整加载 jsonl 成 detail (用于详情视图 + 导出共用)

@ProviderFor(claudeThreadDetail)
const claudeThreadDetailProvider = ClaudeThreadDetailFamily._();

/// 完整加载 jsonl 成 detail (用于详情视图 + 导出共用)

final class ClaudeThreadDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClaudeThreadDetail>,
          ClaudeThreadDetail,
          FutureOr<ClaudeThreadDetail>
        >
    with
        $FutureModifier<ClaudeThreadDetail>,
        $FutureProvider<ClaudeThreadDetail> {
  /// 完整加载 jsonl 成 detail (用于详情视图 + 导出共用)
  const ClaudeThreadDetailProvider._({
    required ClaudeThreadDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'claudeThreadDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$claudeThreadDetailHash();

  @override
  String toString() {
    return r'claudeThreadDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClaudeThreadDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClaudeThreadDetail> create(Ref ref) {
    final argument = this.argument as String;
    return claudeThreadDetail(ref, jsonlPath: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClaudeThreadDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$claudeThreadDetailHash() =>
    r'3116f67d20a1199cd79be850a0b436f9ae7c5f2b';

/// 完整加载 jsonl 成 detail (用于详情视图 + 导出共用)

final class ClaudeThreadDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClaudeThreadDetail>, String> {
  const ClaudeThreadDetailFamily._()
    : super(
        retry: null,
        name: r'claudeThreadDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 完整加载 jsonl 成 detail (用于详情视图 + 导出共用)

  ClaudeThreadDetailProvider call({required String jsonlPath}) =>
      ClaudeThreadDetailProvider._(argument: jsonlPath, from: this);

  @override
  String toString() => r'claudeThreadDetailProvider';
}

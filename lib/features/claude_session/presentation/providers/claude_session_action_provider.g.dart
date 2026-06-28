// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_session_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(claudeSessionActionRepository)
const claudeSessionActionRepositoryProvider =
    ClaudeSessionActionRepositoryProvider._();

final class ClaudeSessionActionRepositoryProvider
    extends
        $FunctionalProvider<
          ClaudeSessionActionRepository,
          ClaudeSessionActionRepository,
          ClaudeSessionActionRepository
        >
    with $Provider<ClaudeSessionActionRepository> {
  const ClaudeSessionActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeSessionActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeSessionActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClaudeSessionActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClaudeSessionActionRepository create(Ref ref) {
    return claudeSessionActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaudeSessionActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaudeSessionActionRepository>(
        value,
      ),
    );
  }
}

String _$claudeSessionActionRepositoryHash() =>
    r'7b830e0dd95cb3d00454c857befa90c232886a1a';

/// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。

@ProviderFor(exportClaudeThread)
const exportClaudeThreadProvider = ExportClaudeThreadFamily._();

/// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。

final class ExportClaudeThreadProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。
  const ExportClaudeThreadProvider._({
    required ExportClaudeThreadFamily super.from,
    required ({ClaudeThreadDetail detail, String format}) super.argument,
  }) : super(
         retry: null,
         name: r'exportClaudeThreadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportClaudeThreadHash();

  @override
  String toString() {
    return r'exportClaudeThreadProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument =
        this.argument as ({ClaudeThreadDetail detail, String format});
    return exportClaudeThread(
      ref,
      detail: argument.detail,
      format: argument.format,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExportClaudeThreadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportClaudeThreadHash() =>
    r'f93e391585cb7442e93cecea3f37845b8ecd5948';

/// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。

final class ExportClaudeThreadFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String?>,
          ({ClaudeThreadDetail detail, String format})
        > {
  const ExportClaudeThreadFamily._()
    : super(
        retry: null,
        name: r'exportClaudeThreadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 导出某会话:弹保存对话框 → 写文件。返回 outputPath,用户取消返回 null。

  ExportClaudeThreadProvider call({
    required ClaudeThreadDetail detail,
    required String format,
  }) => ExportClaudeThreadProvider._(
    argument: (detail: detail, format: format),
    from: this,
  );

  @override
  String toString() => r'exportClaudeThreadProvider';
}

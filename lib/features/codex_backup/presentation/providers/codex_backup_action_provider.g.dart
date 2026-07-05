// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_backup_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexBackupActionDatasource)
const codexBackupActionDatasourceProvider =
    CodexBackupActionDatasourceProvider._();

final class CodexBackupActionDatasourceProvider
    extends
        $FunctionalProvider<
          CodexBackupActionDatasource,
          CodexBackupActionDatasource,
          CodexBackupActionDatasource
        >
    with $Provider<CodexBackupActionDatasource> {
  const CodexBackupActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexBackupActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexBackupActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<CodexBackupActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexBackupActionDatasource create(Ref ref) {
    return codexBackupActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexBackupActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexBackupActionDatasource>(value),
    );
  }
}

String _$codexBackupActionDatasourceHash() =>
    r'289b3609bbd037cb10a10f7b7142c2fd1d9dee7d';

@ProviderFor(codexBackupActionRepository)
const codexBackupActionRepositoryProvider =
    CodexBackupActionRepositoryProvider._();

final class CodexBackupActionRepositoryProvider
    extends
        $FunctionalProvider<
          CodexBackupActionRepository,
          CodexBackupActionRepository,
          CodexBackupActionRepository
        >
    with $Provider<CodexBackupActionRepository> {
  const CodexBackupActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexBackupActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexBackupActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexBackupActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexBackupActionRepository create(Ref ref) {
    return codexBackupActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexBackupActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexBackupActionRepository>(value),
    );
  }
}

String _$codexBackupActionRepositoryHash() =>
    r'a84ba03437ba7e2bea1095bfcf78bb3b75edd8b2';

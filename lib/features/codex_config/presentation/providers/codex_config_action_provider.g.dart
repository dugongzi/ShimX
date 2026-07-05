// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_config_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexConfigActionDatasource)
const codexConfigActionDatasourceProvider =
    CodexConfigActionDatasourceProvider._();

final class CodexConfigActionDatasourceProvider
    extends
        $FunctionalProvider<
          CodexConfigActionDatasource,
          CodexConfigActionDatasource,
          CodexConfigActionDatasource
        >
    with $Provider<CodexConfigActionDatasource> {
  const CodexConfigActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexConfigActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexConfigActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<CodexConfigActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexConfigActionDatasource create(Ref ref) {
    return codexConfigActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexConfigActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexConfigActionDatasource>(value),
    );
  }
}

String _$codexConfigActionDatasourceHash() =>
    r'bc4e9764a2f87f6ec14c46aec8307e7f7920f58e';

@ProviderFor(codexConfigActionRepository)
const codexConfigActionRepositoryProvider =
    CodexConfigActionRepositoryProvider._();

final class CodexConfigActionRepositoryProvider
    extends
        $FunctionalProvider<
          CodexConfigActionRepository,
          CodexConfigActionRepository,
          CodexConfigActionRepository
        >
    with $Provider<CodexConfigActionRepository> {
  const CodexConfigActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexConfigActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexConfigActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexConfigActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexConfigActionRepository create(Ref ref) {
    return codexConfigActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexConfigActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexConfigActionRepository>(value),
    );
  }
}

String _$codexConfigActionRepositoryHash() =>
    r'352ae509b8e0969c4fd9a0d6fc16191058b6727a';

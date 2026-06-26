// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_mcp_config_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexMcpConfigQueryRepository)
const codexMcpConfigQueryRepositoryProvider =
    CodexMcpConfigQueryRepositoryProvider._();

final class CodexMcpConfigQueryRepositoryProvider
    extends
        $FunctionalProvider<
          CodexMcpConfigQueryRepository,
          CodexMcpConfigQueryRepository,
          CodexMcpConfigQueryRepository
        >
    with $Provider<CodexMcpConfigQueryRepository> {
  const CodexMcpConfigQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexMcpConfigQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexMcpConfigQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexMcpConfigQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexMcpConfigQueryRepository create(Ref ref) {
    return codexMcpConfigQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexMcpConfigQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexMcpConfigQueryRepository>(
        value,
      ),
    );
  }
}

String _$codexMcpConfigQueryRepositoryHash() =>
    r'0ac72978a493e296b31b0e44661cc95099c3a935';

@ProviderFor(codexMcpConfigs)
const codexMcpConfigsProvider = CodexMcpConfigsProvider._();

final class CodexMcpConfigsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexMcpConfig>>,
          List<CodexMcpConfig>,
          FutureOr<List<CodexMcpConfig>>
        >
    with
        $FutureModifier<List<CodexMcpConfig>>,
        $FutureProvider<List<CodexMcpConfig>> {
  const CodexMcpConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexMcpConfigsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexMcpConfigsHash();

  @$internal
  @override
  $FutureProviderElement<List<CodexMcpConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexMcpConfig>> create(Ref ref) {
    return codexMcpConfigs(ref);
  }
}

String _$codexMcpConfigsHash() => r'cee1ca7ed3e18eea2d5ad624101f2df972c7c788';

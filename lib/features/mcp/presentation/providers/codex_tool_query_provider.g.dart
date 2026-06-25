// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_tool_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexToolQueryRepository)
const codexToolQueryRepositoryProvider = CodexToolQueryRepositoryProvider._();

final class CodexToolQueryRepositoryProvider
    extends
        $FunctionalProvider<
          CodexToolQueryRepository,
          CodexToolQueryRepository,
          CodexToolQueryRepository
        >
    with $Provider<CodexToolQueryRepository> {
  const CodexToolQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexToolQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexToolQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexToolQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexToolQueryRepository create(Ref ref) {
    return codexToolQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexToolQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexToolQueryRepository>(value),
    );
  }
}

String _$codexToolQueryRepositoryHash() =>
    r'25287055118500a5c07ede87d75d32e2eaed3dcf';

@ProviderFor(codexTools)
const codexToolsProvider = CodexToolsProvider._();

final class CodexToolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexTool>>,
          List<CodexTool>,
          FutureOr<List<CodexTool>>
        >
    with $FutureModifier<List<CodexTool>>, $FutureProvider<List<CodexTool>> {
  const CodexToolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexToolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexToolsHash();

  @$internal
  @override
  $FutureProviderElement<List<CodexTool>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexTool>> create(Ref ref) {
    return codexTools(ref);
  }
}

String _$codexToolsHash() => r'e36dd597e8aa1d3129f466c33c80909552e5d174';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_config_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexConfigQueryDatasource)
const codexConfigQueryDatasourceProvider =
    CodexConfigQueryDatasourceProvider._();

final class CodexConfigQueryDatasourceProvider
    extends
        $FunctionalProvider<
          CodexConfigQueryDatasource,
          CodexConfigQueryDatasource,
          CodexConfigQueryDatasource
        >
    with $Provider<CodexConfigQueryDatasource> {
  const CodexConfigQueryDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexConfigQueryDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexConfigQueryDatasourceHash();

  @$internal
  @override
  $ProviderElement<CodexConfigQueryDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexConfigQueryDatasource create(Ref ref) {
    return codexConfigQueryDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexConfigQueryDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexConfigQueryDatasource>(value),
    );
  }
}

String _$codexConfigQueryDatasourceHash() =>
    r'28ea5da0aae6cd2708f59a51c45104db7eb55920';

@ProviderFor(codexConfigQueryRepository)
const codexConfigQueryRepositoryProvider =
    CodexConfigQueryRepositoryProvider._();

final class CodexConfigQueryRepositoryProvider
    extends
        $FunctionalProvider<
          CodexConfigQueryRepository,
          CodexConfigQueryRepository,
          CodexConfigQueryRepository
        >
    with $Provider<CodexConfigQueryRepository> {
  const CodexConfigQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexConfigQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexConfigQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexConfigQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexConfigQueryRepository create(Ref ref) {
    return codexConfigQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexConfigQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexConfigQueryRepository>(value),
    );
  }
}

String _$codexConfigQueryRepositoryHash() =>
    r'eedf6204e0eb41232ccf86ae8a6e3b88f0d62059';

/// 当前 codex config.toml 里的 `model_provider`,给首页顶部条使用。
/// autoDispose 让页面关掉后不再持有,重新进入会 refresh。

@ProviderFor(codexModelProvider)
const codexModelProviderProvider = CodexModelProviderProvider._();

/// 当前 codex config.toml 里的 `model_provider`,给首页顶部条使用。
/// autoDispose 让页面关掉后不再持有,重新进入会 refresh。

final class CodexModelProviderProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 当前 codex config.toml 里的 `model_provider`,给首页顶部条使用。
  /// autoDispose 让页面关掉后不再持有,重新进入会 refresh。
  const CodexModelProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexModelProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexModelProviderHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return codexModelProvider(ref);
  }
}

String _$codexModelProviderHash() =>
    r'ec9adf890c6bad1a029827f935ce16048a4ca591';

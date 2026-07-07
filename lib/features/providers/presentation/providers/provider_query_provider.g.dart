// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providerQueryRepository)
const providerQueryRepositoryProvider = ProviderQueryRepositoryProvider._();

final class ProviderQueryRepositoryProvider
    extends
        $FunctionalProvider<
          ProviderQueryRepository,
          ProviderQueryRepository,
          ProviderQueryRepository
        >
    with $Provider<ProviderQueryRepository> {
  const ProviderQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProviderQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderQueryRepository create(Ref ref) {
    return providerQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderQueryRepository>(value),
    );
  }
}

String _$providerQueryRepositoryHash() =>
    r'5ce20bcf4d168ced3f23a4d5427a60ee37d9d928';

/// 供应商列表 + 当前选中项。action 写入后 invalidate 本 provider 刷新。

@ProviderFor(providerList)
const providerListProvider = ProviderListProvider._();

/// 供应商列表 + 当前选中项。action 写入后 invalidate 本 provider 刷新。

final class ProviderListProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProviderListState>,
          ProviderListState,
          FutureOr<ProviderListState>
        >
    with
        $FutureModifier<ProviderListState>,
        $FutureProvider<ProviderListState> {
  /// 供应商列表 + 当前选中项。action 写入后 invalidate 本 provider 刷新。
  const ProviderListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerListHash();

  @$internal
  @override
  $FutureProviderElement<ProviderListState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProviderListState> create(Ref ref) {
    return providerList(ref);
  }
}

String _$providerListHash() => r'214e6b6fcefdd9dd8d12f4e60af0b9996b2c32ba';

/// 本地代理配置（开关 + 端口）。action 写入后 invalidate 本 provider 刷新。

@ProviderFor(proxyConfig)
const proxyConfigProvider = ProxyConfigProvider._();

/// 本地代理配置（开关 + 端口）。action 写入后 invalidate 本 provider 刷新。

final class ProxyConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProxyConfig>,
          ProxyConfig,
          FutureOr<ProxyConfig>
        >
    with $FutureModifier<ProxyConfig>, $FutureProvider<ProxyConfig> {
  /// 本地代理配置（开关 + 端口）。action 写入后 invalidate 本 provider 刷新。
  const ProxyConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyConfigHash();

  @$internal
  @override
  $FutureProviderElement<ProxyConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProxyConfig> create(Ref ref) {
    return proxyConfig(ref);
  }
}

String _$proxyConfigHash() => r'a74627351e4161d35dfe7a78749ceb45d9d9d86e';

/// 拉取指定供应商的可用模型列表（调其 /models 端点）。

@ProviderFor(fetchProviderModels)
const fetchProviderModelsProvider = FetchProviderModelsFamily._();

/// 拉取指定供应商的可用模型列表（调其 /models 端点）。

final class FetchProviderModelsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// 拉取指定供应商的可用模型列表（调其 /models 端点）。
  const FetchProviderModelsProvider._({
    required FetchProviderModelsFamily super.from,
    required ({String baseUrl, String apiKey}) super.argument,
  }) : super(
         retry: null,
         name: r'fetchProviderModelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchProviderModelsHash();

  @override
  String toString() {
    return r'fetchProviderModelsProvider'
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
    final argument = this.argument as ({String baseUrl, String apiKey});
    return fetchProviderModels(
      ref,
      baseUrl: argument.baseUrl,
      apiKey: argument.apiKey,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FetchProviderModelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchProviderModelsHash() =>
    r'0ed97d116a433efe931c2a80018f5a6b3495b2e7';

/// 拉取指定供应商的可用模型列表（调其 /models 端点）。

final class FetchProviderModelsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<String>>,
          ({String baseUrl, String apiKey})
        > {
  const FetchProviderModelsFamily._()
    : super(
        retry: null,
        name: r'fetchProviderModelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 拉取指定供应商的可用模型列表（调其 /models 端点）。

  FetchProviderModelsProvider call({
    required String baseUrl,
    required String apiKey,
  }) => FetchProviderModelsProvider._(
    argument: (baseUrl: baseUrl, apiKey: apiKey),
    from: this,
  );

  @override
  String toString() => r'fetchProviderModelsProvider';
}

/// 把供应商查询路由注册到 bridge。注入时 read 一次让它生效。
///
/// /provider/current — JS 拉当前生效的供应商，用于在对话上方渲染名称。
/// 返回 {name, label}：name 为供应商名（无则 null），label 为拼好语言前缀的
/// 完整文案（中「供应商：xxx」/ 英「Provider: xxx」）。语言跟随 ShimX 本体设置，
/// 由 Dart 侧拼好交给 JS，JS 不处理语言逻辑。

@ProviderFor(providerRouteRegistration)
const providerRouteRegistrationProvider = ProviderRouteRegistrationProvider._();

/// 把供应商查询路由注册到 bridge。注入时 read 一次让它生效。
///
/// /provider/current — JS 拉当前生效的供应商，用于在对话上方渲染名称。
/// 返回 {name, label}：name 为供应商名（无则 null），label 为拼好语言前缀的
/// 完整文案（中「供应商：xxx」/ 英「Provider: xxx」）。语言跟随 ShimX 本体设置，
/// 由 Dart 侧拼好交给 JS，JS 不处理语言逻辑。

final class ProviderRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把供应商查询路由注册到 bridge。注入时 read 一次让它生效。
  ///
  /// /provider/current — JS 拉当前生效的供应商，用于在对话上方渲染名称。
  /// 返回 {name, label}：name 为供应商名（无则 null），label 为拼好语言前缀的
  /// 完整文案（中「供应商：xxx」/ 英「Provider: xxx」）。语言跟随 ShimX 本体设置，
  /// 由 Dart 侧拼好交给 JS，JS 不处理语言逻辑。
  const ProviderRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return providerRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$providerRouteRegistrationHash() =>
    r'6ee9680817c5f5b740d3e2b25aa62d26ba4a4acf';

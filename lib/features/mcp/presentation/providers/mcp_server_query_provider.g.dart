// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mcpServerQueryRepository)
const mcpServerQueryRepositoryProvider = McpServerQueryRepositoryProvider._();

final class McpServerQueryRepositoryProvider
    extends
        $FunctionalProvider<
          McpServerQueryRepository,
          McpServerQueryRepository,
          McpServerQueryRepository
        >
    with $Provider<McpServerQueryRepository> {
  const McpServerQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mcpServerQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mcpServerQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<McpServerQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  McpServerQueryRepository create(Ref ref) {
    return mcpServerQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(McpServerQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<McpServerQueryRepository>(value),
    );
  }
}

String _$mcpServerQueryRepositoryHash() =>
    r'9665831e3ed8f42287e18378175d31d28aad090c';

/// shim 暴露的 MCP server 列表(配置 + codex 注册状态)。
/// runtime running 状态由 UI 层结合 [mcpServerRunningPortProvider] 自行覆盖。

@ProviderFor(mcpServerList)
const mcpServerListProvider = McpServerListProvider._();

/// shim 暴露的 MCP server 列表(配置 + codex 注册状态)。
/// runtime running 状态由 UI 层结合 [mcpServerRunningPortProvider] 自行覆盖。

final class McpServerListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<McpServerInfo>>,
          List<McpServerInfo>,
          FutureOr<List<McpServerInfo>>
        >
    with
        $FutureModifier<List<McpServerInfo>>,
        $FutureProvider<List<McpServerInfo>> {
  /// shim 暴露的 MCP server 列表(配置 + codex 注册状态)。
  /// runtime running 状态由 UI 层结合 [mcpServerRunningPortProvider] 自行覆盖。
  const McpServerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mcpServerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mcpServerListHash();

  @$internal
  @override
  $FutureProviderElement<List<McpServerInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<McpServerInfo>> create(Ref ref) {
    return mcpServerList(ref);
  }
}

String _$mcpServerListHash() => r'78eb2b95b267355ba3a659c3e96ec018d35f8653';

/// shim 内置 MCP server 是否开启;未设置过时返回默认 true。

@ProviderFor(mcpServerEnabled)
const mcpServerEnabledProvider = McpServerEnabledProvider._();

/// shim 内置 MCP server 是否开启;未设置过时返回默认 true。

final class McpServerEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// shim 内置 MCP server 是否开启;未设置过时返回默认 true。
  const McpServerEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mcpServerEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mcpServerEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return mcpServerEnabled(ref);
  }
}

String _$mcpServerEnabledHash() => r'03c8c5911844c0caa360c247851f8ecf0cc9e080';

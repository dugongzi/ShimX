// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mcpServerActionRepository)
const mcpServerActionRepositoryProvider = McpServerActionRepositoryProvider._();

final class McpServerActionRepositoryProvider
    extends
        $FunctionalProvider<
          McpServerActionRepository,
          McpServerActionRepository,
          McpServerActionRepository
        >
    with $Provider<McpServerActionRepository> {
  const McpServerActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mcpServerActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mcpServerActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<McpServerActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  McpServerActionRepository create(Ref ref) {
    return mcpServerActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(McpServerActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<McpServerActionRepository>(value),
    );
  }
}

String _$mcpServerActionRepositoryHash() =>
    r'375f6617adb5f11dc58b2a49a86970bc08fb184f';

/// keepAlive 保留 notifier 实例 —— 否则 UI 切走或重建会 dispose,
/// 而 setEnabled 是 await + ref.invalidate,中途 dispose 会抛
/// 'Cannot use the Ref ... after disposed'。

@ProviderFor(McpServerActions)
const mcpServerActionsProvider = McpServerActionsProvider._();

/// keepAlive 保留 notifier 实例 —— 否则 UI 切走或重建会 dispose,
/// 而 setEnabled 是 await + ref.invalidate,中途 dispose 会抛
/// 'Cannot use the Ref ... after disposed'。
final class McpServerActionsProvider
    extends $NotifierProvider<McpServerActions, void> {
  /// keepAlive 保留 notifier 实例 —— 否则 UI 切走或重建会 dispose,
  /// 而 setEnabled 是 await + ref.invalidate,中途 dispose 会抛
  /// 'Cannot use the Ref ... after disposed'。
  const McpServerActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mcpServerActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mcpServerActionsHash();

  @$internal
  @override
  McpServerActions create() => McpServerActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$mcpServerActionsHash() => r'5651af999932501ebb907c4a89c367c97f17d323';

/// keepAlive 保留 notifier 实例 —— 否则 UI 切走或重建会 dispose,
/// 而 setEnabled 是 await + ref.invalidate,中途 dispose 会抛
/// 'Cannot use the Ref ... after disposed'。

abstract class _$McpServerActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// 应用启动时根据持久化的 enabled 自动起 MCP server。
/// keepAlive,只在第一次 watch 时跑一次。

@ProviderFor(mcpServerAutoStart)
const mcpServerAutoStartProvider = McpServerAutoStartProvider._();

/// 应用启动时根据持久化的 enabled 自动起 MCP server。
/// keepAlive,只在第一次 watch 时跑一次。

final class McpServerAutoStartProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 应用启动时根据持久化的 enabled 自动起 MCP server。
  /// keepAlive,只在第一次 watch 时跑一次。
  const McpServerAutoStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mcpServerAutoStartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mcpServerAutoStartHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return mcpServerAutoStart(ref);
  }
}

String _$mcpServerAutoStartHash() =>
    r'c5239126ccd2c9e38b13c64b1db033adbbd02e8e';

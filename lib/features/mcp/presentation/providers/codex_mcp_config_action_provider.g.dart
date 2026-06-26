// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_mcp_config_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexMcpConfigActionRepository)
const codexMcpConfigActionRepositoryProvider =
    CodexMcpConfigActionRepositoryProvider._();

final class CodexMcpConfigActionRepositoryProvider
    extends
        $FunctionalProvider<
          CodexMcpConfigActionRepository,
          CodexMcpConfigActionRepository,
          CodexMcpConfigActionRepository
        >
    with $Provider<CodexMcpConfigActionRepository> {
  const CodexMcpConfigActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexMcpConfigActionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexMcpConfigActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexMcpConfigActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexMcpConfigActionRepository create(Ref ref) {
    return codexMcpConfigActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexMcpConfigActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexMcpConfigActionRepository>(
        value,
      ),
    );
  }
}

String _$codexMcpConfigActionRepositoryHash() =>
    r'aa63f4449a5e218c38912adb6603ec0595059244';

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。

@ProviderFor(CodexMcpConfigActions)
const codexMcpConfigActionsProvider = CodexMcpConfigActionsProvider._();

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。
final class CodexMcpConfigActionsProvider
    extends $NotifierProvider<CodexMcpConfigActions, void> {
  /// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
  /// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。
  const CodexMcpConfigActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexMcpConfigActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexMcpConfigActionsHash();

  @$internal
  @override
  CodexMcpConfigActions create() => CodexMcpConfigActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$codexMcpConfigActionsHash() =>
    r'4a260bb533e823f35c399d9e13a969b11a496fd0';

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。

abstract class _$CodexMcpConfigActions extends $Notifier<void> {
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

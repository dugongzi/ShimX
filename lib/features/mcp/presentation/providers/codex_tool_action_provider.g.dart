// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_tool_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexToolActionRepository)
const codexToolActionRepositoryProvider = CodexToolActionRepositoryProvider._();

final class CodexToolActionRepositoryProvider
    extends
        $FunctionalProvider<
          CodexToolActionRepository,
          CodexToolActionRepository,
          CodexToolActionRepository
        >
    with $Provider<CodexToolActionRepository> {
  const CodexToolActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexToolActionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexToolActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexToolActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexToolActionRepository create(Ref ref) {
    return codexToolActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexToolActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexToolActionRepository>(value),
    );
  }
}

String _$codexToolActionRepositoryHash() =>
    r'ea13053568314f9cd04b6a0787d80314bd16d2f4';

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。

@ProviderFor(CodexToolActions)
const codexToolActionsProvider = CodexToolActionsProvider._();

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。
final class CodexToolActionsProvider
    extends $NotifierProvider<CodexToolActions, void> {
  /// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
  /// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。
  const CodexToolActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexToolActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexToolActionsHash();

  @$internal
  @override
  CodexToolActions create() => CodexToolActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$codexToolActionsHash() => r'0d17afb2a9ee9fba5c78f950ad1e092f94c4f652';

/// keepAlive 保留 notifier 实例。UI 通过 `ref.read(...notifier)` 触发写入时,
/// 没有 widget watch 这个 provider;若 auto-dispose,await 文件写入期间会释放 ref。

abstract class _$CodexToolActions extends $Notifier<void> {
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

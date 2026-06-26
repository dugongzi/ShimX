// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_skill_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexSkillActionRepository)
const codexSkillActionRepositoryProvider =
    CodexSkillActionRepositoryProvider._();

final class CodexSkillActionRepositoryProvider
    extends
        $FunctionalProvider<
          CodexSkillActionRepository,
          CodexSkillActionRepository,
          CodexSkillActionRepository
        >
    with $Provider<CodexSkillActionRepository> {
  const CodexSkillActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSkillActionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSkillActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexSkillActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexSkillActionRepository create(Ref ref) {
    return codexSkillActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexSkillActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexSkillActionRepository>(value),
    );
  }
}

String _$codexSkillActionRepositoryHash() =>
    r'29310cc108ef758d351719a23ebb58e559b4266d';

@ProviderFor(CodexSkillActions)
const codexSkillActionsProvider = CodexSkillActionsProvider._();

final class CodexSkillActionsProvider
    extends $NotifierProvider<CodexSkillActions, void> {
  const CodexSkillActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSkillActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSkillActionsHash();

  @$internal
  @override
  CodexSkillActions create() => CodexSkillActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$codexSkillActionsHash() => r'3aaee741019f0dd63d2edad5302bfd0f494260a1';

abstract class _$CodexSkillActions extends $Notifier<void> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_skill_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexSkillQueryRepository)
const codexSkillQueryRepositoryProvider = CodexSkillQueryRepositoryProvider._();

final class CodexSkillQueryRepositoryProvider
    extends
        $FunctionalProvider<
          CodexSkillQueryRepository,
          CodexSkillQueryRepository,
          CodexSkillQueryRepository
        >
    with $Provider<CodexSkillQueryRepository> {
  const CodexSkillQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSkillQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSkillQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexSkillQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexSkillQueryRepository create(Ref ref) {
    return codexSkillQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexSkillQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexSkillQueryRepository>(value),
    );
  }
}

String _$codexSkillQueryRepositoryHash() =>
    r'b2eff9627a69adc054cdfa72d32ab8126c268c0f';

@ProviderFor(codexSkills)
const codexSkillsProvider = CodexSkillsProvider._();

final class CodexSkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CodexSkill>>,
          List<CodexSkill>,
          FutureOr<List<CodexSkill>>
        >
    with $FutureModifier<List<CodexSkill>>, $FutureProvider<List<CodexSkill>> {
  const CodexSkillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSkillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSkillsHash();

  @$internal
  @override
  $FutureProviderElement<List<CodexSkill>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CodexSkill>> create(Ref ref) {
    return codexSkills(ref);
  }
}

String _$codexSkillsHash() => r'1cddbf12311141780eacb498c1f244e9db0da1b6';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scriptQueryDatasource)
const scriptQueryDatasourceProvider = ScriptQueryDatasourceProvider._();

final class ScriptQueryDatasourceProvider
    extends
        $FunctionalProvider<
          ScriptQueryDatasource,
          ScriptQueryDatasource,
          ScriptQueryDatasource
        >
    with $Provider<ScriptQueryDatasource> {
  const ScriptQueryDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptQueryDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptQueryDatasourceHash();

  @$internal
  @override
  $ProviderElement<ScriptQueryDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScriptQueryDatasource create(Ref ref) {
    return scriptQueryDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptQueryDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptQueryDatasource>(value),
    );
  }
}

String _$scriptQueryDatasourceHash() =>
    r'faa206096b44a515d141eada279319551cfd8e71';

@ProviderFor(scriptQueryRepository)
const scriptQueryRepositoryProvider = ScriptQueryRepositoryProvider._();

final class ScriptQueryRepositoryProvider
    extends
        $FunctionalProvider<
          ScriptQueryRepository,
          ScriptQueryRepository,
          ScriptQueryRepository
        >
    with $Provider<ScriptQueryRepository> {
  const ScriptQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScriptQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScriptQueryRepository create(Ref ref) {
    return scriptQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptQueryRepository>(value),
    );
  }
}

String _$scriptQueryRepositoryHash() =>
    r'2ec60a659597487c0c86b0603249b0fdd156a53c';

@ProviderFor(scripts)
const scriptsProvider = ScriptsProvider._();

final class ScriptsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InjectScript>>,
          List<InjectScript>,
          FutureOr<List<InjectScript>>
        >
    with
        $FutureModifier<List<InjectScript>>,
        $FutureProvider<List<InjectScript>> {
  const ScriptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptsHash();

  @$internal
  @override
  $FutureProviderElement<List<InjectScript>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InjectScript>> create(Ref ref) {
    return scripts(ref);
  }
}

String _$scriptsHash() => r'7ee585745233b8f0fdc7af856caccf0e264913e3';

@ProviderFor(scriptEnabled)
const scriptEnabledProvider = ScriptEnabledFamily._();

final class ScriptEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const ScriptEnabledProvider._({
    required ScriptEnabledFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'scriptEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scriptEnabledHash();

  @override
  String toString() {
    return r'scriptEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return scriptEnabled(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ScriptEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scriptEnabledHash() => r'fa310aad3ae3ff0ad6dbbbf082dcc192fbeee2c3';

final class ScriptEnabledFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const ScriptEnabledFamily._()
    : super(
        retry: null,
        name: r'scriptEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScriptEnabledProvider call({required String id}) =>
      ScriptEnabledProvider._(argument: id, from: this);

  @override
  String toString() => r'scriptEnabledProvider';
}

/// 编辑器 Run 时是否同时刷新 Codex(默认 true)。

@ProviderFor(reloadOnRun)
const reloadOnRunProvider = ReloadOnRunProvider._();

/// 编辑器 Run 时是否同时刷新 Codex(默认 true)。

final class ReloadOnRunProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 编辑器 Run 时是否同时刷新 Codex(默认 true)。
  const ReloadOnRunProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reloadOnRunProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reloadOnRunHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return reloadOnRun(ref);
  }
}

String _$reloadOnRunHash() => r'17d3dc3dd4e146592da77f8dbdef1b36c79045a4';

/// 手动保存(Ctrl+S)后是否自动 Run(默认 false)。

@ProviderFor(hotRun)
const hotRunProvider = HotRunProvider._();

/// 手动保存(Ctrl+S)后是否自动 Run(默认 false)。

final class HotRunProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 手动保存(Ctrl+S)后是否自动 Run(默认 false)。
  const HotRunProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotRunProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotRunHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hotRun(ref);
  }
}

String _$hotRunHash() => r'22567f46897117180ca73f8dddf433f90c451c88';

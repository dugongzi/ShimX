// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scriptActionDatasource)
const scriptActionDatasourceProvider = ScriptActionDatasourceProvider._();

final class ScriptActionDatasourceProvider
    extends
        $FunctionalProvider<
          ScriptActionDatasource,
          ScriptActionDatasource,
          ScriptActionDatasource
        >
    with $Provider<ScriptActionDatasource> {
  const ScriptActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<ScriptActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScriptActionDatasource create(Ref ref) {
    return scriptActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptActionDatasource>(value),
    );
  }
}

String _$scriptActionDatasourceHash() =>
    r'10eee129ac4a88d4ff79024642e305e6516b8e2f';

@ProviderFor(scriptActionRepository)
const scriptActionRepositoryProvider = ScriptActionRepositoryProvider._();

final class ScriptActionRepositoryProvider
    extends
        $FunctionalProvider<
          ScriptActionRepository,
          ScriptActionRepository,
          ScriptActionRepository
        >
    with $Provider<ScriptActionRepository> {
  const ScriptActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScriptActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScriptActionRepository create(Ref ref) {
    return scriptActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptActionRepository>(value),
    );
  }
}

String _$scriptActionRepositoryHash() =>
    r'a7468e1abd6cdc379a2f27cef5b618236f52d9db';

/// 弹文件选择器导入 .js;成功后 invalidate 列表。用户取消返回 null。

@ProviderFor(importScript)
const importScriptProvider = ImportScriptProvider._();

/// 弹文件选择器导入 .js;成功后 invalidate 列表。用户取消返回 null。

final class ImportScriptProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 弹文件选择器导入 .js;成功后 invalidate 列表。用户取消返回 null。
  const ImportScriptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importScriptProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importScriptHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return importScript(ref);
  }
}

String _$importScriptHash() => r'57613474ab8ec65415b3e9e00046797c01264a67';

@ProviderFor(deleteScripts)
const deleteScriptsProvider = DeleteScriptsFamily._();

final class DeleteScriptsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const DeleteScriptsProvider._({
    required DeleteScriptsFamily super.from,
    required Iterable<String> super.argument,
  }) : super(
         retry: null,
         name: r'deleteScriptsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteScriptsHash();

  @override
  String toString() {
    return r'deleteScriptsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as Iterable<String>;
    return deleteScripts(ref, ids: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteScriptsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteScriptsHash() => r'8fe75743dfc90b36ae1906ed99c5407f5ae411ea';

final class DeleteScriptsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, Iterable<String>> {
  const DeleteScriptsFamily._()
    : super(
        retry: null,
        name: r'deleteScriptsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteScriptsProvider call({required Iterable<String> ids}) =>
      DeleteScriptsProvider._(argument: ids, from: this);

  @override
  String toString() => r'deleteScriptsProvider';
}

@ProviderFor(setScriptsEnabled)
const setScriptsEnabledProvider = SetScriptsEnabledFamily._();

final class SetScriptsEnabledProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const SetScriptsEnabledProvider._({
    required SetScriptsEnabledFamily super.from,
    required ({Iterable<String> ids, bool enabled}) super.argument,
  }) : super(
         retry: null,
         name: r'setScriptsEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setScriptsEnabledHash();

  @override
  String toString() {
    return r'setScriptsEnabledProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ({Iterable<String> ids, bool enabled});
    return setScriptsEnabled(ref, ids: argument.ids, enabled: argument.enabled);
  }

  @override
  bool operator ==(Object other) {
    return other is SetScriptsEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setScriptsEnabledHash() => r'105f7c02b63cf4450ba6efd8334a8d23820ce9b3';

final class SetScriptsEnabledFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({Iterable<String> ids, bool enabled})
        > {
  const SetScriptsEnabledFamily._()
    : super(
        retry: null,
        name: r'setScriptsEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetScriptsEnabledProvider call({
    required Iterable<String> ids,
    required bool enabled,
  }) => SetScriptsEnabledProvider._(
    argument: (ids: ids, enabled: enabled),
    from: this,
  );

  @override
  String toString() => r'setScriptsEnabledProvider';
}

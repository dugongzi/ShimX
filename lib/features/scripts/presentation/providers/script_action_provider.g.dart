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

/// 弹文件选择器导入 .js。用户取消返回 null。
///
/// 注:副作用(invalidate scriptsProvider)由调用方在 `await` 后自己触发。
/// 因为 `@riverpod Future<T>` action provider 在 `.future` 完成后会被立刻
/// dispose,在里头 `ref.invalidate` 会命中 "Ref after disposed" 断言。

@ProviderFor(importScript)
const importScriptProvider = ImportScriptProvider._();

/// 弹文件选择器导入 .js。用户取消返回 null。
///
/// 注:副作用(invalidate scriptsProvider)由调用方在 `await` 后自己触发。
/// 因为 `@riverpod Future<T>` action provider 在 `.future` 完成后会被立刻
/// dispose,在里头 `ref.invalidate` 会命中 "Ref after disposed" 断言。

final class ImportScriptProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 弹文件选择器导入 .js。用户取消返回 null。
  ///
  /// 注:副作用(invalidate scriptsProvider)由调用方在 `await` 后自己触发。
  /// 因为 `@riverpod Future<T>` action provider 在 `.future` 完成后会被立刻
  /// dispose,在里头 `ref.invalidate` 会命中 "Ref after disposed" 断言。
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

String _$importScriptHash() => r'36def23d801ccb0a9c6392bae65824ff29fcb092';

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

String _$deleteScriptsHash() => r'a2f183cd73c44d565c006026aecf22d646446fbd';

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

String _$setScriptsEnabledHash() => r'ec2fb02da469af555158aa3c835eb1a049a8e033';

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

/// 保存脚本代码。返回 false 表示文件不存在。

@ProviderFor(saveScript)
const saveScriptProvider = SaveScriptFamily._();

/// 保存脚本代码。返回 false 表示文件不存在。

final class SaveScriptProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 保存脚本代码。返回 false 表示文件不存在。
  const SaveScriptProvider._({
    required SaveScriptFamily super.from,
    required ({String id, String code}) super.argument,
  }) : super(
         retry: null,
         name: r'saveScriptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saveScriptHash();

  @override
  String toString() {
    return r'saveScriptProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as ({String id, String code});
    return saveScript(ref, id: argument.id, code: argument.code);
  }

  @override
  bool operator ==(Object other) {
    return other is SaveScriptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saveScriptHash() => r'da52dcb7186babc2c4901a833c3cb662dff60b8f';

/// 保存脚本代码。返回 false 表示文件不存在。

final class SaveScriptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, ({String id, String code})> {
  const SaveScriptFamily._()
    : super(
        retry: null,
        name: r'saveScriptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 保存脚本代码。返回 false 表示文件不存在。

  SaveScriptProvider call({required String id, required String code}) =>
      SaveScriptProvider._(argument: (id: id, code: code), from: this);

  @override
  String toString() => r'saveScriptProvider';
}

/// 创建新脚本。返回写入的文件名(id)。

@ProviderFor(createScript)
const createScriptProvider = CreateScriptFamily._();

/// 创建新脚本。返回写入的文件名(id)。

final class CreateScriptProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 创建新脚本。返回写入的文件名(id)。
  const CreateScriptProvider._({
    required CreateScriptFamily super.from,
    required ({String name, String code}) super.argument,
  }) : super(
         retry: null,
         name: r'createScriptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createScriptHash();

  @override
  String toString() {
    return r'createScriptProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as ({String name, String code});
    return createScript(ref, name: argument.name, code: argument.code);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateScriptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createScriptHash() => r'e54de24e5d3a228e8dafb788cce561bd7b002477';

/// 创建新脚本。返回写入的文件名(id)。

final class CreateScriptFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String>,
          ({String name, String code})
        > {
  const CreateScriptFamily._()
    : super(
        retry: null,
        name: r'createScriptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 创建新脚本。返回写入的文件名(id)。

  CreateScriptProvider call({required String name, required String code}) =>
      CreateScriptProvider._(argument: (name: name, code: code), from: this);

  @override
  String toString() => r'createScriptProvider';
}

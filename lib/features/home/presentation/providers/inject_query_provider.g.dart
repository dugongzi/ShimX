// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inject_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(injectQueryDatasource)
const injectQueryDatasourceProvider = InjectQueryDatasourceProvider._();

final class InjectQueryDatasourceProvider
    extends
        $FunctionalProvider<
          InjectQueryDatasource,
          InjectQueryDatasource,
          InjectQueryDatasource
        >
    with $Provider<InjectQueryDatasource> {
  const InjectQueryDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'injectQueryDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$injectQueryDatasourceHash();

  @$internal
  @override
  $ProviderElement<InjectQueryDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InjectQueryDatasource create(Ref ref) {
    return injectQueryDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InjectQueryDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InjectQueryDatasource>(value),
    );
  }
}

String _$injectQueryDatasourceHash() =>
    r'6082269eb18057c5cacabbbc18edbb61ed0cd1f0';

@ProviderFor(injectQueryRepository)
const injectQueryRepositoryProvider = InjectQueryRepositoryProvider._();

final class InjectQueryRepositoryProvider
    extends
        $FunctionalProvider<
          InjectQueryRepository,
          InjectQueryRepository,
          InjectQueryRepository
        >
    with $Provider<InjectQueryRepository> {
  const InjectQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'injectQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$injectQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InjectQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InjectQueryRepository create(Ref ref) {
    return injectQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InjectQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InjectQueryRepository>(value),
    );
  }
}

String _$injectQueryRepositoryHash() =>
    r'044042fd2f000088dcfc252110b5dd41d33285de';

@ProviderFor(isDebugPortAlive)
const isDebugPortAliveProvider = IsDebugPortAliveFamily._();

final class IsDebugPortAliveProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsDebugPortAliveProvider._({
    required IsDebugPortAliveFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'isDebugPortAliveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isDebugPortAliveHash();

  @override
  String toString() {
    return r'isDebugPortAliveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return isDebugPortAlive(ref, debugPort: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDebugPortAliveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isDebugPortAliveHash() => r'ce4dbb2120d540a66f15f962635ecd4c24e905c1';

final class IsDebugPortAliveFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  const IsDebugPortAliveFamily._()
    : super(
        retry: null,
        name: r'isDebugPortAliveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsDebugPortAliveProvider call({required int debugPort}) =>
      IsDebugPortAliveProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'isDebugPortAliveProvider';
}

/// 找到 devtools URL → 用系统浏览器打开。
/// 未找到时抛 [CodexNotRunningException],widget 层翻译为 l10n.codexNotRunningError。

@ProviderFor(openInspector)
const openInspectorProvider = OpenInspectorFamily._();

/// 找到 devtools URL → 用系统浏览器打开。
/// 未找到时抛 [CodexNotRunningException],widget 层翻译为 l10n.codexNotRunningError。

final class OpenInspectorProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 找到 devtools URL → 用系统浏览器打开。
  /// 未找到时抛 [CodexNotRunningException],widget 层翻译为 l10n.codexNotRunningError。
  const OpenInspectorProvider._({
    required OpenInspectorFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'openInspectorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$openInspectorHash();

  @override
  String toString() {
    return r'openInspectorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return openInspector(ref, debugPort: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OpenInspectorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openInspectorHash() => r'a635e88b53e2fa8656dfc1f6d3db6bc667e13d7f';

/// 找到 devtools URL → 用系统浏览器打开。
/// 未找到时抛 [CodexNotRunningException],widget 层翻译为 l10n.codexNotRunningError。

final class OpenInspectorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  const OpenInspectorFamily._()
    : super(
        retry: null,
        name: r'openInspectorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 找到 devtools URL → 用系统浏览器打开。
  /// 未找到时抛 [CodexNotRunningException],widget 层翻译为 l10n.codexNotRunningError。

  OpenInspectorProvider call({required int debugPort}) =>
      OpenInspectorProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'openInspectorProvider';
}

@ProviderFor(waitForDebugPort)
const waitForDebugPortProvider = WaitForDebugPortFamily._();

final class WaitForDebugPortProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const WaitForDebugPortProvider._({
    required WaitForDebugPortFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'waitForDebugPortProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$waitForDebugPortHash();

  @override
  String toString() {
    return r'waitForDebugPortProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return waitForDebugPort(ref, debugPort: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WaitForDebugPortProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$waitForDebugPortHash() => r'9056e447030cb68298ac4f842400d3897f21046b';

final class WaitForDebugPortFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  const WaitForDebugPortFamily._()
    : super(
        retry: null,
        name: r'waitForDebugPortProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WaitForDebugPortProvider call({required int debugPort}) =>
      WaitForDebugPortProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'waitForDebugPortProvider';
}

@ProviderFor(loadInjectScript)
const loadInjectScriptProvider = LoadInjectScriptProvider._();

final class LoadInjectScriptProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const LoadInjectScriptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadInjectScriptProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadInjectScriptHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return loadInjectScript(ref);
  }
}

String _$loadInjectScriptHash() => r'70f72b84ee6e22054d63516fec9d87bec9b49cd7';

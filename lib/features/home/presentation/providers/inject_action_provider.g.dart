// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inject_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(injectActionDatasource)
const injectActionDatasourceProvider = InjectActionDatasourceProvider._();

final class InjectActionDatasourceProvider
    extends
        $FunctionalProvider<
          InjectActionDatasource,
          InjectActionDatasource,
          InjectActionDatasource
        >
    with $Provider<InjectActionDatasource> {
  const InjectActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'injectActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$injectActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<InjectActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InjectActionDatasource create(Ref ref) {
    return injectActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InjectActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InjectActionDatasource>(value),
    );
  }
}

String _$injectActionDatasourceHash() =>
    r'ba24ef75681fa6f09db3b94f6526603aefaff074';

@ProviderFor(injectActionRepository)
const injectActionRepositoryProvider = InjectActionRepositoryProvider._();

final class InjectActionRepositoryProvider
    extends
        $FunctionalProvider<
          InjectActionRepository,
          InjectActionRepository,
          InjectActionRepository
        >
    with $Provider<InjectActionRepository> {
  const InjectActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'injectActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$injectActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<InjectActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InjectActionRepository create(Ref ref) {
    return injectActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InjectActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InjectActionRepository>(value),
    );
  }
}

String _$injectActionRepositoryHash() =>
    r'ed4671c248cbafb86a09b05302d35c9d7ecee212';

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

String _$isDebugPortAliveHash() => r'd9e0a0f5c70e9613650ed7767c0c734467f4a527';

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

@ProviderFor(openInspector)
const openInspectorProvider = OpenInspectorFamily._();

final class OpenInspectorProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
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

String _$openInspectorHash() => r'dbcc589edf91019e09b14820c81e4b8708740d3e';

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

String _$waitForDebugPortHash() => r'e3ae77d0f76beeb66e9e49bf9760b522a77c7b30';

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

String _$loadInjectScriptHash() => r'3e72081d0ec98feb8821f6d39217503072b40fbb';

/// 直接注入到端口（要求端口上已经有 page），建立 CDP 长连接并安装 bridge + 脚本

@ProviderFor(injectToRunningPort)
const injectToRunningPortProvider = InjectToRunningPortFamily._();

/// 直接注入到端口（要求端口上已经有 page），建立 CDP 长连接并安装 bridge + 脚本

final class InjectToRunningPortProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 直接注入到端口（要求端口上已经有 page），建立 CDP 长连接并安装 bridge + 脚本
  const InjectToRunningPortProvider._({
    required InjectToRunningPortFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'injectToRunningPortProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$injectToRunningPortHash();

  @override
  String toString() {
    return r'injectToRunningPortProvider'
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
    return injectToRunningPort(ref, debugPort: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InjectToRunningPortProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$injectToRunningPortHash() =>
    r'a854d7b8822bcf3e9ce56be1b5e16dfdb37b6d67';

/// 直接注入到端口（要求端口上已经有 page），建立 CDP 长连接并安装 bridge + 脚本

final class InjectToRunningPortFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  const InjectToRunningPortFamily._()
    : super(
        retry: null,
        name: r'injectToRunningPortProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 直接注入到端口（要求端口上已经有 page），建立 CDP 长连接并安装 bridge + 脚本

  InjectToRunningPortProvider call({required int debugPort}) =>
      InjectToRunningPortProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'injectToRunningPortProvider';
}

/// 完整流程：
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex（Windows: COM 激活 UWP；macOS: open .app）→ 等就绪 → 注入
///
/// Codex 未安装时抛 CodexNotInstalledException

@ProviderFor(launchAndInject)
const launchAndInjectProvider = LaunchAndInjectFamily._();

/// 完整流程：
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex（Windows: COM 激活 UWP；macOS: open .app）→ 等就绪 → 注入
///
/// Codex 未安装时抛 CodexNotInstalledException

final class LaunchAndInjectProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 完整流程：
  /// - 端口活 → 直接连上现有 Codex 并注入
  /// - 端口不活 → 自动发现 + 启动 Codex（Windows: COM 激活 UWP；macOS: open .app）→ 等就绪 → 注入
  ///
  /// Codex 未安装时抛 CodexNotInstalledException
  const LaunchAndInjectProvider._({
    required LaunchAndInjectFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'launchAndInjectProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$launchAndInjectHash();

  @override
  String toString() {
    return r'launchAndInjectProvider'
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
    return launchAndInject(ref, debugPort: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LaunchAndInjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$launchAndInjectHash() => r'6a3007ae2a7905fb57d29c55ad91d33784b22c65';

/// 完整流程：
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex（Windows: COM 激活 UWP；macOS: open .app）→ 等就绪 → 注入
///
/// Codex 未安装时抛 CodexNotInstalledException

final class LaunchAndInjectFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  const LaunchAndInjectFamily._()
    : super(
        retry: null,
        name: r'launchAndInjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// 完整流程：
  /// - 端口活 → 直接连上现有 Codex 并注入
  /// - 端口不活 → 自动发现 + 启动 Codex（Windows: COM 激活 UWP；macOS: open .app）→ 等就绪 → 注入
  ///
  /// Codex 未安装时抛 CodexNotInstalledException

  LaunchAndInjectProvider call({required int debugPort}) =>
      LaunchAndInjectProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'launchAndInjectProvider';
}

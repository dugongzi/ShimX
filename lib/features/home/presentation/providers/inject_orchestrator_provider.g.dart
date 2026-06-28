// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inject_orchestrator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。

@ProviderFor(injectToRunningPort)
const injectToRunningPortProvider = InjectToRunningPortFamily._();

/// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。

final class InjectToRunningPortProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。
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
    r'c7a5f8d7b8f5861571e4c2d3524df46e976d0668';

/// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。

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

  /// 直接注入到端口(要求端口上已经有 page),建立 CDP 长连接并安装 bridge + 脚本。

  InjectToRunningPortProvider call({required int debugPort}) =>
      InjectToRunningPortProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'injectToRunningPortProvider';
}

/// 完整流程:
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
///
/// Codex 未安装时抛 [CodexNotInstalledException]。

@ProviderFor(launchAndInject)
const launchAndInjectProvider = LaunchAndInjectFamily._();

/// 完整流程:
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
///
/// Codex 未安装时抛 [CodexNotInstalledException]。

final class LaunchAndInjectProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 完整流程:
  /// - 端口活 → 直接连上现有 Codex 并注入
  /// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
  ///
  /// Codex 未安装时抛 [CodexNotInstalledException]。
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

String _$launchAndInjectHash() => r'2ab6d1de68c04b7b8dab4504d573ecb7640964d5';

/// 完整流程:
/// - 端口活 → 直接连上现有 Codex 并注入
/// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
///
/// Codex 未安装时抛 [CodexNotInstalledException]。

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

  /// 完整流程:
  /// - 端口活 → 直接连上现有 Codex 并注入
  /// - 端口不活 → 自动发现 + 启动 Codex(Windows: COM 激活 UWP;macOS: open .app)→ 等就绪 → 注入
  ///
  /// Codex 未安装时抛 [CodexNotInstalledException]。

  LaunchAndInjectProvider call({required int debugPort}) =>
      LaunchAndInjectProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'launchAndInjectProvider';
}

/// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
/// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。

@ProviderFor(reloadCodexAndReinject)
const reloadCodexAndReinjectProvider = ReloadCodexAndReinjectFamily._();

/// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
/// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。

final class ReloadCodexAndReinjectProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
  /// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。
  const ReloadCodexAndReinjectProvider._({
    required ReloadCodexAndReinjectFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'reloadCodexAndReinjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reloadCodexAndReinjectHash();

  @override
  String toString() {
    return r'reloadCodexAndReinjectProvider'
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
    return reloadCodexAndReinject(ref, debugPort: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReloadCodexAndReinjectProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reloadCodexAndReinjectHash() =>
    r'3aaa421a300e7e1eb8fbdcf0835169eff357c9f2';

/// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
/// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。

final class ReloadCodexAndReinjectFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  const ReloadCodexAndReinjectFamily._()
    : super(
        retry: null,
        name: r'reloadCodexAndReinjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 已注入状态下手动刷新 Codex 页面 + 重新装 bridge + 重跑脚本。
  /// 与 [injectToRunningPort] 区别:这里会先调用 `cdp.reloadPage()`,清掉旧 page 上的脚本副作用。

  ReloadCodexAndReinjectProvider call({required int debugPort}) =>
      ReloadCodexAndReinjectProvider._(argument: debugPort, from: this);

  @override
  String toString() => r'reloadCodexAndReinjectProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'takeover_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 启动时自动接管:app 起来就 watch 一次,按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。

@ProviderFor(proxyAutoStart)
const proxyAutoStartProvider = ProxyAutoStartProvider._();

/// 启动时自动接管:app 起来就 watch 一次,按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。

final class ProxyAutoStartProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 启动时自动接管:app 起来就 watch 一次,按持久化的开关状态自动起代理。
  /// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。
  const ProxyAutoStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyAutoStartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyAutoStartHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return proxyAutoStart(ref);
  }
}

String _$proxyAutoStartHash() => r'973f32c132a08a8c53a23a1c2ea3fe46ff9a1633';

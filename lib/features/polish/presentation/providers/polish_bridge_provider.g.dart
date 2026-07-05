// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polish_bridge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 注册文本润色的 bridge 路由。
///
/// `/polish/text` payload: `{ text: string, instruction: string }`
///                   → `{ polished: string }`
///
/// instruction 是「更简洁」/「更正式」/「更口语」/「更详细」之类的短语,
/// JS 侧不做校验, dart 也不做校验(纯 pass-through 到 datasource)。

@ProviderFor(polishBridgeRouteRegistration)
const polishBridgeRouteRegistrationProvider =
    PolishBridgeRouteRegistrationProvider._();

/// 注册文本润色的 bridge 路由。
///
/// `/polish/text` payload: `{ text: string, instruction: string }`
///                   → `{ polished: string }`
///
/// instruction 是「更简洁」/「更正式」/「更口语」/「更详细」之类的短语,
/// JS 侧不做校验, dart 也不做校验(纯 pass-through 到 datasource)。

final class PolishBridgeRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册文本润色的 bridge 路由。
  ///
  /// `/polish/text` payload: `{ text: string, instruction: string }`
  ///                   → `{ polished: string }`
  ///
  /// instruction 是「更简洁」/「更正式」/「更口语」/「更详细」之类的短语,
  /// JS 侧不做校验, dart 也不做校验(纯 pass-through 到 datasource)。
  const PolishBridgeRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'polishBridgeRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$polishBridgeRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return polishBridgeRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$polishBridgeRouteRegistrationHash() =>
    r'7d00d2f0a3aea1fa9fb2e57479da7efe41753f09';

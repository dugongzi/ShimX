// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_action_bridge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 注册 JS 侧供应商/模型选择路由。
///
/// /provider/list                  列出全部供应商 + 当前选中 + reasoningEffort + i18n labels
/// /provider/select                选择供应商
/// /provider/select-model          切换某供应商的模型
/// /provider/set-reasoning-effort  写思考深度

@ProviderFor(providerActionRouteRegistration)
const providerActionRouteRegistrationProvider =
    ProviderActionRouteRegistrationProvider._();

/// 注册 JS 侧供应商/模型选择路由。
///
/// /provider/list                  列出全部供应商 + 当前选中 + reasoningEffort + i18n labels
/// /provider/select                选择供应商
/// /provider/select-model          切换某供应商的模型
/// /provider/set-reasoning-effort  写思考深度

final class ProviderActionRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册 JS 侧供应商/模型选择路由。
  ///
  /// /provider/list                  列出全部供应商 + 当前选中 + reasoningEffort + i18n labels
  /// /provider/select                选择供应商
  /// /provider/select-model          切换某供应商的模型
  /// /provider/set-reasoning-effort  写思考深度
  const ProviderActionRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerActionRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerActionRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return providerActionRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$providerActionRouteRegistrationHash() =>
    r'cefe7452fc7d5f8ff8502053af10a58df624754c';

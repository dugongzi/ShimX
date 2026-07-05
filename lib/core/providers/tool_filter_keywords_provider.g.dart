// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_filter_keywords_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 请求 body tools 数组过滤关键词。
///
/// 命中判定:tools 里每一项的 `type` 或 `name` 若等于列表中任何一个 **enabled** 关键词,
/// 就会在转发前被剔除。disabled 的关键词保留在列表里但不参与过滤。
///
/// 默认包含 enabled 的 `image_generation`,因为 codex app-server(VSCode 插件、桌面 App)
/// 识别到官方 ChatGPT 登录态时会无条件把它塞进 tools,让不支持图片生成的中转站
/// 直接 403 Forbidden。参考 openai/codex#21952。

@ProviderFor(ToolFilterKeywordsNotifier)
const toolFilterKeywordsProvider = ToolFilterKeywordsNotifierProvider._();

/// 请求 body tools 数组过滤关键词。
///
/// 命中判定:tools 里每一项的 `type` 或 `name` 若等于列表中任何一个 **enabled** 关键词,
/// 就会在转发前被剔除。disabled 的关键词保留在列表里但不参与过滤。
///
/// 默认包含 enabled 的 `image_generation`,因为 codex app-server(VSCode 插件、桌面 App)
/// 识别到官方 ChatGPT 登录态时会无条件把它塞进 tools,让不支持图片生成的中转站
/// 直接 403 Forbidden。参考 openai/codex#21952。
final class ToolFilterKeywordsNotifierProvider
    extends
        $NotifierProvider<ToolFilterKeywordsNotifier, List<ToolFilterKeyword>> {
  /// 请求 body tools 数组过滤关键词。
  ///
  /// 命中判定:tools 里每一项的 `type` 或 `name` 若等于列表中任何一个 **enabled** 关键词,
  /// 就会在转发前被剔除。disabled 的关键词保留在列表里但不参与过滤。
  ///
  /// 默认包含 enabled 的 `image_generation`,因为 codex app-server(VSCode 插件、桌面 App)
  /// 识别到官方 ChatGPT 登录态时会无条件把它塞进 tools,让不支持图片生成的中转站
  /// 直接 403 Forbidden。参考 openai/codex#21952。
  const ToolFilterKeywordsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toolFilterKeywordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toolFilterKeywordsNotifierHash();

  @$internal
  @override
  ToolFilterKeywordsNotifier create() => ToolFilterKeywordsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ToolFilterKeyword> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ToolFilterKeyword>>(value),
    );
  }
}

String _$toolFilterKeywordsNotifierHash() =>
    r'b999a5ffbbcf197058a065e8a1ccc23938c37386';

/// 请求 body tools 数组过滤关键词。
///
/// 命中判定:tools 里每一项的 `type` 或 `name` 若等于列表中任何一个 **enabled** 关键词,
/// 就会在转发前被剔除。disabled 的关键词保留在列表里但不参与过滤。
///
/// 默认包含 enabled 的 `image_generation`,因为 codex app-server(VSCode 插件、桌面 App)
/// 识别到官方 ChatGPT 登录态时会无条件把它塞进 tools,让不支持图片生成的中转站
/// 直接 403 Forbidden。参考 openai/codex#21952。

abstract class _$ToolFilterKeywordsNotifier
    extends $Notifier<List<ToolFilterKeyword>> {
  List<ToolFilterKeyword> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<List<ToolFilterKeyword>, List<ToolFilterKeyword>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ToolFilterKeyword>, List<ToolFilterKeyword>>,
              List<ToolFilterKeyword>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 把工具过滤关键词的 get/set 注册到 bridge,让注入 codex 页面里的 JS 也能读写。
///
/// /tool-filter/get — 读当前列表 + i18n labels
/// /tool-filter/add — { keyword: string }
/// /tool-filter/remove — { keyword: string }
/// /tool-filter/toggle — { keyword: string, enabled: bool }

@ProviderFor(toolFilterRouteRegistration)
const toolFilterRouteRegistrationProvider =
    ToolFilterRouteRegistrationProvider._();

/// 把工具过滤关键词的 get/set 注册到 bridge,让注入 codex 页面里的 JS 也能读写。
///
/// /tool-filter/get — 读当前列表 + i18n labels
/// /tool-filter/add — { keyword: string }
/// /tool-filter/remove — { keyword: string }
/// /tool-filter/toggle — { keyword: string, enabled: bool }

final class ToolFilterRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把工具过滤关键词的 get/set 注册到 bridge,让注入 codex 页面里的 JS 也能读写。
  ///
  /// /tool-filter/get — 读当前列表 + i18n labels
  /// /tool-filter/add — { keyword: string }
  /// /tool-filter/remove — { keyword: string }
  /// /tool-filter/toggle — { keyword: string, enabled: bool }
  const ToolFilterRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toolFilterRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toolFilterRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return toolFilterRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$toolFilterRouteRegistrationHash() =>
    r'80f7fab97490c52d513714ddb0e942d2b5cbaf60';

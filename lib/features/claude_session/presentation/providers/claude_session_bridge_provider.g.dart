// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_session_bridge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 把 Claude 会话查询路由注册到 bridge,供 codex_enhance.js 的侧栏折叠列表调用。
///
/// /claude-session/projects        → 列出全部 Claude Code 项目分组
/// /claude-session/threads         → payload.encodedDir 必填,列该项目下会话

@ProviderFor(claudeSessionRouteRegistration)
const claudeSessionRouteRegistrationProvider =
    ClaudeSessionRouteRegistrationProvider._();

/// 把 Claude 会话查询路由注册到 bridge,供 codex_enhance.js 的侧栏折叠列表调用。
///
/// /claude-session/projects        → 列出全部 Claude Code 项目分组
/// /claude-session/threads         → payload.encodedDir 必填,列该项目下会话

final class ClaudeSessionRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把 Claude 会话查询路由注册到 bridge,供 codex_enhance.js 的侧栏折叠列表调用。
  ///
  /// /claude-session/projects        → 列出全部 Claude Code 项目分组
  /// /claude-session/threads         → payload.encodedDir 必填,列该项目下会话
  const ClaudeSessionRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claudeSessionRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claudeSessionRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return claudeSessionRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$claudeSessionRouteRegistrationHash() =>
    r'47179e0e53376e61f17a422f425c9bb723cf2f58';

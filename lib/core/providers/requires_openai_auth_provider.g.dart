// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requires_openai_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `~/.codex/config.toml` 里 `[model_providers.*]` 段的 `requires_openai_auth` 字段。
///
/// - true:走 `auth.json` 里的 OpenAI 官方登录。
/// - false:不使用官方 auth,由 provider 自己的 config 提供凭据。
///
/// 状态直接反映磁盘上的真实值。改开关会立刻改写 config.toml,重启 codex 生效。

@ProviderFor(RequiresOpenaiAuthNotifier)
const requiresOpenaiAuthProvider = RequiresOpenaiAuthNotifierProvider._();

/// `~/.codex/config.toml` 里 `[model_providers.*]` 段的 `requires_openai_auth` 字段。
///
/// - true:走 `auth.json` 里的 OpenAI 官方登录。
/// - false:不使用官方 auth,由 provider 自己的 config 提供凭据。
///
/// 状态直接反映磁盘上的真实值。改开关会立刻改写 config.toml,重启 codex 生效。
final class RequiresOpenaiAuthNotifierProvider
    extends $NotifierProvider<RequiresOpenaiAuthNotifier, bool> {
  /// `~/.codex/config.toml` 里 `[model_providers.*]` 段的 `requires_openai_auth` 字段。
  ///
  /// - true:走 `auth.json` 里的 OpenAI 官方登录。
  /// - false:不使用官方 auth,由 provider 自己的 config 提供凭据。
  ///
  /// 状态直接反映磁盘上的真实值。改开关会立刻改写 config.toml,重启 codex 生效。
  const RequiresOpenaiAuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requiresOpenaiAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requiresOpenaiAuthNotifierHash();

  @$internal
  @override
  RequiresOpenaiAuthNotifier create() => RequiresOpenaiAuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$requiresOpenaiAuthNotifierHash() =>
    r'c7925fa75e3100dc07e8431f8cbbd1edba4366aa';

/// `~/.codex/config.toml` 里 `[model_providers.*]` 段的 `requires_openai_auth` 字段。
///
/// - true:走 `auth.json` 里的 OpenAI 官方登录。
/// - false:不使用官方 auth,由 provider 自己的 config 提供凭据。
///
/// 状态直接反映磁盘上的真实值。改开关会立刻改写 config.toml,重启 codex 生效。

abstract class _$RequiresOpenaiAuthNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_launch_target_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// codex 客户端的启动目标用户覆盖。留空 = 走 launcher 内置默认。
/// - macOS: 存 `.app` 完整路径,例如 `/Applications/ChatGPT.app`。
/// - Windows: 存 Get-AppxPackage 的 -Name 通配符,例如 `OpenAI.ChatGPT*`。
///
/// 官方 codex 已从 Codex 更名为 ChatGPT,不同版本/发行渠道的名字可能再变;
/// 用户可以在设置里自己填,shim 立即用。

@ProviderFor(CodexLaunchTargetNotifier)
const codexLaunchTargetProvider = CodexLaunchTargetNotifierProvider._();

/// codex 客户端的启动目标用户覆盖。留空 = 走 launcher 内置默认。
/// - macOS: 存 `.app` 完整路径,例如 `/Applications/ChatGPT.app`。
/// - Windows: 存 Get-AppxPackage 的 -Name 通配符,例如 `OpenAI.ChatGPT*`。
///
/// 官方 codex 已从 Codex 更名为 ChatGPT,不同版本/发行渠道的名字可能再变;
/// 用户可以在设置里自己填,shim 立即用。
final class CodexLaunchTargetNotifierProvider
    extends $NotifierProvider<CodexLaunchTargetNotifier, String> {
  /// codex 客户端的启动目标用户覆盖。留空 = 走 launcher 内置默认。
  /// - macOS: 存 `.app` 完整路径,例如 `/Applications/ChatGPT.app`。
  /// - Windows: 存 Get-AppxPackage 的 -Name 通配符,例如 `OpenAI.ChatGPT*`。
  ///
  /// 官方 codex 已从 Codex 更名为 ChatGPT,不同版本/发行渠道的名字可能再变;
  /// 用户可以在设置里自己填,shim 立即用。
  const CodexLaunchTargetNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexLaunchTargetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexLaunchTargetNotifierHash();

  @$internal
  @override
  CodexLaunchTargetNotifier create() => CodexLaunchTargetNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$codexLaunchTargetNotifierHash() =>
    r'4f056d58250b12e7ca0cf99c1f045be65a192987';

/// codex 客户端的启动目标用户覆盖。留空 = 走 launcher 内置默认。
/// - macOS: 存 `.app` 完整路径,例如 `/Applications/ChatGPT.app`。
/// - Windows: 存 Get-AppxPackage 的 -Name 通配符,例如 `OpenAI.ChatGPT*`。
///
/// 官方 codex 已从 Codex 更名为 ChatGPT,不同版本/发行渠道的名字可能再变;
/// 用户可以在设置里自己填,shim 立即用。

abstract class _$CodexLaunchTargetNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

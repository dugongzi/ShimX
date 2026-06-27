// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_session_import_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 注册导入路由。
///
/// /session/import         — 弹文件选择器 (.jsonl), 把单条 rollout 导入到 codex。
///   payload.targetCwd     可选, 把导入的 thread 强制归到该 cwd; 不传则保留 rollout 自带 cwd。
///
/// /session/import-bundle  — 弹文件选择器 (.zip), 解压后批量导入。zip 里所有 .jsonl 都试着当 rollout 解析。
///   payload.targetCwd     同上, 应用到 zip 内所有条目。

@ProviderFor(codexSessionImportRouteRegistration)
const codexSessionImportRouteRegistrationProvider =
    CodexSessionImportRouteRegistrationProvider._();

/// 注册导入路由。
///
/// /session/import         — 弹文件选择器 (.jsonl), 把单条 rollout 导入到 codex。
///   payload.targetCwd     可选, 把导入的 thread 强制归到该 cwd; 不传则保留 rollout 自带 cwd。
///
/// /session/import-bundle  — 弹文件选择器 (.zip), 解压后批量导入。zip 里所有 .jsonl 都试着当 rollout 解析。
///   payload.targetCwd     同上, 应用到 zip 内所有条目。

final class CodexSessionImportRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 注册导入路由。
  ///
  /// /session/import         — 弹文件选择器 (.jsonl), 把单条 rollout 导入到 codex。
  ///   payload.targetCwd     可选, 把导入的 thread 强制归到该 cwd; 不传则保留 rollout 自带 cwd。
  ///
  /// /session/import-bundle  — 弹文件选择器 (.zip), 解压后批量导入。zip 里所有 .jsonl 都试着当 rollout 解析。
  ///   payload.targetCwd     同上, 应用到 zip 内所有条目。
  const CodexSessionImportRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionImportRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$codexSessionImportRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return codexSessionImportRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$codexSessionImportRouteRegistrationHash() =>
    r'40a60786071bc5eb7b6fed0ad8d47c56b9eabf16';

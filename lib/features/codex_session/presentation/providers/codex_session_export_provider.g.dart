// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_session_export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(codexSessionExportRepository)
const codexSessionExportRepositoryProvider =
    CodexSessionExportRepositoryProvider._();

final class CodexSessionExportRepositoryProvider
    extends
        $FunctionalProvider<
          CodexSessionExportRepository,
          CodexSessionExportRepository,
          CodexSessionExportRepository
        >
    with $Provider<CodexSessionExportRepository> {
  const CodexSessionExportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionExportRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$codexSessionExportRepositoryHash();

  @$internal
  @override
  $ProviderElement<CodexSessionExportRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CodexSessionExportRepository create(Ref ref) {
    return codexSessionExportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CodexSessionExportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CodexSessionExportRepository>(value),
    );
  }
}

String _$codexSessionExportRepositoryHash() =>
    r'e4bd458e52f43e3c926d8c0b7a7af93788c09985';

@ProviderFor(codexThreadDetail)
const codexThreadDetailProvider = CodexThreadDetailFamily._();

final class CodexThreadDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CodexThreadDetail>,
          CodexThreadDetail,
          FutureOr<CodexThreadDetail>
        >
    with
        $FutureModifier<CodexThreadDetail>,
        $FutureProvider<CodexThreadDetail> {
  const CodexThreadDetailProvider._({
    required CodexThreadDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'codexThreadDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$codexThreadDetailHash();

  @override
  String toString() {
    return r'codexThreadDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CodexThreadDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CodexThreadDetail> create(Ref ref) {
    final argument = this.argument as String;
    return codexThreadDetail(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CodexThreadDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$codexThreadDetailHash() => r'd18fc2ff1e30a072bf7f063e38b18eef14be5b08';

final class CodexThreadDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CodexThreadDetail>, String> {
  const CodexThreadDetailFamily._()
    : super(
        retry: null,
        name: r'codexThreadDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CodexThreadDetailProvider call({required String id}) =>
      CodexThreadDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'codexThreadDetailProvider';
}

/// 把导出会话路由注册到 bridge。
///
/// /session/export — 弹系统保存对话框 → 选完路径后真正写文件。
///   payload.id     thread id (required)
///   payload.format 'markdown' | 'raws' (required)

@ProviderFor(codexSessionExportRouteRegistration)
const codexSessionExportRouteRegistrationProvider =
    CodexSessionExportRouteRegistrationProvider._();

/// 把导出会话路由注册到 bridge。
///
/// /session/export — 弹系统保存对话框 → 选完路径后真正写文件。
///   payload.id     thread id (required)
///   payload.format 'markdown' | 'raws' (required)

final class CodexSessionExportRouteRegistrationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 把导出会话路由注册到 bridge。
  ///
  /// /session/export — 弹系统保存对话框 → 选完路径后真正写文件。
  ///   payload.id     thread id (required)
  ///   payload.format 'markdown' | 'raws' (required)
  const CodexSessionExportRouteRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'codexSessionExportRouteRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$codexSessionExportRouteRegistrationHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return codexSessionExportRouteRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$codexSessionExportRouteRegistrationHash() =>
    r'694950119bd859833f6557102b983c312a2c6438';

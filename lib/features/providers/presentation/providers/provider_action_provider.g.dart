// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providerActionRepository)
const providerActionRepositoryProvider = ProviderActionRepositoryProvider._();

final class ProviderActionRepositoryProvider
    extends
        $FunctionalProvider<
          ProviderActionRepository,
          ProviderActionRepository,
          ProviderActionRepository
        >
    with $Provider<ProviderActionRepository> {
  const ProviderActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProviderActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderActionRepository create(Ref ref) {
    return providerActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderActionRepository>(value),
    );
  }
}

String _$providerActionRepositoryHash() =>
    r'52fae25a25078a67d38c0aadcd1c47b3610796bd';

/// 新增供应商；列表为空时自动选中第一个加入项。

@ProviderFor(addProvider)
const addProviderProvider = AddProviderFamily._();

/// 新增供应商；列表为空时自动选中第一个加入项。

final class AddProviderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 新增供应商；列表为空时自动选中第一个加入项。
  const AddProviderProvider._({
    required AddProviderFamily super.from,
    required ApiProvider super.argument,
  }) : super(
         retry: null,
         name: r'addProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addProviderHash();

  @override
  String toString() {
    return r'addProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ApiProvider;
    return addProvider(ref, provider: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addProviderHash() => r'e7e63385fada5dcb6093501690248e979a30a95e';

/// 新增供应商；列表为空时自动选中第一个加入项。

final class AddProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, ApiProvider> {
  const AddProviderFamily._()
    : super(
        retry: null,
        name: r'addProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 新增供应商；列表为空时自动选中第一个加入项。

  AddProviderProvider call({required ApiProvider provider}) =>
      AddProviderProvider._(argument: provider, from: this);

  @override
  String toString() => r'addProviderProvider';
}

/// 更新供应商

@ProviderFor(updateProvider)
const updateProviderProvider = UpdateProviderFamily._();

/// 更新供应商

final class UpdateProviderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 更新供应商
  const UpdateProviderProvider._({
    required UpdateProviderFamily super.from,
    required ApiProvider super.argument,
  }) : super(
         retry: null,
         name: r'updateProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateProviderHash();

  @override
  String toString() {
    return r'updateProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ApiProvider;
    return updateProvider(ref, provider: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateProviderHash() => r'8f80b09f3ce33823bd13a9a923c82817480d4ed3';

/// 更新供应商

final class UpdateProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, ApiProvider> {
  const UpdateProviderFamily._()
    : super(
        retry: null,
        name: r'updateProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 更新供应商

  UpdateProviderProvider call({required ApiProvider provider}) =>
      UpdateProviderProvider._(argument: provider, from: this);

  @override
  String toString() => r'updateProviderProvider';
}

/// 删除供应商；删的是当前选中项则改选第一个剩余项。

@ProviderFor(removeProvider)
const removeProviderProvider = RemoveProviderFamily._();

/// 删除供应商；删的是当前选中项则改选第一个剩余项。

final class RemoveProviderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 删除供应商；删的是当前选中项则改选第一个剩余项。
  const RemoveProviderProvider._({
    required RemoveProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'removeProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$removeProviderHash();

  @override
  String toString() {
    return r'removeProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return removeProvider(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RemoveProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$removeProviderHash() => r'9561404970a4fbca588d5abbe8467aec87a48086';

/// 删除供应商；删的是当前选中项则改选第一个剩余项。

final class RemoveProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const RemoveProviderFamily._()
    : super(
        retry: null,
        name: r'removeProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 删除供应商；删的是当前选中项则改选第一个剩余项。

  RemoveProviderProvider call({required String id}) =>
      RemoveProviderProvider._(argument: id, from: this);

  @override
  String toString() => r'removeProviderProvider';
}

/// 选中供应商

@ProviderFor(selectProvider)
const selectProviderProvider = SelectProviderFamily._();

/// 选中供应商

final class SelectProviderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 选中供应商
  const SelectProviderProvider._({
    required SelectProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectProviderHash();

  @override
  String toString() {
    return r'selectProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return selectProvider(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectProviderHash() => r'e9ab73e605491149d536b162c18f689fc5622b74';

/// 选中供应商

final class SelectProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const SelectProviderFamily._()
    : super(
        retry: null,
        name: r'selectProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 选中供应商

  SelectProviderProvider call({required String id}) =>
      SelectProviderProvider._(argument: id, from: this);

  @override
  String toString() => r'selectProviderProvider';
}

/// 设置代理开关：写持久化后立即应用（开 → 接管，关 → 释放）。

@ProviderFor(setProxyEnabled)
const setProxyEnabledProvider = SetProxyEnabledFamily._();

/// 设置代理开关：写持久化后立即应用（开 → 接管，关 → 释放）。

final class SetProxyEnabledProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 设置代理开关：写持久化后立即应用（开 → 接管，关 → 释放）。
  const SetProxyEnabledProvider._({
    required SetProxyEnabledFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'setProxyEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setProxyEnabledHash();

  @override
  String toString() {
    return r'setProxyEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as bool;
    return setProxyEnabled(ref, enabled: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetProxyEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setProxyEnabledHash() => r'484dffa8de502de91932d886605a5a8223439688';

/// 设置代理开关：写持久化后立即应用（开 → 接管，关 → 释放）。

final class SetProxyEnabledFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, bool> {
  const SetProxyEnabledFamily._()
    : super(
        retry: null,
        name: r'setProxyEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 设置代理开关：写持久化后立即应用（开 → 接管，关 → 释放）。

  SetProxyEnabledProvider call({required bool enabled}) =>
      SetProxyEnabledProvider._(argument: enabled, from: this);

  @override
  String toString() => r'setProxyEnabledProvider';
}

/// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。

@ProviderFor(proxyAutoStart)
const proxyAutoStartProvider = ProxyAutoStartProvider._();

/// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
/// 开关开着且有选中供应商 → 起代理 + 设 target + 改 config.toml。

final class ProxyAutoStartProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 启动时自动接管：app 起来就 watch 一次，按持久化的开关状态自动起代理。
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

/// 设置代理端口

@ProviderFor(setProxyPort)
const setProxyPortProvider = SetProxyPortFamily._();

/// 设置代理端口

final class SetProxyPortProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 设置代理端口
  const SetProxyPortProvider._({
    required SetProxyPortFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'setProxyPortProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setProxyPortHash();

  @override
  String toString() {
    return r'setProxyPortProvider'
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
    return setProxyPort(ref, port: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetProxyPortProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setProxyPortHash() => r'045293f8702f1bf9545dbcf1a1fe9f3891e1c550';

/// 设置代理端口

final class SetProxyPortFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  const SetProxyPortFamily._()
    : super(
        retry: null,
        name: r'setProxyPortProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 设置代理端口

  SetProxyPortProvider call({required int port}) =>
      SetProxyPortProvider._(argument: port, from: this);

  @override
  String toString() => r'setProxyPortProvider';
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/providers/locale_provider.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/providers/data/datasources/provider_query_datasource.dart';
import 'package:shim/features/providers/data/repositories/provider_query_repository_impl.dart';
import 'package:shim/features/providers/domain/models/provider_list_state.dart';
import 'package:shim/features/providers/domain/models/proxy_config.dart';
import 'package:shim/features/providers/domain/repositories/provider_query_repository.dart';

part 'provider_query_provider.g.dart';

@riverpod
ProviderQueryRepository providerQueryRepository(Ref ref) {
  return ProviderQueryRepositoryImpl(
    dataSource: ProviderQueryDatasource(
      appStorage: ref.read(appStorageProvider),
    ),
  );
}

/// 供应商列表 + 当前选中项。action 写入后 invalidate 本 provider 刷新。
@riverpod
Future<ProviderListState> providerList(Ref ref) async {
  final repo = ref.read(providerQueryRepositoryProvider);
  final providers = await repo.listProviders();
  final selectedId = await repo.selectedId();
  return ProviderListState(providers: providers, selectedId: selectedId);
}

/// 本地代理配置（开关 + 端口）。action 写入后 invalidate 本 provider 刷新。
@riverpod
Future<ProxyConfig> proxyConfig(Ref ref) {
  return ref.read(providerQueryRepositoryProvider).proxyConfig();
}

/// 把供应商查询路由注册到 bridge。注入时 read 一次让它生效。
///
/// /provider/current — JS 拉当前生效的供应商，用于在对话上方渲染名称。
/// 返回 {name, label}：name 为供应商名（无则 null），label 为拼好语言前缀的
/// 完整文案（中「供应商：xxx」/ 英「Provider: xxx」）。语言跟随 Shim 本体设置，
/// 由 Dart 侧拼好交给 JS，JS 不处理语言逻辑。
@Riverpod(keepAlive: true)
bool providerRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final repo = ref.read(providerQueryRepositoryProvider);

  bridge.register('/provider/current', (payload) async {
    final name = await _currentProviderName(repo);
    if (name == null) {
      return {'name': null, 'label': null};
    }
    final isZh = ref.read(localeProvider).languageCode == 'zh';
    final label = isZh ? '供应商：$name' : 'Provider: $name';
    return {'name': name, 'label': label};
  });

  return true;
}

/// 当前生效的供应商名：代理接管开着且有选中项才返回，否则 null。
Future<String?> _currentProviderName(ProviderQueryRepository repo) async {
  final proxy = await repo.proxyConfig();
  if (!proxy.enabled) return null;
  final selectedId = await repo.selectedId();
  if (selectedId == null) return null;
  final providers = await repo.listProviders();
  for (final p in providers) {
    if (p.id == selectedId) return p.name;
  }
  return null;
}

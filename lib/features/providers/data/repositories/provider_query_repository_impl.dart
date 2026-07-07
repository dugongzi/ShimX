import 'package:shimx/features/providers/data/datasources/provider_query_datasource.dart';
import 'package:shimx/features/providers/domain/models/api_provider.dart';
import 'package:shimx/features/providers/domain/models/proxy_config.dart';
import 'package:shimx/features/providers/domain/repositories/provider_query_repository.dart';

class ProviderQueryRepositoryImpl implements ProviderQueryRepository {
  final ProviderQueryDatasource dataSource;

  ProviderQueryRepositoryImpl({required this.dataSource});

  @override
  Future<List<ApiProvider>> listProviders() async {
    final dtos = await dataSource.listProviders();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<String?> selectedId() {
    return dataSource.selectedId();
  }

  @override
  Future<ProxyConfig> proxyConfig() async {
    const defaults = ProxyConfig();
    final enabled = await dataSource.proxyEnabled() ?? defaults.enabled;
    final port = await dataSource.proxyPort() ?? defaults.port;
    return ProxyConfig(enabled: enabled, port: port);
  }

  @override
  Future<List<String>> fetchModels({
    required String baseUrl,
    required String apiKey,
  }) {
    return dataSource.fetchModels(baseUrl: baseUrl, apiKey: apiKey);
  }
}

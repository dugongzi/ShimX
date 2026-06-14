import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/proxy_config.dart';

abstract class ProviderQueryRepository {
  /// 列出全部供应商
  Future<List<ApiProvider>> listProviders();

  /// 读当前选中的供应商 id（无则 null）
  Future<String?> selectedId();

  /// 读本地代理配置（无则取默认值）
  Future<ProxyConfig> proxyConfig();

  /// 调供应商 /models 端点拉取可用模型 id 列表
  Future<List<String>> fetchModels({
    required String baseUrl,
    required String apiKey,
  });
}

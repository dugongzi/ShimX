import 'package:shim/features/providers/domain/models/api_provider.dart';

abstract class ProviderActionRepository {
  /// 覆盖写全部供应商
  Future<void> saveProviders(List<ApiProvider> providers);

  /// 写当前选中的供应商 id（null 表示清除）
  Future<void> saveSelectedId(String? id);

  /// 写代理开关
  Future<void> saveProxyEnabled(bool enabled);

  /// 写代理端口
  Future<void> saveProxyPort(int port);

  /// 开启接管：把 `~/.codex/config.toml` 的 base_url 改成本地代理地址，
  /// 原值备份。返回是否成功改写。
  Future<bool> enableTakeover({required String localProxyUrl});

  /// 关闭接管：把 base_url 还原成备份的原值。
  Future<bool> disableTakeover();
}

import 'package:shim/features/plugins/domain/models/plugin_marketplace_status.dart';

abstract class PluginQueryRepository {
  /// 读磁盘 + config.toml,汇总当前 marketplace 状态。
  Future<PluginMarketplaceStatus> readMarketplaceStatus();
}

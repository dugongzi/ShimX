import 'package:shim/features/providers/domain/models/provider_health.dart';

/// 供应商健康数据访问接口。
///
/// 内存态：每次启动从空开始；只走 datasource 的 ValueNotifier/Stream。
abstract class ProviderHealthRepository {
  /// 当前所有已观察到的健康快照（providerId → health）。
  Map<String, ProviderHealth> snapshot();

  /// 单独读取某家。null 表示该家从未测过。
  ProviderHealth? read({required String providerId});

  /// 写入/覆盖某家健康。会触发订阅推送。
  void write({required ProviderHealth health});

  /// 移除某家（删除供应商时调用）。
  void remove({required String providerId});

  /// 订阅所有供应商健康变化。每次 write/remove 推一次完整 snapshot。
  Stream<Map<String, ProviderHealth>> watch();
}

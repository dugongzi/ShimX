import 'package:shimx/features/providers/domain/models/auto_switch_settings.dart';

abstract class AutoSwitchRepository {
  /// 读取当前配置（未持久化过则返回 const AutoSwitchSettings()）
  Future<AutoSwitchSettings> read();

  /// 持久化覆盖写
  Future<void> save({required AutoSwitchSettings settings});
}

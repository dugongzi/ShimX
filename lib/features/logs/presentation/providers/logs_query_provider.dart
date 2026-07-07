import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';

part 'logs_query_provider.g.dart';

/// 暴露全局日志服务给 logs feature widget。
/// 数据源是 core 单例 `AppLogService.instance`(同时也是 ValueNotifier),
/// 这里仅作 feature 层的薄包装 —— 让 widget 不直接 import core service。
@riverpod
AppLogService logsService(Ref ref) {
  return AppLogService.instance;
}

import 'package:shimx/core/services/app_log_service.dart';

/// 日志列表的级别过滤选项。`info` 段包含 debug 级别(用户角度看 debug 也是普通信息)。
enum LogFilter {
  all,
  info,
  warning,
  error;

  bool matches(AppLogLevel level) {
    switch (this) {
      case LogFilter.all:
        return true;
      case LogFilter.info:
        return level == AppLogLevel.info || level == AppLogLevel.debug;
      case LogFilter.warning:
        return level == AppLogLevel.warning;
      case LogFilter.error:
        return level == AppLogLevel.error;
    }
  }
}

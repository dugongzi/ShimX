import 'package:flutter/material.dart';
import 'package:shimx/core/services/app_log_service.dart';

/// HH:mm:ss.SSS
String formatLogTime(DateTime time) {
  String two(int v) => v.toString().padLeft(2, '0');
  String three(int v) => v.toString().padLeft(3, '0');
  return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}.${three(time.millisecond)}';
}

/// 等级 → 4-字母短标签(DEBUG/INFO/WARN/ERROR)
String logLevelLabel(AppLogLevel level) {
  switch (level) {
    case AppLogLevel.debug:
      return 'DEBUG';
    case AppLogLevel.info:
      return 'INFO';
    case AppLogLevel.warning:
      return 'WARN';
    case AppLogLevel.error:
      return 'ERROR';
  }
}

/// 等级 → 主题色;warning 用固定 orange,其余跟随 colorScheme。
Color logLevelColor(BuildContext context, AppLogLevel level) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (level) {
    case AppLogLevel.debug:
      return colorScheme.onSurfaceVariant;
    case AppLogLevel.info:
      return colorScheme.primary;
    case AppLogLevel.warning:
      return Colors.orange;
    case AppLogLevel.error:
      return colorScheme.error;
  }
}

/// 复制到剪贴板时用的纯文本格式:`HH:mm:ss.SSS LEVEL source - message[\ndetails]`
String formatLogEntryForCopy(AppLogEntry entry) {
  final buffer = StringBuffer()
    ..write(formatLogTime(entry.timestamp))
    ..write(' ')
    ..write(logLevelLabel(entry.level))
    ..write(' ')
    ..write(entry.source)
    ..write(' - ')
    ..write(entry.message);
  final details = entry.details;
  if (details != null && details.isNotEmpty) {
    buffer.write('\n');
    buffer.write(details);
  }
  return buffer.toString();
}

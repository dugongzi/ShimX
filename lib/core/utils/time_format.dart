import 'package:flutter/widgets.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

/// 把毫秒时间戳格式化为相对时间。30 天内显示 "x 分/小时/天 前",超出则显示绝对日期。
/// ms 为 0 时返回空串。
String formatRelativeTime(BuildContext context, int ms) {
  if (ms == 0) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return context.l10n.justNow;
  if (diff.inHours < 1) return context.l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return context.l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 30) return context.l10n.daysAgo(diff.inDays);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

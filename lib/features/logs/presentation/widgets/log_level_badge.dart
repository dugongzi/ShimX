import 'package:flutter/material.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/utils/log_format.dart';

/// 日志条目左侧的小圆角等级徽章。颜色来自 [logLevelColor]。
class LogLevelBadge extends StatelessWidget {
  const LogLevelBadge({super.key, required this.level});

  final AppLogLevel level;

  @override
  Widget build(BuildContext context) {
    final color = logLevelColor(context, level);
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.20 : 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Text(
        logLevelLabel(level),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

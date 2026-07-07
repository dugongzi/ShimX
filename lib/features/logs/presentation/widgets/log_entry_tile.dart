import 'package:flutter/material.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/utils/log_format.dart';
import 'package:shimx/features/logs/presentation/widgets/log_level_badge.dart';

/// 日志列表的单条卡片:级别徽章 + source + 时间 + message + 可选 details。
class LogEntryTile extends StatelessWidget {
  const LogEntryTile({super.key, required this.entry});

  final AppLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final details = entry.details;

    return Container(
      padding: EdgeInsets.all(12.cw(min: 10, max: 14)),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.82 : 0.76,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LogLevelBadge(level: entry.level),
              SizedBox(width: AppSizes.itemGap),
              Expanded(
                child: Text(
                  entry.source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                formatLogTime(entry.timestamp),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
          SizedBox(height: 6.ch(min: 5, max: 8)),
          Text(
            entry.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (details != null && details.isNotEmpty) ...[
            SizedBox(height: 6.ch(min: 5, max: 8)),
            Text(
              details,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

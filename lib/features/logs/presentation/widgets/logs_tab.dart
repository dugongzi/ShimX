import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/app_log_service.dart';

enum _LogFilter {
  all,
  info,
  warning,
  error,
}

class LogsTab extends ConsumerStatefulWidget {
  const LogsTab({super.key});

  @override
  ConsumerState<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends ConsumerState<LogsTab> {
  _LogFilter _filter = _LogFilter.all;

  @override
  Widget build(BuildContext context) {
    final logService = ref.watch(appLogServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return WorkspaceSurface(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: SectionTitle(title: l10n.logs)),
                IconButton(
                  tooltip: l10n.logsCopy,
                  onPressed: () => _copyLogs(context, logService.value),
                  icon: const Icon(Icons.content_copy_rounded),
                ),
                IconButton(
                  tooltip: l10n.logsClear,
                  onPressed: logService.clear,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            SizedBox(height: AppSizes.itemGap),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<_LogFilter>(
                segments: [
                  ButtonSegment(value: _LogFilter.all, label: Text(l10n.logsFilterAll)),
                  ButtonSegment(value: _LogFilter.info, label: Text(l10n.logsFilterInfo)),
                  ButtonSegment(value: _LogFilter.warning, label: Text(l10n.logsFilterWarning)),
                  ButtonSegment(value: _LogFilter.error, label: Text(l10n.logsFilterError)),
                ],
                selected: {_filter},
                onSelectionChanged: (value) {
                  setState(() => _filter = value.first);
                },
              ),
            ),
            SizedBox(height: AppSizes.sectionGap),
            Expanded(
              child: ValueListenableBuilder<List<AppLogEntry>>(
                valueListenable: logService,
                builder: (context, entries, _) {
                  final visible = entries.where(_matchesFilter).toList();
                  if (visible.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.logsEmpty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppSizes.itemGap),
                    itemBuilder: (context, index) {
                      return _LogEntryTile(entry: visible[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(AppLogEntry entry) {
    switch (_filter) {
      case _LogFilter.all:
        return true;
      case _LogFilter.info:
        return entry.level == AppLogLevel.info ||
            entry.level == AppLogLevel.debug;
      case _LogFilter.warning:
        return entry.level == AppLogLevel.warning;
      case _LogFilter.error:
        return entry.level == AppLogLevel.error;
    }
  }

  Future<void> _copyLogs(BuildContext context, List<AppLogEntry> entries) async {
    final l10n = context.l10n;
    final text = entries.map(_formatEntryForCopy).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    SmartDialog.showToast(l10n.logsCopiedToast);
  }

  String _formatEntryForCopy(AppLogEntry entry) {
    final buffer = StringBuffer()
      ..write(_formatTime(entry.timestamp))
      ..write(' ')
      ..write(_levelLabel(entry.level))
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
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final AppLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = _levelColor(context, entry.level);
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
              _LevelBadge(level: entry.level, color: levelColor),
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
                _formatTime(entry.timestamp),
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

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.color});

  final AppLogLevel level;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
        _levelLabel(level),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _levelColor(BuildContext context, AppLogLevel level) {
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

String _levelLabel(AppLogLevel level) {
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

String _formatTime(DateTime time) {
  String two(int value) => value.toString().padLeft(2, '0');
  String three(int value) => value.toString().padLeft(3, '0');
  return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}.${three(time.millisecond)}';
}

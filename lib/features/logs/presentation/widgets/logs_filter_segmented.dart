import 'package:flutter/material.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/utils/log_filter.dart';

/// 日志等级过滤段控:全部 / Info / Warning / Error。
class LogsFilterSegmented extends StatelessWidget {
  const LogsFilterSegmented({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LogFilter value;
  final ValueChanged<LogFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<LogFilter>(
        segments: [
          ButtonSegment(value: LogFilter.all, label: Text(l10n.logsFilterAll)),
          ButtonSegment(value: LogFilter.info, label: Text(l10n.logsFilterInfo)),
          ButtonSegment(
            value: LogFilter.warning,
            label: Text(l10n.logsFilterWarning),
          ),
          ButtonSegment(
            value: LogFilter.error,
            label: Text(l10n.logsFilterError),
          ),
        ],
        selected: {value},
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }
}

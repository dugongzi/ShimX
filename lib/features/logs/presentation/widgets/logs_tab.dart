import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/workspace_surface.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/features/logs/presentation/providers/logs_query_provider.dart';
import 'package:shimx/features/logs/presentation/widgets/log_entry_tile.dart';
import 'package:shimx/core/utils/log_filter.dart';
import 'package:shimx/features/logs/presentation/widgets/logs_filter_segmented.dart';
import 'package:shimx/features/logs/presentation/widgets/logs_toolbar.dart';

/// 主页 Logs tab:工具栏 + 等级过滤 + 列表(订阅 [AppLogService] ValueNotifier 实时更新)。
class LogsTab extends HookConsumerWidget {
  const LogsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = useState(LogFilter.all);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final logService = ref.watch(logsServiceProvider);

    return WorkspaceSurface(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LogsToolbar(),
            SizedBox(height: AppSizes.itemGap),
            LogsFilterSegmented(
              value: filter.value,
              onChanged: (v) => filter.value = v,
            ),
            SizedBox(height: AppSizes.sectionGap),
            Expanded(
              child: ValueListenableBuilder<List<AppLogEntry>>(
                valueListenable: logService,
                builder: (context, entries, _) {
                  final visible = entries
                      .where((e) => filter.value.matches(e.level))
                      .toList();
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
                    itemBuilder: (context, index) =>
                        LogEntryTile(entry: visible[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimx/common/widgets/custom_dialog.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/presentation/providers/app_update_provider.dart';

class UpdateChangelogDialog extends HookConsumerWidget {
  const UpdateChangelogDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSystemOnly = useState(true);
    // 复用同一个 controller,不然每次 setState 都新建会漏。
    final scrollController = useScrollController();
    final logsAsync = ref.watch(
      appUpdateLogsProvider(currentSystemOnly: currentSystemOnly.value),
    );

    return CustomDialog(
      title: Text(context.l10n.updateLog),
      hasClose: true,
      width: 560,
      height: 620,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(context.l10n.updateLogCurrentSystem),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(context.l10n.updateLogAllSystems),
                ),
              ],
              selected: {currentSystemOnly.value},
              onSelectionChanged: (value) {
                currentSystemOnly.value = value.first;
              },
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          Expanded(
            child: logsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(child: Text(context.l10n.updateLogEmpty));
                }
                // Scrollbar 明确挂 controller,避免 primary scroll 判定不到。
                // thumbVisibility 会要求 build 时就有 valid scroll position,
                // 有些窗口尺寸下会抛 assertion,让它按默认淡入淡出即可。
                return Scrollbar(
                  controller: scrollController,
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.only(right: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      return _TimelineItem(
                        item: items[index],
                        isLast: index == items.length - 1,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(context.l10n.updateLogLoadFailed(error.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item, required this.isLast});

  final AppUpdateRelease item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = item.publishedAt.millisecondsSinceEpoch == 0
        ? ''
        : DateFormat('yyyy-MM-dd HH:mm').format(item.publishedAt);
    final changelog = item.changelog.trim().isEmpty
        ? context.l10n.updateCardNoChangelog
        : item.changelog.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.only(top: 4),
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'v${item.version} · ${item.system.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  changelog,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

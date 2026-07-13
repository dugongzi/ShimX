import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/themes/app_colors.dart';
import 'package:shimx/features/update/presentation/providers/app_update_provider.dart';

/// 侧栏顶部更新提示卡片,仅在检测到新版本时展示。
class SidebarUpdateCard extends HookConsumerWidget {
  const SidebarUpdateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final updateAsync = ref.watch(appUpdateCheckProvider);
    return updateAsync.maybeWhen(
      data: (result) {
        if (result == null || !result.hasUpdate) {
          return const SizedBox.shrink();
        }
        final release = result.item;

        final colorScheme = Theme.of(context).colorScheme;
        final isDark = context.isDark;
        final accent = colorScheme.primary;
        final background = isDark
            ? AppColors.darkBgBottom.withValues(alpha: 0.92)
            : accent.withValues(alpha: 0.1);
        final borderColor = accent.withValues(alpha: isDark ? 0.55 : 0.28);
        final foreground = isDark ? Colors.white : accent;
        final bodyColor = isDark
            ? Colors.white.withValues(alpha: 0.72)
            : colorScheme.onSurfaceVariant;
        final changelog = release.changelog.trim().isEmpty
            ? context.l10n.updateCardNoChangelog
            : release.changelog.trim();

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.24),
                        blurRadius: 18,
                        spreadRadius: -3,
                        offset: const Offset(2, 4),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.updateAvailableVersion(release.version),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  // 限最大高度,内容超出可滚。primary: false 避免跟侧栏的
                  // 主 ScrollView 抢滚动手势;Scrollbar 让用户看到还有更多。
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Scrollbar(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Text(
                          changelog,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: bodyColor,
                                    height: 1.35,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

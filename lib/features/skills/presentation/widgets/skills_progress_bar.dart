import 'package:flutter/material.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/constants/skill_progress_mode.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/l10n/app_localizations.dart';

/// skills tab 顶部:进行中的进度条 + 当前模式文案。
/// 不进行时高度自适应为 0。
class SkillsProgressBar extends StatelessWidget {
  const SkillsProgressBar({
    super.key,
    required this.show,
    required this.mode,
    required this.asyncRefreshing,
  });

  final bool show;
  final SkillProgressMode? mode;

  /// codexSkillsProvider 自身在 refresh/reload(与 [mode] 解耦,用于显示通用 refresh 文案)
  final bool asyncRefreshing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: show
          ? Padding(
              key: const ValueKey('skills-progress'),
              padding: EdgeInsets.only(
                left: AppSizes.itemGap,
                right: AppSizes.itemGap,
                top: AppSizes.itemGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 6),
                  Text(
                    _progressText(l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('skills-progress-empty')),
    );
  }

  String _progressText(AppLocalizations l10n) {
    if (mode == null && asyncRefreshing) return l10n.skillsRefreshing;
    return switch (mode) {
      SkillProgressMode.install => l10n.skillsInstalling,
      SkillProgressMode.refresh => l10n.skillsRefreshing,
      SkillProgressMode.import => l10n.skillsImporting,
      SkillProgressMode.delete => l10n.skillsDeleting,
      null => l10n.skillsRefreshing,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

/// 没有任何 skill 时显示的占位 + 两个安装入口。
class EmptySkills extends StatelessWidget {
  const EmptySkills({
    super.key,
    required this.onInstallFolder,
    required this.onInstallZip,
  });

  final VoidCallback? onInstallFolder;
  final VoidCallback? onInstallZip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.skillsEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: AppSizes.itemGap,
              runSpacing: AppSizes.itemGap,
              children: [
                FilledButton.icon(
                  onPressed: onInstallFolder,
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: Text(l10n.skillsInstallFolder),
                ),
                OutlinedButton.icon(
                  onPressed: onInstallZip,
                  icon: const Icon(Icons.archive_rounded),
                  label: Text(l10n.skillsInstallZip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

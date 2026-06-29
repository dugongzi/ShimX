import 'package:flutter/material.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/skills/domain/models/codex_skill.dart';
import 'package:shim/features/skills/presentation/widgets/skill_badge.dart';
import 'package:shim/features/skills/presentation/widgets/skill_info_row.dart';

/// 单条 codex skill 卡片:左 badge + 标题/描述 + 右 进度/动作按钮 + ID/path/hash 信息。
class SkillCard extends StatelessWidget {
  const SkillCard({
    super.key,
    required this.skill,
    required this.busy,
    required this.onImport,
    required this.onDelete,
  });

  final CodexSkill skill;
  final bool busy;
  final VoidCallback? onImport;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final badgeColor = skill.managedByShim
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkillBadge(
                label: skill.managedByShim
                    ? l10n.skillsManagedBadge
                    : l10n.skillsExternalBadge,
                color: badgeColor,
              ),
              SizedBox(width: AppSizes.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name.isEmpty ? skill.id : skill.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skill.description.isEmpty
                          ? l10n.skillsNoDescription
                          : skill.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else ...[
                if (onImport != null)
                  TextButton.icon(
                    onPressed: onImport,
                    icon: const Icon(Icons.add_link_rounded),
                    label: Text(l10n.skillsImportManaged),
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: l10n.skillsDelete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          const Divider(height: 1),
          SizedBox(height: AppSizes.itemGap),
          SkillInfoRow(label: l10n.skillsIdLabel, value: skill.id, copyable: true),
          const SizedBox(height: 6),
          SkillInfoRow(
            label: l10n.skillsPathLabel,
            value: skill.path,
            copyable: true,
          ),
          if (skill.contentHash.isNotEmpty) ...[
            const SizedBox(height: 6),
            SkillInfoRow(
              label: l10n.skillsHashLabel,
              value: skill.contentHash,
              copyable: true,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

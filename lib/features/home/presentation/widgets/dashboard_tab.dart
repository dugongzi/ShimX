import 'package:codex_z/common/widgets/icon_badge.dart';
import 'package:codex_z/common/widgets/section_title.dart';
import 'package:codex_z/common/widgets/workspace_surface.dart';
import 'package:codex_z/core/constants/app_sizes.dart';
import 'package:codex_z/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkspaceSurface(
      child: ListView(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          const WorkspaceHeader(),
          SizedBox(height: AppSizes.sectionGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - AppSizes.sectionGap * 2) / 3
                  : constraints.maxWidth;

              return Wrap(
                spacing: AppSizes.sectionGap,
                runSpacing: AppSizes.sectionGap,
                children: [
                  StatusCard(
                    width: itemWidth,
                    icon: Icons.memory_rounded,
                    title: 'Runtime',
                    value: 'Local',
                    caption: 'Codex process bridge',
                  ),
                  StatusCard(
                    width: itemWidth,
                    icon: Icons.folder_copy_rounded,
                    title: 'Workspace',
                    value: 'Ready',
                    caption: 'Project context loaded',
                  ),
                  StatusCard(
                    width: itemWidth,
                    icon: Icons.bolt_rounded,
                    title: 'Overlay',
                    value: 'Planned',
                    caption: 'Flutter UI injection',
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSizes.sectionGap),
          SectionTitle(
            title: 'Quick actions',
            trailing: Text(
              'No route jump, switch panels in place',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 720;
              final itemWidth = twoColumns
                  ? (constraints.maxWidth - AppSizes.sectionGap) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: AppSizes.sectionGap,
                runSpacing: AppSizes.sectionGap,
                children: [
                  ActionCard(
                    width: itemWidth,
                    icon: Icons.play_arrow_rounded,
                    title: 'Launch Codex',
                    description: 'Prepare command runner and attach session.',
                  ),
                  ActionCard(
                    width: itemWidth,
                    icon: Icons.radar_rounded,
                    title: 'Scan environment',
                    description: 'Check Flutter, Android, ADB, and storage.',
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSizes.sectionGap),
          const TimelineCard(),
        ],
      ),
    );
  }
}

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.homeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6.ch(min: 4, max: 8)),
              Text(
                'Local Codex workspace and Flutter overlay console.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: EdgeInsets.symmetric(
            horizontal: 12.cw(min: 10, max: 14),
            vertical: 8.ch(min: 7, max: 10),
          ),
          shape: LiquidRoundedSuperellipse(borderRadius: AppSizes.cardRadius),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: colorScheme.primary),
              SizedBox(width: AppSizes.itemGap),
              Text(
                'Online',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });

  final double width;
  final IconData icon;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: GlassCard(
        padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
        shape: LiquidRoundedSuperellipse(borderRadius: AppSizes.cardRadius + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(icon: icon),
                const Spacer(),
                Icon(
                  Icons.more_horiz_rounded,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
                ),
              ],
            ),
            SizedBox(height: 18.ch(min: 14, max: 20)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 4.ch(min: 3, max: 6)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.ch(min: 6, max: 10)),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: GlassCard(
        padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
        shape: LiquidRoundedSuperellipse(borderRadius: AppSizes.cardRadius + 2),
        child: Row(
          children: [
            IconBadge(icon: icon),
            SizedBox(width: 12.cw(min: 10, max: 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.ch(min: 3, max: 6)),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.itemGap),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
      shape: LiquidRoundedSuperellipse(borderRadius: AppSizes.cardRadius + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Workspace notes'),
          SizedBox(height: AppSizes.itemGap),
          const NoteRow(
            icon: Icons.check_circle_rounded,
            title: 'Shell layout is ready',
            description:
                'Home and Settings stay in one window with IndexedStack.',
          ),
          const NoteRow(
            icon: Icons.pending_actions_rounded,
            title: 'Next milestone',
            description:
                'Define the bridge for process control and UI injection.',
          ),
        ],
      ),
    );
  }
}

class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.ch(min: 6, max: 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 2.ch(min: 2, max: 4)),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:shim/common/widgets/icon_badge.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/providers/locale_provider.dart';
import 'package:shim/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeColor = ref.watch(themeColorProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      const Color(0xFF98D2D5),
      const Color(0xFF6C8CFF),
      const Color(0xFF27AE60),
      const Color(0xFFE86F51),
    ];

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          SectionTitle(title: context.l10n.settings),
          SizedBox(height: AppSizes.sectionGap),
          SettingCard(
            icon: Icons.language_rounded,
            title: context.l10n.systemLanguage,
            description: locale.languageCode == 'zh'
                ? context.l10n.chineseLanguage
                : context.l10n.englishLanguage,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'zh',
                  label: Text(context.l10n.chineseLanguage),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(context.l10n.englishLanguage),
                ),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (value) {
                final selected = value.first;
                if (selected == 'zh') {
                  ref.read(localeProvider.notifier).setZh();
                } else {
                  ref.read(localeProvider.notifier).setEn();
                }
              },
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          SettingCard(
            icon: Icons.dark_mode_rounded,
            title: context.l10n.themeMode,
            description: themeMode.localizedName(context),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(context.l10n.systemTheme),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(context.l10n.lightTheme),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(context.l10n.darkTheme),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) {
                final selected = value.first;
                final notifier = ref.read(themeModeProvider.notifier);
                switch (selected) {
                  case ThemeMode.system:
                    notifier.setSystem();
                  case ThemeMode.light:
                    notifier.setLight();
                  case ThemeMode.dark:
                    notifier.setDark();
                }
              },
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          SettingCard(
            icon: Icons.palette_rounded,
            title: context.l10n.primaryColor,
            description:
                '#${themeColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
            child: Wrap(
              spacing: AppSizes.itemGap,
              runSpacing: AppSizes.itemGap,
              children: [
                for (final color in colors)
                  ColorSwatch(
                    color: color,
                    selected: color.toARGB32() == themeColor.toARGB32(),
                    onTap: () {
                      ref
                          .read(themeColorProvider.notifier)
                          .updatePrimaryColor(color);
                    },
                  ),
                IconButton.filledTonal(
                  tooltip: context.l10n.reset,
                  onPressed: () {
                    ref.read(themeColorProvider.notifier).resetPrimaryColor();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.sectionGap),
          Text(
            context.l10n.settingsPersistedDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

extension on ThemeMode {
  String localizedName(BuildContext context) {
    return switch (this) {
      ThemeMode.system => context.l10n.systemTheme,
      ThemeMode.light => context.l10n.lightTheme,
      ThemeMode.dark => context.l10n.darkTheme,
    };
  }
}

class SettingCard extends StatelessWidget {
  const SettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SurfaceCard(
      padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.sectionGap),
          child,
        ],
      ),
    );
  }
}

class ColorSwatch extends StatelessWidget {
  const ColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.96 : 0.74),
              width: selected ? 3 : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.36),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }
}

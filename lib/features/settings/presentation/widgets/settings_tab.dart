import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/section_title.dart';
import 'package:shimx/common/widgets/theme_color_swatch.dart';
import 'package:shimx/common/widgets/workspace_surface.dart';
import 'package:shimx/core/constants/app_links.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/constants/theme_color_presets.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/providers/locale_provider.dart';
import 'package:shimx/core/providers/theme_provider.dart';
import 'package:shimx/core/services/shortcut_service.dart';
import 'package:shimx/core/utils/theme_mode_label.dart';
import 'package:shimx/core/providers/requires_openai_auth_provider.dart';
import 'package:shimx/core/providers/tool_filter_keywords_provider.dart';
import 'package:shimx/features/providers/presentation/widgets/proxy_card.dart';
import 'package:shimx/features/settings/presentation/widgets/app_version_line.dart';
import 'package:shimx/features/settings/presentation/widgets/setting_card.dart';
import 'package:shimx/features/settings/presentation/widgets/tool_filter_keywords_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeColor = ref.watch(themeColorProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
                for (final color in themeColorPresets)
                  ThemeColorSwatch(
                    color: color,
                    gradient:
                        color.toARGB32() == launchThemeColor.toARGB32()
                            ? launchThemeColorGradient
                            : null,
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
          SizedBox(height: AppSizes.itemGap),
          SettingCard(
            icon: Icons.add_link_rounded,
            title: context.l10n.desktopShortcut,
            description: context.l10n.desktopShortcutDescription,
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final l10n = context.l10n;
                try {
                  await ref
                      .read(shortcutServiceProvider)
                      .createDesktopShortcut();
                  SmartDialog.showToast(l10n.shortcutCreated);
                } catch (e) {
                  SmartDialog.showToast(l10n.shortcutFailed(e.toString()));
                }
              },
              icon: const Icon(Icons.desktop_windows_outlined),
              label: Text(context.l10n.createShortcut),
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          SettingCard(
            icon: Icons.code_rounded,
            title: context.l10n.openSourceRepository,
            description: shimxRepositoryUrl,
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final l10n = context.l10n;
                try {
                  await launchUrl(
                    Uri.parse(shimxRepositoryUrl),
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  SmartDialog.showToast(
                    l10n.openSourceRepositoryFailed(e.toString()),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(context.l10n.openRepository),
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          SettingCard(
            icon: Icons.filter_alt_rounded,
            title: context.l10n.toolFilterKeywordsTitle,
            description: _toolFilterKeywordsSummary(ref, context),
            child: FilledButton.tonalIcon(
              onPressed: () => SmartDialog.show(
                builder: (_) => const ToolFilterKeywordsDialog(),
              ),
              icon: const Icon(Icons.tune_rounded),
              label: Text(context.l10n.toolFilterKeywordsManage),
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          SettingCard(
            icon: Icons.verified_user_rounded,
            title: context.l10n.requiresOpenaiAuthTitle,
            description: context.l10n.requiresOpenaiAuthDescription,
            child: Switch(
              value: ref.watch(requiresOpenaiAuthProvider),
              onChanged: (v) => ref
                  .read(requiresOpenaiAuthProvider.notifier)
                  .set(v),
            ),
          ),
          SizedBox(height: AppSizes.itemGap),
          const ProxyCard(),
          SizedBox(height: AppSizes.sectionGap),
          Text(
            context.l10n.settingsPersistedDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: AppSizes.itemGap),
          const AppVersionLine(),
        ],
      ),
    );
  }

  String _toolFilterKeywordsSummary(WidgetRef ref, BuildContext context) {
    final list = ref.watch(toolFilterKeywordsProvider);
    if (list.isEmpty) return context.l10n.toolFilterKeywordsEmpty;
    return list
        .map((k) => k.enabled ? k.keyword : '${k.keyword} (off)')
        .join(', ');
  }
}

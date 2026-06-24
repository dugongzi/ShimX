import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/app_background.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/home/presentation/widgets/dashboard_tab.dart';
import 'package:shim/features/home/presentation/widgets/home_sidebar.dart';
import 'package:shim/features/home/presentation/widgets/home_tab_item.dart';
import 'package:shim/features/home/presentation/widgets/sessions_tab.dart';
import 'package:shim/features/logs/presentation/widgets/logs_tab.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_tab.dart';
import 'package:shim/features/providers/presentation/widgets/providers_tab.dart';
import 'package:shim/features/settings/presentation/widgets/settings_tab.dart';

enum HomeTab { home, providers, sessions, mcp, logs, settings }

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = useState(HomeTab.home);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeSidebar(
                  title: context.l10n.homeTitle,
                  children: [
                    HomeTabItem(
                      leading: Icons.home_outlined,
                      selectedLeading: Icons.home_rounded,
                      title: context.l10n.home,
                      selected: selectedTab.value == HomeTab.home,
                      onTap: () => selectedTab.value = HomeTab.home,
                    ),
                    HomeTabItem(
                      leading: Icons.dns_outlined,
                      selectedLeading: Icons.dns_rounded,
                      title: context.l10n.providers,
                      selected: selectedTab.value == HomeTab.providers,
                      onTap: () => selectedTab.value = HomeTab.providers,
                    ),
                    HomeTabItem(
                      leading: Icons.forum_outlined,
                      selectedLeading: Icons.forum_rounded,
                      title: context.l10n.sessionManagement,
                      selected: selectedTab.value == HomeTab.sessions,
                      onTap: () => selectedTab.value = HomeTab.sessions,
                    ),
                    HomeTabItem(
                      leading: Icons.hub_outlined,
                      selectedLeading: Icons.hub_rounded,
                      title: context.l10n.mcp,
                      selected: selectedTab.value == HomeTab.mcp,
                      onTap: () => selectedTab.value = HomeTab.mcp,
                    ),
                    HomeTabItem(
                      leading: Icons.subject_outlined,
                      selectedLeading: Icons.subject_rounded,
                      title: context.l10n.navLogs,
                      selected: selectedTab.value == HomeTab.logs,
                      onTap: () => selectedTab.value = HomeTab.logs,
                    ),
                    HomeTabItem(
                      leading: Icons.settings_outlined,
                      selectedLeading: Icons.settings_rounded,
                      title: context.l10n.settings,
                      selected: selectedTab.value == HomeTab.settings,
                      onTap: () => selectedTab.value = HomeTab.settings,
                    ),
                  ],
                ),
                SizedBox(width: AppSizes.sectionGap),
                Expanded(
                  child: IndexedStack(
                    index: selectedTab.value.index,
                    children: const [
                      DashboardTab(),
                      ProvidersTab(),
                      SessionsTab(),
                      McpTab(),
                      LogsTab(),
                      SettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

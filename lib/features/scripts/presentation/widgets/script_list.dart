import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/themes/app_colors.dart';
import 'package:shimx/features/scripts/domain/models/inject_script.dart';
import 'package:shimx/features/scripts/presentation/providers/script_action_provider.dart';
import 'package:shimx/features/scripts/presentation/providers/script_query_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shimx/core/routes/routes/scripts_route.dart';
import 'package:shimx/features/scripts/presentation/widgets/remote_script_list.dart';
import 'package:shimx/features/scripts/presentation/widgets/script_list_body.dart';
import 'package:shimx/features/scripts/presentation/widgets/script_list_pagination.dart';
import 'package:shimx/features/scripts/presentation/widgets/script_list_toolbar.dart';

const _pageSize = 20;

class ScriptList extends HookConsumerWidget {
  const ScriptList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<Set<String>>({});
    final currentPage = useState(1);
    final showRemote = useState(false);

    final scriptsAsync = ref.watch(scriptsProvider);
    final scripts = scriptsAsync.value ?? const <InjectScript>[];

    final totalPages =
        scripts.isEmpty ? 1 : (scripts.length / _pageSize).ceil();
    final clampedPage = currentPage.value.clamp(1, totalPages);
    if (clampedPage != currentPage.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentPage.value = clampedPage;
      });
    }
    final start = (clampedPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, scripts.length);
    final pageItems = scripts.sublist(start, end);
    final pageIds = pageItems.map((s) => s.id).toSet();
    final selectedOnPage = selected.value.where(pageIds.contains).length;

    Future<void> handleImport() async {
      try {
        await ref.read(importScriptProvider.future);
        ref.invalidate(scriptsProvider);
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    void handleRefresh() {
      ref.invalidate(scriptsProvider);
    }

    Future<void> handleDeleteSelected() async {
      final ids = selected.value.where(pageIds.contains).toList();
      if (ids.isEmpty) return;
      try {
        await ref.read(deleteScriptsProvider(ids: ids).future);
        for (final id in ids) {
          ref.invalidate(scriptEnabledProvider(id: id));
        }
        ref.invalidate(scriptsProvider);
        final next = {...selected.value}..removeAll(ids);
        selected.value = next;
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    Future<void> handleSetEnabled(bool enabled) async {
      final ids = selected.value.where(pageIds.contains).toList();
      if (ids.isEmpty) return;
      try {
        await ref.read(
          setScriptsEnabledProvider(ids: ids, enabled: enabled).future,
        );
        for (final id in ids) {
          ref.invalidate(scriptEnabledProvider(id: id));
        }
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(context.l10n.localScripts),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(context.l10n.remoteScripts),
                  ),
                ],
                selected: {showRemote.value},
                onSelectionChanged: (value) {
                  showRemote.value = value.first;
                },
              ),
            ),
            SizedBox(height: AppSizes.sectionGap),
            if (showRemote.value)
              Expanded(child: RemoteScriptList(localScripts: scripts))
            else ...[
              ScriptListToolbar(
                selectedCount: selectedOnPage,
                onSelectAll: pageItems.isEmpty
                    ? null
                    : () => selected.value = {...selected.value, ...pageIds},
                onInvertSelection: pageItems.isEmpty
                    ? null
                    : () {
                        final next = {...selected.value};
                        for (final id in pageIds) {
                          if (next.contains(id)) {
                            next.remove(id);
                          } else {
                            next.add(id);
                          }
                        }
                        selected.value = next;
                      },
                onRefresh: handleRefresh,
                onDeleteSelected:
                    selectedOnPage == 0 ? null : () => handleDeleteSelected(),
                onEnableSelected:
                    selectedOnPage == 0 ? null : () => handleSetEnabled(true),
                onDisableSelected:
                    selectedOnPage == 0 ? null : () => handleSetEnabled(false),
              ),
              SizedBox(height: AppSizes.sectionGap),
              Expanded(
                child: ScriptListBody(
                  scriptsAsync: scriptsAsync,
                  pageItems: pageItems,
                  selected: selected,
                ),
              ),
              SizedBox(height: AppSizes.sectionGap),
              ScriptListPagination(
                currentPage: clampedPage,
                totalPages: totalPages,
                onPageSelected: (page) => currentPage.value = page,
              ),
            ],
          ],
        ),
        if (!showRemote.value)
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AccentFab(
                  icon: Icons.file_download_outlined,
                  tooltip: context.l10n.importScript,
                  onTap: () => handleImport(),
                ),
                const SizedBox(height: 12),
                _AccentFab(
                  icon: Icons.add_rounded,
                  tooltip: context.l10n.newScript,
                  onTap: () => context.push(ScriptsRoute.toEditorNew()),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 学 [HomeTabItem] 选中态的浮动按钮:深底 + 主色描边 + 主色光晕 + 主色图标。
class _AccentFab extends StatelessWidget {
  const _AccentFab({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDark;
    final accent = colorScheme.primary;
    final radius = BorderRadius.circular(16);

    final bg = isDark
        ? AppColors.darkBgBottom.withValues(alpha: 0.92)
        : accent.withValues(alpha: 0.12);
    final border = accent.withValues(alpha: isDark ? 0.55 : 0.32);
    final fg = isDark ? Colors.white : accent;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: Border.all(color: border),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.32),
                    blurRadius: 22,
                    spreadRadius: -2,
                    offset: const Offset(2, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Center(child: Icon(icon, size: 22, color: fg)),
          ),
        ),
      ),
    );
  }
}

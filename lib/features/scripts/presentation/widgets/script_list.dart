import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:shim/features/scripts/presentation/providers/script_action_provider.dart';
import 'package:shim/features/scripts/presentation/providers/script_query_provider.dart';
import 'package:shim/features/scripts/presentation/widgets/script_list_body.dart';
import 'package:shim/features/scripts/presentation/widgets/script_list_pagination.dart';
import 'package:shim/features/scripts/presentation/widgets/script_list_toolbar.dart';

const _pageSize = 20;

class ScriptList extends HookConsumerWidget {
  const ScriptList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<Set<String>>({});
    final currentPage = useState(1);

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
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    Future<void> handleDeleteSelected() async {
      final ids = selected.value.where(pageIds.contains).toList();
      if (ids.isEmpty) return;
      try {
        await ref.read(deleteScriptsProvider(ids: ids).future);
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
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScriptListToolbar(
          selectedCount: selectedOnPage,
          onImport: () => handleImport(),
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
    );
  }
}

import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class ScriptListToolbar extends StatelessWidget {
  const ScriptListToolbar({
    super.key,
    required this.selectedCount,
    required this.onImport,
    required this.onSelectAll,
    required this.onInvertSelection,
    required this.onDeleteSelected,
    required this.onEnableSelected,
    required this.onDisableSelected,
  });

  final int selectedCount;
  final VoidCallback? onImport;
  final VoidCallback? onSelectAll;
  final VoidCallback? onInvertSelection;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onEnableSelected;
  final VoidCallback? onDisableSelected;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCount > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          onPressed: onImport,
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: Text(context.l10n.importScript),
        ),
        SizedBox(width: AppSizes.itemGap),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: hasSelection ? onDeleteSelected : null,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(context.l10n.deleteSelected),
                ),
                SizedBox(width: AppSizes.itemGap),
                TextButton.icon(
                  onPressed: hasSelection ? onDisableSelected : null,
                  icon: const Icon(Icons.power_off_rounded, size: 18),
                  label: Text(context.l10n.disableSelected),
                ),
                SizedBox(width: AppSizes.itemGap),
                TextButton.icon(
                  onPressed: hasSelection ? onEnableSelected : null,
                  icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                  label: Text(context.l10n.enableSelected),
                ),
                SizedBox(width: AppSizes.itemGap),
                TextButton.icon(
                  onPressed: onInvertSelection,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: Text(context.l10n.invertSelection),
                ),
                SizedBox(width: AppSizes.itemGap),
                TextButton.icon(
                  onPressed: onSelectAll,
                  icon: const Icon(Icons.checklist_rounded, size: 18),
                  label: Text(context.l10n.selectAll),
                ),
              ].reversed.toList(),
            ),
          ),
        ),
      ],
    );
  }
}

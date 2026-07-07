import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class ScriptListToolbar extends StatelessWidget {
  const ScriptListToolbar({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onInvertSelection,
    required this.onDeleteSelected,
    required this.onEnableSelected,
    required this.onDisableSelected,
  });

  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onInvertSelection;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onEnableSelected;
  final VoidCallback? onDisableSelected;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCount > 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: onSelectAll,
            icon: const Icon(Icons.checklist_rounded, size: 18),
            label: Text(context.l10n.selectAll),
          ),
          SizedBox(width: AppSizes.itemGap),
          TextButton.icon(
            onPressed: onInvertSelection,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(context.l10n.invertSelection),
          ),
          SizedBox(width: AppSizes.itemGap),
          TextButton.icon(
            onPressed: hasSelection ? onEnableSelected : null,
            icon: const Icon(Icons.power_settings_new_rounded, size: 18),
            label: Text(context.l10n.enableSelected),
          ),
          SizedBox(width: AppSizes.itemGap),
          TextButton.icon(
            onPressed: hasSelection ? onDisableSelected : null,
            icon: const Icon(Icons.power_off_rounded, size: 18),
            label: Text(context.l10n.disableSelected),
          ),
          SizedBox(width: AppSizes.itemGap),
          TextButton.icon(
            onPressed: hasSelection ? onDeleteSelected : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(context.l10n.deleteSelected),
          ),
        ],
      ),
    );
  }
}

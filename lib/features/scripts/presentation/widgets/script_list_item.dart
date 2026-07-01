import 'package:go_router/go_router.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/routes/routes/scripts_route.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:flutter/material.dart';

class ScriptListItem extends StatelessWidget {
  const ScriptListItem({
    super.key,
    required this.script,
    required this.selected,
    required this.onSelectedChanged,
  });

  final InjectScript script;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metadata = script.metadata;
    final hasDescription = metadata.description.isNotEmpty;

    return SurfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: 14.cw(min: 12, max: 16),
        vertical: 10.ch(min: 8, max: 12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: selected,
            onChanged: (value) => onSelectedChanged(value ?? false),
          ),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metadata.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (hasDescription) ...[
                  SizedBox(height: 2.ch(min: 2, max: 4)),
                  Text(
                    metadata.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSizes.itemGap),
          if (metadata.version.isNotEmpty)
            Text(
              'v${metadata.version}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          SizedBox(width: AppSizes.itemGap),
          IconButton(
            tooltip: context.l10n.editScript,
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: () => context.push(ScriptsRoute.toEditor(script.id)),
            icon: const Icon(Icons.code_rounded),
          ),
        ],
      ),
    );
  }
}

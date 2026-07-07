import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/surface_card.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/routes/routes/scripts_route.dart';
import 'package:shimx/features/scripts/domain/models/inject_script.dart';
import 'package:shimx/features/scripts/presentation/providers/script_action_provider.dart';
import 'package:shimx/features/scripts/presentation/providers/script_query_provider.dart';

class ScriptListItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final metadata = script.metadata;
    final hasDescription = metadata.description.isNotEmpty;
    final enabledAsync = ref.watch(scriptEnabledProvider(id: script.id));
    final enabled = enabledAsync.value ?? false;

    Future<void> handleToggleEnabled(bool value) async {
      try {
        await ref.read(
          setScriptsEnabledProvider(ids: [script.id], enabled: value).future,
        );
        ref.invalidate(scriptEnabledProvider(id: script.id));
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(ScriptsRoute.toEditor(script.id)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
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
              Switch(
                value: enabled,
                onChanged:
                    enabledAsync.isLoading ? null : handleToggleEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

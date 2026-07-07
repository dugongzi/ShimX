import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/section_title.dart';
import 'package:shimx/common/widgets/workspace_surface.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/providers/domain/models/api_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';
import 'package:shimx/features/providers/presentation/widgets/auto_switch_card.dart';
import 'package:shimx/features/providers/presentation/widgets/provider_card.dart';
import 'package:shimx/features/providers/presentation/widgets/provider_edit_dialog.dart';

class ProvidersTab extends ConsumerWidget {
  const ProvidersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(providerListProvider);
    final state = listAsync.value;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    void showEditDialog(ApiProvider? existing) {
      SmartDialog.show(
        builder: (_) => ProviderEditDialog(existing: existing),
      );
    }

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          const AutoSwitchCard(),
          SizedBox(height: AppSizes.sectionGap),
          Row(
            children: [
              Expanded(child: SectionTitle(title: l10n.providers)),
              FilledButton.icon(
                onPressed: () => showEditDialog(null),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addProvider),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sectionGap),
          if (state == null || state.providers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  l10n.noProvidersHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          else
            for (final provider in state.providers) ...[
              ProviderCard(
                provider: provider,
                selected: provider.id == state.selectedId,
                onSelect: () => ref
                    .read(providerActionsProvider.notifier)
                    .select(provider.id),
                onEdit: () => showEditDialog(provider),
                onDelete: () async {
                  await ref
                      .read(providerActionsProvider.notifier)
                      .remove(provider.id);
                  SmartDialog.showToast(l10n.deletedToast);
                },
              ),
              SizedBox(height: AppSizes.itemGap),
            ],
        ],
      ),
    );
  }
}

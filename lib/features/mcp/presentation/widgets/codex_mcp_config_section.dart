import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shim/features/mcp/presentation/providers/codex_mcp_config_action_provider.dart';
import 'package:shim/features/mcp/presentation/providers/codex_mcp_config_query_provider.dart';
import 'package:shim/features/mcp/presentation/widgets/codex_mcp_config_card.dart';
import 'package:shim/features/mcp/presentation/widgets/codex_mcp_config_edit_dialog.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_empty_box.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_error_box.dart';

/// "Codex MCP 配置"分区:标题 + 添加按钮 + 进度条 + 配置列表。
class CodexMcpConfigSection extends HookConsumerWidget {
  const CodexMcpConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(codexMcpConfigsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final working = useState(false);
    final showProgress =
        working.value || async.isRefreshing || async.isReloading;

    Future<void> runConfigAction(Future<void> Function() action) async {
      working.value = true;
      try {
        await action();
        ref.invalidate(codexMcpConfigsProvider);
        await ref.read(codexMcpConfigsProvider.future);
      } finally {
        working.value = false;
      }
    }

    void showEditDialog(CodexMcpConfig? existing) {
      SmartDialog.show(
        builder: (_) => CodexMcpConfigEditDialog(existing: existing),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SectionTitle(title: l10n.mcpConfigTitle)),
            FilledButton.icon(
              onPressed: working.value ? null : () => showEditDialog(null),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.mcpConfigAdd),
            ),
            IconButton(
              tooltip: l10n.refresh,
              onPressed:
                  working.value ? null : () => runConfigAction(() async {}),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        SizedBox(height: AppSizes.itemGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.itemGap),
          child: Text(
            l10n.mcpConfigHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: showProgress
              ? Padding(
                  key: const ValueKey('mcp-config-progress'),
                  padding: EdgeInsets.only(
                    left: AppSizes.itemGap,
                    right: AppSizes.itemGap,
                    top: AppSizes.itemGap,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 6),
                      Text(
                        l10n.mcpConfigInstalling,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(
                  key: ValueKey('mcp-config-progress-empty'),
                ),
        ),
        SizedBox(height: AppSizes.sectionGap),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => McpErrorBox(message: error.toString()),
          data: (configs) {
            if (configs.isEmpty) {
              return McpEmptyBox(message: l10n.mcpConfigEmpty);
            }
            return Column(
              children: [
                for (final config in configs) ...[
                  CodexMcpConfigCard(
                    key: ValueKey('${config.kind}:${config.id}'),
                    config: config,
                    onEdit: () => showEditDialog(config),
                    onDelete: () async {
                      try {
                        await runConfigAction(
                          () => ref
                              .read(codexMcpConfigActionsProvider.notifier)
                              .remove(kind: config.kind, id: config.id),
                        );
                        SmartDialog.showToast(l10n.deletedToast);
                      } catch (error) {
                        SmartDialog.showToast(error.toString());
                      }
                    },
                    onToggle: (enabled) {
                      return runConfigAction(
                        () => ref
                            .read(codexMcpConfigActionsProvider.notifier)
                            .setEnabled(
                              kind: config.kind,
                              id: config.id,
                              enabled: enabled,
                            ),
                      );
                    },
                  ),
                  SizedBox(height: AppSizes.itemGap),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

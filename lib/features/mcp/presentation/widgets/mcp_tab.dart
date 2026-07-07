import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/section_title.dart';
import 'package:shimx/common/widgets/workspace_surface.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/constants/mcp_server_status.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/services/mcp_service.dart';
import 'package:shimx/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shimx/features/mcp/presentation/providers/mcp_server_action_provider.dart';
import 'package:shimx/features/mcp/presentation/providers/mcp_server_query_provider.dart';
import 'package:shimx/features/mcp/presentation/widgets/codex_mcp_config_section.dart';
import 'package:shimx/features/mcp/presentation/widgets/mcp_empty_box.dart';
import 'package:shimx/features/mcp/presentation/widgets/mcp_error_box.dart';
import 'package:shimx/features/mcp/presentation/widgets/mcp_server_card.dart';

/// MCP tab 外壳:shimx 自带 server 列表 + codex 端 MCP 配置区。
class McpTab extends HookConsumerWidget {
  const McpTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mcpServerListProvider);
    final enabledAsync = ref.watch(mcpServerEnabledProvider);
    final runningPortListenable = ref.watch(mcpServerRunningPortProvider);
    final l10n = context.l10n;

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Row(
            children: [
              Expanded(child: SectionTitle(title: l10n.mcpServersTitle)),
              IconButton(
                tooltip: l10n.refresh,
                onPressed: () => ref.invalidate(mcpServerListProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.itemGap),
            child: Text(
              l10n.mcpServersHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          SizedBox(height: AppSizes.sectionGap),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => McpErrorBox(message: e.toString()),
            data: (servers) {
              if (servers.isEmpty) {
                return McpEmptyBox(message: l10n.mcpServersEmpty);
              }
              final enabled = enabledAsync.value ?? true;
              return ValueListenableBuilder<int?>(
                valueListenable: runningPortListenable,
                builder: (context, runningPort, _) {
                  return Column(
                    children: [
                      for (final s in servers) ...[
                        McpServerCard(
                          server: _localizedBuiltInServer(context, s).copyWith(
                            status: runningPort != null
                                ? McpServerStatus.running.wire
                                : s.status,
                          ),
                          enabled: enabled,
                          loading: enabledAsync.isLoading,
                          onToggle: (v) => ref
                              .read(mcpServerActionsProvider.notifier)
                              .setEnabled(v),
                        ),
                        SizedBox(height: AppSizes.itemGap),
                      ],
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: AppSizes.sectionGap),
          const CodexMcpConfigSection(),
        ],
      ),
    );
  }

  /// 内置 shimx_claude server 的 name/description 走 l10n;其它 server 透传。
  McpServerInfo _localizedBuiltInServer(
    BuildContext context,
    McpServerInfo server,
  ) {
    if (server.id != 'shimx_claude') return server;
    final l10n = context.l10n;
    return server.copyWith(
      name: l10n.mcpShimXClaudeName,
      description: l10n.mcpShimXClaudeDescription,
    );
  }
}

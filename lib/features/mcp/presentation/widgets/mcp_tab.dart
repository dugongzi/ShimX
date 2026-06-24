import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/mcp_service.dart';
import 'package:shim/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shim/features/mcp/presentation/providers/mcp_server_action_provider.dart';
import 'package:shim/features/mcp/presentation/providers/mcp_server_query_provider.dart';

class McpTab extends ConsumerWidget {
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
            error: (e, _) => _ErrorBox(message: e.toString()),
            data: (servers) {
              if (servers.isEmpty) {
                return _EmptyBox(message: l10n.mcpServersEmpty);
              }
              final enabled = enabledAsync.value ?? true;
              return ValueListenableBuilder<int?>(
                valueListenable: runningPortListenable,
                builder: (context, runningPort, _) {
                  return Column(
                    children: [
                      for (final s in servers) ...[
                        _McpServerCard(
                          server: s.copyWith(
                            status: runningPort != null ? 'running' : s.status,
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
        ],
      ),
    );
  }
}

class _McpServerCard extends StatelessWidget {
  const _McpServerCard({
    required this.server,
    required this.enabled,
    required this.loading,
    required this.onToggle,
  });

  final McpServerInfo server;
  final bool enabled;
  final bool loading;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final (statusColor, statusText) = _statusVisual(context, server);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.cw(min: 8, max: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      server.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.cw(min: 8, max: 12)),
              _StatusBadge(label: statusText, color: statusColor),
              SizedBox(width: 10.cw(min: 8, max: 12)),
              Switch(
                value: enabled,
                onChanged: loading ? null : onToggle,
              ),
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          const Divider(height: 1),
          SizedBox(height: AppSizes.itemGap),
          _InfoRow(
            label: l10n.mcpServerUrlLabel,
            value: server.url,
            copyable: true,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: l10n.mcpServerIdLabel,
            value: server.id,
            copyable: true,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: l10n.mcpServerToolCountLabel,
            value: server.toolCount.toString(),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: l10n.mcpServerRegisteredLabel,
            value: server.registeredInCodex
                ? l10n.mcpServerRegisteredYes
                : l10n.mcpServerRegisteredNo,
            valueColor: server.registeredInCodex
                ? Colors.green
                : colorScheme.onSurfaceVariant,
          ),
          if (server.statusDetail.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(
              label: l10n.mcpServerStatusDetailLabel,
              value: server.statusDetail,
              valueColor: colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }

  (Color, String) _statusVisual(BuildContext context, McpServerInfo s) {
    final l10n = context.l10n;
    switch (s.status) {
      case 'running':
        return (Colors.green, l10n.mcpStatusRunning);
      case 'error':
        return (Theme.of(context).colorScheme.error, l10n.mcpStatusError);
      default:
        return (
          Theme.of(context).colorScheme.onSurfaceVariant,
          l10n.mcpStatusStopped
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool copyable;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor ?? colorScheme.onSurface,
                  fontFamily: copyable ? 'monospace' : null,
                ),
          ),
        ),
        if (copyable)
          IconButton(
            tooltip: l10n.copy,
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              SmartDialog.showToast(l10n.copied);
            },
            icon: const Icon(Icons.copy_rounded),
          ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}

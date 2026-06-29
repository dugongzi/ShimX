import 'package:flutter/material.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/constants/mcp_server_status.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_info_row.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_status_badge.dart';

/// shim 暴露的一个 MCP server 在 UI 列表里的卡片。
class McpServerCard extends StatelessWidget {
  const McpServerCard({
    super.key,
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
    final status = McpServerStatus.fromWire(server.status);
    final (statusColor, statusText) = status.visual(context);

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
              McpStatusBadge(label: statusText, color: statusColor),
              SizedBox(width: 10.cw(min: 8, max: 12)),
              Switch(value: enabled, onChanged: loading ? null : onToggle),
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          const Divider(height: 1),
          SizedBox(height: AppSizes.itemGap),
          McpInfoRow(
            label: l10n.mcpServerUrlLabel,
            value: server.url,
            copyable: true,
          ),
          const SizedBox(height: 6),
          McpInfoRow(
            label: l10n.mcpServerIdLabel,
            value: server.id,
            copyable: true,
          ),
          const SizedBox(height: 6),
          McpInfoRow(
            label: l10n.mcpServerToolCountLabel,
            value: server.toolCount.toString(),
          ),
          const SizedBox(height: 6),
          McpInfoRow(
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
            McpInfoRow(
              label: l10n.mcpServerStatusDetailLabel,
              value: server.statusDetail,
              valueColor: colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

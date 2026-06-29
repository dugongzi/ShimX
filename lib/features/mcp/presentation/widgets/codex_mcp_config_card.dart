import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_info_row.dart';
import 'package:shim/features/mcp/presentation/widgets/mcp_status_badge.dart';

/// codex MCP 配置的单条卡片:类型徽章 + 名称 + 开关 + 编辑/删除 + ID + body 预览。
///
/// 开关状态:乐观更新 —— 切到目标值再 await action,失败时回滚。
class CodexMcpConfigCard extends HookConsumerWidget {
  const CodexMcpConfigCard({
    super.key,
    required this.config,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final CodexMcpConfig config;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(bool enabled) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final typeLabel = CodexMcpConfigKind.label(config.kind);
    final enabled = useState(config.enabled);
    final toggling = useState(false);

    // config 变化时(列表 invalidate 后)同步本地乐观状态。
    useEffect(() {
      enabled.value = config.enabled;
      return null;
    }, [config.id, config.kind, config.enabled]);

    Future<void> handleToggle(bool next) async {
      final previous = enabled.value;
      AppLogService.instance.info(
        'CodexMcpConfig',
        'UI 点击 MCP 配置开关',
        details:
            'kind=${config.kind}\nid=${config.id}\nfrom=$previous\nto=$next',
      );
      enabled.value = next;
      toggling.value = true;
      try {
        await onToggle(next);
        AppLogService.instance.info(
          'CodexMcpConfig',
          'UI MCP 配置开关完成',
          details: 'kind=${config.kind}\nid=${config.id}\nto=$next',
        );
      } catch (error) {
        AppLogService.instance.error(
          'CodexMcpConfig',
          'UI MCP 配置开关失败',
          details: 'kind=${config.kind}\nid=${config.id}\n$error',
        );
        enabled.value = previous;
        SmartDialog.showToast(error.toString());
      } finally {
        toggling.value = false;
      }
    }

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              McpStatusBadge(label: typeLabel, color: colorScheme.primary),
              SizedBox(width: 10.cw(min: 8, max: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (config.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        config.description,
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
              Switch(
                value: enabled.value,
                onChanged: toggling.value ? null : handleToggle,
              ),
              IconButton(
                tooltip: l10n.editProvider,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: l10n.deleteProvider,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          const Divider(height: 1),
          SizedBox(height: AppSizes.itemGap),
          McpInfoRow(
            label: l10n.mcpConfigIdLabel,
            value: config.id,
            copyable: true,
          ),
          const SizedBox(height: 6),
          McpInfoRow(
            label: l10n.mcpConfigBodyLabel,
            value: config.bodyText,
            copyable: true,
            maxLines: 6,
            valueColor: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

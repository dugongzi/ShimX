import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/mcp_service.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';
import 'package:shim/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shim/features/mcp/presentation/providers/codex_tool_action_provider.dart';
import 'package:shim/features/mcp/presentation/providers/codex_tool_query_provider.dart';
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
                          server: _localizedBuiltInServer(context, s).copyWith(
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
          SizedBox(height: AppSizes.sectionGap),
          const _CodexToolSection(),
        ],
      ),
    );
  }

  McpServerInfo _localizedBuiltInServer(
    BuildContext context,
    McpServerInfo server,
  ) {
    if (server.id != 'shim_claude') return server;
    final l10n = context.l10n;
    return server.copyWith(
      name: l10n.mcpShimClaudeName,
      description: l10n.mcpShimClaudeDescription,
    );
  }
}

class _CodexToolSection extends ConsumerWidget {
  const _CodexToolSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(codexToolsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final deletedToast = context.l10n.deletedToast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SectionTitle(title: l10n.mcpCodexToolsTitle)),
            FilledButton.icon(
              onPressed: () => _showEditDialog(context, ref, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.mcpCodexToolAdd),
            ),
            IconButton(
              tooltip: context.l10n.refresh,
              onPressed: () => ref.invalidate(codexToolsProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        SizedBox(height: AppSizes.itemGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.itemGap),
          child: Text(
            l10n.mcpCodexToolsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: AppSizes.sectionGap),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => _ErrorBox(message: error.toString()),
          data: (configs) {
            if (configs.isEmpty) {
              return _EmptyBox(message: l10n.mcpCodexToolsEmpty);
            }
            return Column(
              children: [
                for (final tool in configs) ...[
                  _CodexToolCard(
                    key: ValueKey('${tool.kind}:${tool.id}'),
                    tool: tool,
                    onEdit: () => _showEditDialog(context, ref, tool),
                    onDelete: () async {
                      await ref
                          .read(codexToolActionsProvider.notifier)
                          .remove(kind: tool.kind, id: tool.id);
                      SmartDialog.showToast(deletedToast);
                    },
                    onToggle: (enabled) {
                      return ref
                          .read(codexToolActionsProvider.notifier)
                          .setEnabled(
                            kind: tool.kind,
                            id: tool.id,
                            enabled: enabled,
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

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    CodexTool? existing,
  ) {
    SmartDialog.show(
      builder: (_) => _CodexToolEditDialog(ref: ref, existing: existing),
    );
  }
}

class _CodexToolCard extends StatefulWidget {
  const _CodexToolCard({
    super.key,
    required this.tool,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final CodexTool tool;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(bool enabled) onToggle;

  @override
  State<_CodexToolCard> createState() => _CodexToolCardState();
}

class _CodexToolCardState extends State<_CodexToolCard> {
  late bool _enabled;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.tool.enabled;
  }

  @override
  void didUpdateWidget(covariant _CodexToolCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tool.id != widget.tool.id ||
        oldWidget.tool.kind != widget.tool.kind ||
        oldWidget.tool.enabled != widget.tool.enabled) {
      _enabled = widget.tool.enabled;
    }
  }

  Future<void> _toggle(bool enabled) async {
    final previous = _enabled;
    AppLogService.instance.info(
      'CodexTool',
      'UI 点击配置片段开关',
      details:
          'kind=${widget.tool.kind}\nid=${widget.tool.id}\nfrom=$previous\nto=$enabled',
    );
    setState(() {
      _enabled = enabled;
      _toggling = true;
    });
    try {
      await widget.onToggle(enabled);
      AppLogService.instance.info(
        'CodexTool',
        'UI 配置片段开关完成',
        details: 'kind=${widget.tool.kind}\nid=${widget.tool.id}\nto=$enabled',
      );
    } catch (error) {
      AppLogService.instance.error(
        'CodexTool',
        'UI 配置片段开关失败',
        details: 'kind=${widget.tool.kind}\nid=${widget.tool.id}\n$error',
      );
      if (mounted) setState(() => _enabled = previous);
      SmartDialog.showToast(error.toString());
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tool = widget.tool;
    final typeLabel = CodexToolKind.label(tool.kind);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(
                label: typeLabel,
                color: tool.kind == CodexToolKind.mcpServer
                    ? colorScheme.primary
                    : colorScheme.tertiary,
              ),
              SizedBox(width: 10.cw(min: 8, max: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (tool.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tool.description,
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
              Switch(value: _enabled, onChanged: _toggling ? null : _toggle),
              IconButton(
                tooltip: context.l10n.editProvider,
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: context.l10n.deleteProvider,
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          const Divider(height: 1),
          SizedBox(height: AppSizes.itemGap),
          _InfoRow(label: 'ID', value: tool.id, copyable: true),
          const SizedBox(height: 6),
          _InfoRow(
            label: context.l10n.mcpCodexToolFragmentLabel,
            value: tool.bodyText,
            copyable: true,
            maxLines: 6,
            valueColor: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _CodexToolEditDialog extends StatefulWidget {
  const _CodexToolEditDialog({required this.ref, required this.existing});

  final WidgetRef ref;
  final CodexTool? existing;

  @override
  State<_CodexToolEditDialog> createState() => _CodexToolEditDialogState();
}

class _CodexToolEditDialogState extends State<_CodexToolEditDialog> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _bodyCtrl;
  late String _kind;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _kind = existing?.kind ?? CodexToolKind.mcpServer;
    _enabled = existing?.enabled ?? true;
    _idCtrl = TextEditingController(text: existing?.id ?? '');
    _bodyCtrl = TextEditingController(
      text: existing?.bodyText ?? _defaultBodyText(_kind),
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final savedToast = context.l10n.providerSavedToast;
    final l10n = context.l10n;
    final id = _idCtrl.text.trim();
    final bodyText = _bodyCtrl.text.trim();
    if (id.isEmpty || bodyText.isEmpty) {
      SmartDialog.showToast(l10n.mcpCodexToolFillRequiredToast);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(codexToolActionsProvider.notifier)
          .save(
            CodexTool(
              id: id,
              kind: _kind,
              name: id,
              description: _firstConfigLine(bodyText),
              bodyText: bodyText,
              enabled: _enabled,
              managedByShim: true,
              readOnly: false,
            ),
          );
      SmartDialog.dismiss();
      SmartDialog.showToast(savedToast);
    } catch (error) {
      SmartDialog.showToast(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final existing = widget.existing;
    final l10n = context.l10n;
    final title = existing == null
        ? l10n.mcpCodexToolDialogTitleNew
        : l10n.mcpCodexToolDialogTitleEdit;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: colorScheme.surface,
          elevation: 18,
          shadowColor: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: context.l10n.cancel,
                        onPressed: _saving ? null : SmartDialog.dismiss,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 210,
                        child: _DialogField(
                          label: l10n.mcpCodexToolTypeLabel,
                          child: _KindSelector(
                            value: _kind,
                            enabled: existing == null && !_saving,
                            onChanged: (value) {
                              setState(() {
                                _kind = value;
                                _bodyCtrl.text = _defaultBodyText(value);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DialogField(
                          label: 'ID',
                          child: TextField(
                            controller: _idCtrl,
                            enabled: existing == null && !_saving,
                            style: const TextStyle(fontSize: 14),
                            decoration: _dialogInputDecoration(
                              context,
                              hintText: l10n.mcpCodexToolIdHint,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DialogField(
                    label: l10n.mcpCodexToolFragmentContentLabel,
                    child: TextField(
                      controller: _bodyCtrl,
                      enabled: !_saving,
                      minLines: 8,
                      maxLines: 12,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.45,
                      ),
                      decoration: _dialogInputDecoration(
                        context,
                        helperText: l10n.mcpCodexToolFragmentHelper,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _EnabledToggle(
                    label: l10n.mcpCodexToolEnabledLabel,
                    value: _enabled,
                    enabled: !_saving,
                    onChanged: (value) => setState(() => _enabled = value),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _saving ? null : SmartDialog.dismiss,
                        child: Text(context.l10n.cancel),
                      ),
                      SizedBox(width: AppSizes.itemGap),
                      FilledButton.icon(
                        onPressed: _saving ? null : () => _save(context),
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(context.l10n.providerSave),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(
    BuildContext context, {
    String? hintText,
    String? helperText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      helperText: helperText,
      isDense: true,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      helperStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        height: 1.2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
      ),
    );
  }

  String _defaultBodyText(String kind) {
    if (kind == CodexToolKind.skill) {
      return 'description = ""';
    }
    return 'command = ""\nargs = []';
  }

  String _firstConfigLine(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (final kind in CodexToolKind.values)
            Expanded(
              child: _KindSelectorOption(
                label: CodexToolKind.label(kind),
                selected: value == kind,
                enabled: enabled,
                onTap: () => onChanged(kind),
              ),
            ),
        ],
      ),
    );
  }
}

class _KindSelectorOption extends StatelessWidget {
  const _KindSelectorOption({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: enabled
                ? foreground
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.48),
          ),
        ),
      ),
    );
  }
}

class _EnabledToggle extends StatelessWidget {
  const _EnabledToggle({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_rounded : Icons.pause_circle_outline,
            size: 20,
            color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
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
              Switch(value: enabled, onChanged: loading ? null : onToggle),
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
          l10n.mcpStatusStopped,
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
    this.maxLines,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool copyable;
  final int? maxLines;
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
            maxLines: maxLines,
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

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
import 'package:shim/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shim/features/mcp/domain/models/mcp_server_info.dart';
import 'package:shim/features/mcp/presentation/providers/codex_mcp_config_action_provider.dart';
import 'package:shim/features/mcp/presentation/providers/codex_mcp_config_query_provider.dart';
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
          const _CodexMcpConfigSection(),
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

class _CodexMcpConfigSection extends ConsumerStatefulWidget {
  const _CodexMcpConfigSection();

  @override
  ConsumerState<_CodexMcpConfigSection> createState() =>
      _CodexMcpConfigSectionState();
}

class _CodexMcpConfigSectionState
    extends ConsumerState<_CodexMcpConfigSection> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(codexMcpConfigsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final deletedToast = context.l10n.deletedToast;
    final showProgress = _working || async.isRefreshing || async.isReloading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SectionTitle(title: l10n.mcpConfigTitle)),
            FilledButton.icon(
              onPressed: _working
                  ? null
                  : () => _showEditDialog(context, ref, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.mcpConfigAdd),
            ),
            IconButton(
              tooltip: context.l10n.refresh,
              onPressed: _working ? null : _refreshConfigs,
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
          error: (error, _) => _ErrorBox(message: error.toString()),
          data: (configs) {
            if (configs.isEmpty) {
              return _EmptyBox(message: l10n.mcpConfigEmpty);
            }
            return Column(
              children: [
                for (final config in configs) ...[
                  _CodexMcpConfigCard(
                    key: ValueKey('${config.kind}:${config.id}'),
                    config: config,
                    onEdit: () => _showEditDialog(context, ref, config),
                    onDelete: () async {
                      try {
                        await _runConfigAction(
                          () => ref
                              .read(codexMcpConfigActionsProvider.notifier)
                              .remove(kind: config.kind, id: config.id),
                        );
                        SmartDialog.showToast(deletedToast);
                      } catch (error) {
                        SmartDialog.showToast(error.toString());
                      }
                    },
                    onToggle: (enabled) {
                      return _runConfigAction(
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

  Future<void> _refreshConfigs() {
    return _runConfigAction(() async {});
  }

  Future<void> _runConfigAction(Future<void> Function() action) async {
    setState(() => _working = true);
    try {
      await action();
      ref.invalidate(codexMcpConfigsProvider);
      await ref.read(codexMcpConfigsProvider.future);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    CodexMcpConfig? existing,
  ) {
    SmartDialog.show(
      builder: (_) => _CodexMcpConfigEditDialog(ref: ref, existing: existing),
    );
  }
}

class _CodexMcpConfigCard extends StatefulWidget {
  const _CodexMcpConfigCard({
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
  State<_CodexMcpConfigCard> createState() => _CodexMcpConfigCardState();
}

class _CodexMcpConfigCardState extends State<_CodexMcpConfigCard> {
  late bool _enabled;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.config.enabled;
  }

  @override
  void didUpdateWidget(covariant _CodexMcpConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.id != widget.config.id ||
        oldWidget.config.kind != widget.config.kind ||
        oldWidget.config.enabled != widget.config.enabled) {
      _enabled = widget.config.enabled;
    }
  }

  Future<void> _toggle(bool enabled) async {
    final previous = _enabled;
    AppLogService.instance.info(
      'CodexMcpConfig',
      'UI 点击 MCP 配置开关',
      details:
          'kind=${widget.config.kind}\nid=${widget.config.id}\nfrom=$previous\nto=$enabled',
    );
    setState(() {
      _enabled = enabled;
      _toggling = true;
    });
    try {
      await widget.onToggle(enabled);
      AppLogService.instance.info(
        'CodexMcpConfig',
        'UI MCP 配置开关完成',
        details:
            'kind=${widget.config.kind}\nid=${widget.config.id}\nto=$enabled',
      );
    } catch (error) {
      AppLogService.instance.error(
        'CodexMcpConfig',
        'UI MCP 配置开关失败',
        details: 'kind=${widget.config.kind}\nid=${widget.config.id}\n$error',
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
    final config = widget.config;
    final typeLabel = CodexMcpConfigKind.label(config.kind);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(label: typeLabel, color: colorScheme.primary),
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
          _InfoRow(label: 'ID', value: config.id, copyable: true),
          const SizedBox(height: 6),
          _InfoRow(
            label: context.l10n.mcpConfigBodyLabel,
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

class _CodexMcpConfigEditDialog extends StatefulWidget {
  const _CodexMcpConfigEditDialog({required this.ref, required this.existing});

  final WidgetRef ref;
  final CodexMcpConfig? existing;

  @override
  State<_CodexMcpConfigEditDialog> createState() =>
      _CodexMcpConfigEditDialogState();
}

class _CodexMcpConfigEditDialogState extends State<_CodexMcpConfigEditDialog> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _bodyCtrl;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _enabled = existing?.enabled ?? true;
    _idCtrl = TextEditingController(text: existing?.id ?? '');
    _bodyCtrl = TextEditingController(
      text: existing?.bodyText ?? _defaultBodyText(),
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
      SmartDialog.showToast(l10n.mcpConfigFillRequiredToast);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(codexMcpConfigActionsProvider.notifier)
          .save(
            CodexMcpConfig(
              id: id,
              kind: CodexMcpConfigKind.mcpServer,
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
        ? l10n.mcpConfigDialogTitleNew
        : l10n.mcpConfigDialogTitleEdit;

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
                  _DialogField(
                    label: 'ID',
                    child: TextField(
                      controller: _idCtrl,
                      enabled: existing == null && !_saving,
                      style: const TextStyle(fontSize: 14),
                      decoration: _dialogInputDecoration(
                        context,
                        hintText: l10n.mcpConfigIdHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DialogField(
                    label: l10n.mcpConfigBodyContentLabel,
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
                        helperText: l10n.mcpConfigBodyHelper,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _EnabledToggle(
                    label: l10n.mcpConfigEnabledLabel,
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

  String _defaultBodyText() {
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

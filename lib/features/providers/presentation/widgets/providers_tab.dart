import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shim/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

class ProvidersTab extends ConsumerWidget {
  const ProvidersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(providerListProvider);
    final state = listAsync.value;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          SectionTitle(title: l10n.autoSwitch),
          SizedBox(height: AppSizes.sectionGap),
          const _AutoSwitchCard(),
          SizedBox(height: AppSizes.sectionGap),
          Row(
            children: [
              Expanded(child: SectionTitle(title: l10n.providers)),
              FilledButton.icon(
                onPressed: () => _showEditDialog(context, ref, null),
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
              _ProviderCard(
                provider: provider,
                selected: provider.id == state.selectedId,
                onSelect: () => ref
                    .read(providerActionsProvider.notifier)
                    .select(provider.id),
                onEdit: () => _showEditDialog(context, ref, provider),
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

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ApiProvider? existing,
  ) {
    SmartDialog.show(
      builder: (_) => _ProviderEditDialog(ref: ref, existing: existing),
    );
  }
}

class _ProviderEditDialog extends StatefulWidget {
  const _ProviderEditDialog({required this.ref, required this.existing});

  final WidgetRef ref;
  final ApiProvider? existing;

  @override
  State<_ProviderEditDialog> createState() => _ProviderEditDialogState();
}

class _ProviderEditDialogState extends State<_ProviderEditDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _baseUrlCtrl;
  late final TextEditingController _apiKeyCtrl;
  final _modelCtrl = TextEditingController();

  late List<String> _models;
  String? _selectedModel;
  late String _upstreamProtocol;
  late int _providerWeight;
  late int _modelWeight;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _baseUrlCtrl = TextEditingController(text: e?.baseUrl ?? '');
    _apiKeyCtrl = TextEditingController(text: e?.apiKey ?? '');
    _models = List.of(e?.models ?? const []);
    _selectedModel = e?.selectedModel;
    _upstreamProtocol = e?.upstreamProtocol ?? 'responses';
    _providerWeight = e?.providerWeight ?? 5;
    _modelWeight = e?.modelWeight ?? 5;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  void _addModel() {
    final m = _modelCtrl.text.trim();
    if (m.isEmpty || _models.contains(m)) return;
    setState(() {
      _models.add(m);
      _selectedModel ??= m;
      _modelCtrl.clear();
    });
  }

  void _removeModel(String m) {
    setState(() {
      _models.remove(m);
      if (_selectedModel == m) {
        _selectedModel = _models.isEmpty ? null : _models.first;
      }
    });
  }

  bool _fetching = false;

  Future<void> _fetchModels(BuildContext context) async {
    final l10n = context.l10n;
    final baseUrl = _baseUrlCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      SmartDialog.showToast(l10n.providerFillFirstToast);
      return;
    }
    setState(() => _fetching = true);
    try {
      final ids = await widget.ref.read(
        fetchProviderModelsProvider(baseUrl: baseUrl, apiKey: apiKey).future,
      );
      if (!mounted) return;
      setState(() {
        for (final id in ids) {
          if (!_models.contains(id)) _models.add(id);
        }
        _selectedModel ??= _models.isEmpty ? null : _models.first;
      });
      SmartDialog.showToast(l10n.providerFetchedToast(ids.length));
    } catch (e) {
      SmartDialog.showToast(l10n.providerFetchFailedToast(e.toString()));
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  Future<void> _save(BuildContext context) async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();
    if (name.isEmpty || baseUrl.isEmpty || apiKey.isEmpty) {
      SmartDialog.showToast(l10n.providerFillAllToast);
      return;
    }
    if (_selectedModel == null || _selectedModel!.isEmpty) {
      SmartDialog.showToast(l10n.providerSelectModelRequiredToast);
      return;
    }
    final ref = widget.ref;
    final existing = widget.existing;
    if (existing == null) {
      await ref.read(providerActionsProvider.notifier).add(
            ApiProvider(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: name,
              baseUrl: baseUrl,
              apiKey: apiKey,
              models: _models,
              selectedModel: _selectedModel,
              upstreamProtocol: _upstreamProtocol,
              providerWeight: _providerWeight,
              modelWeight: _modelWeight,
            ),
          );
    } else {
      await ref.read(providerActionsProvider.notifier).update(
            existing.copyWith(
              name: name,
              baseUrl: baseUrl,
              apiKey: apiKey,
              models: _models,
              selectedModel: _selectedModel,
              upstreamProtocol: _upstreamProtocol,
              providerWeight: _providerWeight,
              modelWeight: _modelWeight,
            ),
          );
    }
    SmartDialog.dismiss();
    SmartDialog.showToast(l10n.providerSavedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existing == null
                      ? l10n.providerEditTitleNew
                      : l10n.providerEditTitleEdit,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.providerName,
                    hintText: l10n.providerNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _baseUrlCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.providerBaseUrl,
                    hintText: l10n.providerBaseUrlHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.providerApiKey,
                    hintText: l10n.providerApiKeyHint,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.providerProtocol,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'responses',
                      label: Text(l10n.providerProtocolResponses),
                    ),
                    ButtonSegment(
                      value: 'chat',
                      label: Text(l10n.providerProtocolChat),
                    ),
                    ButtonSegment(
                      value: 'messages',
                      label: Text(l10n.providerProtocolMessages),
                    ),
                  ],
                  selected: {_upstreamProtocol},
                  onSelectionChanged: (v) =>
                      setState(() => _upstreamProtocol = v.first),
                ),
                const SizedBox(height: 14),
                _WeightRow(
                  label: l10n.providerWeight,
                  help: l10n.providerWeightHelp,
                  value: _providerWeight,
                  onChanged: (v) => setState(() => _providerWeight = v),
                ),
                _WeightRow(
                  label: l10n.modelWeight,
                  help: l10n.modelWeightHelp,
                  value: _modelWeight,
                  onChanged: (v) => setState(() => _modelWeight = v),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.providerModels,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _fetching ? null : () => _fetchModels(context),
                      icon: _fetching
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download_outlined, size: 18),
                      label: Text(l10n.providerModelsFetch),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _modelCtrl,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.providerModelInputHint,
                        ),
                        onSubmitted: (_) => _addModel(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _addModel,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (_models.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in _models)
                        InputChip(
                          label: Text(m),
                          selected: _selectedModel == m,
                          onSelected: (_) =>
                              setState(() => _selectedModel = m),
                          onDeleted: () => _removeModel(m),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _save(context),
                      child: Text(l10n.providerSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoSwitchCard extends ConsumerWidget {
  const _AutoSwitchCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncSettings = ref.watch(autoSwitchSettingsProvider);
    final settings = asyncSettings.value ?? const AutoSwitchSettings();
    final l10n = context.l10n;

    return SurfaceCard(
      padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AutoSwitchRowLabel(
            label: l10n.autoSwitchStrategy,
            help: l10n.autoSwitchStrategyHelp,
          ),
          SizedBox(height: 6.ch(min: 4, max: 8)),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'manual',
                label: Text(l10n.autoSwitchStrategyManual),
              ),
              ButtonSegment(
                value: 'failover',
                label: Text(l10n.autoSwitchStrategyFailover),
              ),
              ButtonSegment(
                value: 'fastest',
                label: Text(l10n.autoSwitchStrategyFastest),
              ),
            ],
            selected: {settings.strategy},
            onSelectionChanged: (v) => _save(
              ref,
              settings.copyWith(strategy: v.first),
            ),
          ),
          SizedBox(height: 14.ch(min: 10, max: 16)),
          _AutoSwitchRowLabel(
            label: l10n.autoSwitchScope,
            help: l10n.autoSwitchScopeHelp,
          ),
          SizedBox(height: 6.ch(min: 4, max: 8)),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'same-type',
                label: Text(l10n.autoSwitchScopeSameType),
              ),
              ButtonSegment(
                value: 'same-protocol',
                label: Text(l10n.autoSwitchScopeSameProtocol),
              ),
              ButtonSegment(
                value: 'any',
                label: Text(l10n.autoSwitchScopeAny),
              ),
            ],
            selected: {settings.scope},
            onSelectionChanged: (v) => _save(
              ref,
              settings.copyWith(scope: v.first),
            ),
          ),
          SizedBox(height: 14.ch(min: 10, max: 16)),
          Divider(color: colorScheme.outlineVariant, height: 1),
          SizedBox(height: 12.ch(min: 8, max: 14)),
          _AutoSwitchNumberRow(
            label: l10n.autoSwitchFailureThreshold,
            suffix: l10n.autoSwitchFailureThresholdUnit,
            value: settings.failureThreshold,
            min: 1,
            max: 10,
            help: l10n.autoSwitchFailureThresholdHelp,
            onChanged: (v) => _save(
              ref,
              settings.copyWith(failureThreshold: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: l10n.autoSwitchFastestMargin,
            suffix: l10n.autoSwitchFastestMarginUnit,
            value: settings.fastestMarginMs,
            min: 50,
            max: 2000,
            step: 50,
            help: l10n.autoSwitchFastestMarginHelp,
            onChanged: (v) => _save(
              ref,
              settings.copyWith(fastestMarginMs: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: l10n.autoSwitchCooldown,
            suffix: l10n.autoSwitchCooldownUnit,
            value: settings.cooldownSeconds,
            min: 5,
            max: 600,
            step: 5,
            help: l10n.autoSwitchCooldownHelp,
            onChanged: (v) => _save(
              ref,
              settings.copyWith(cooldownSeconds: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: l10n.autoSwitchProbeInterval,
            suffix: l10n.autoSwitchProbeIntervalUnit,
            value: settings.probeIntervalSeconds,
            min: 60,
            max: 1800,
            step: 30,
            help: l10n.autoSwitchProbeIntervalHelp,
            onChanged: (v) => _save(
              ref,
              settings.copyWith(probeIntervalSeconds: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: l10n.autoSwitchSlowTimeout,
            suffix: l10n.autoSwitchSlowTimeoutUnit,
            value: settings.slowRequestTimeoutSeconds,
            min: 0,
            max: 120,
            step: 5,
            help: l10n.autoSwitchSlowTimeoutHelp,
            onChanged: (v) => _save(
              ref,
              settings.copyWith(slowRequestTimeoutSeconds: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: l10n.autoSwitchSlowThreshold,
            suffix: l10n.autoSwitchSlowThresholdUnit,
            value: settings.slowRequestSwitchThreshold,
            min: 1,
            max: 10,
            help: l10n.autoSwitchSlowThresholdHelp,
            onChanged: (v) => _save(
              ref,
              settings.copyWith(slowRequestSwitchThreshold: v),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.ch(min: 2, max: 6)),
            child: Row(
              children: [
                Expanded(
                  child: _AutoSwitchRowLabel(
                    label: l10n.autoSwitchAllowSibling,
                    help: l10n.autoSwitchAllowSiblingHelp,
                  ),
                ),
                Switch(
                  value: settings.allowSameProviderSibling,
                  onChanged: (v) => _save(
                    ref,
                    settings.copyWith(allowSameProviderSibling: v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(WidgetRef ref, AutoSwitchSettings next) async {
    await ref.read(autoSwitchRepositoryProvider).save(settings: next);
    ref.invalidate(autoSwitchSettingsProvider);
  }
}

class _AutoSwitchRowLabel extends StatelessWidget {
  const _AutoSwitchRowLabel({required this.label, required this.help});

  final String label;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 6),
        Tooltip(
          message: help,
          waitDuration: const Duration(milliseconds: 300),
          preferBelow: false,
          child: MouseRegion(
            cursor: SystemMouseCursors.help,
            child: Icon(
              Icons.help_outline_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AutoSwitchNumberRow extends StatelessWidget {
  const _AutoSwitchNumberRow({
    required this.label,
    required this.suffix,
    required this.value,
    required this.min,
    required this.max,
    required this.help,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final String suffix;
  final int value;
  final int min;
  final int max;
  final int step;
  final String help;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.ch(min: 2, max: 6)),
      child: Row(
        children: [
          Expanded(
            child: _AutoSwitchRowLabel(label: label, help: help),
          ),
          IconButton(
            tooltip: '-',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: value > min ? () => onChanged((value - step).clamp(min, max)) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value $suffix',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            tooltip: '+',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: value < max ? () => onChanged((value + step).clamp(min, max)) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.label,
    required this.help,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String help;
  final int value;
  final ValueChanged<int> onChanged;

  static const _min = 1;
  static const _max = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 6),
                Tooltip(
                  message: help,
                  waitDuration: const Duration(milliseconds: 300),
                  preferBelow: false,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.help,
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: value > _min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: value < _max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final ApiProvider provider;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return SurfaceCard(
      padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelect,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 12.cw(min: 10, max: 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _WeightBadge(
                        text: 'P·${provider.providerWeight} M·${provider.modelWeight}',
                      ),
                    ],
                  ),
                  SizedBox(height: 4.ch(min: 3, max: 6)),
                  Text(
                    provider.baseUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.editProvider,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: l10n.deleteProvider,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightBadge extends StatelessWidget {
  const _WeightBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

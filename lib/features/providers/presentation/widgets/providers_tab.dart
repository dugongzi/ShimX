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

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          const SectionTitle(title: '自动切换'),
          SizedBox(height: AppSizes.sectionGap),
          const _AutoSwitchCard(),
          SizedBox(height: AppSizes.sectionGap),
          Row(
            children: [
              const Expanded(child: SectionTitle(title: '供应商')),
              FilledButton.icon(
                onPressed: () => _showEditDialog(context, ref, null),
                icon: const Icon(Icons.add_rounded),
                label: const Text('新增'),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sectionGap),
          if (state == null || state.providers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  '还没有供应商，点右上角新增',
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
                onSelect: () => ref.read(
                  selectProviderProvider(id: provider.id).future,
                ),
                onEdit: () => _showEditDialog(context, ref, provider),
                onDelete: () async {
                  await ref.read(
                    removeProviderProvider(id: provider.id).future,
                  );
                  SmartDialog.showToast('已删除');
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

  Future<void> _fetchModels() async {
    final baseUrl = _baseUrlCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      SmartDialog.showToast('先填 Base URL 和 API Key');
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
      SmartDialog.showToast('获取到 ${ids.length} 个模型');
    } catch (e) {
      SmartDialog.showToast('获取失败：$e');
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();
    if (name.isEmpty || baseUrl.isEmpty || apiKey.isEmpty) {
      SmartDialog.showToast('请填完整');
      return;
    }
    final ref = widget.ref;
    final existing = widget.existing;
    if (existing == null) {
      await ref.read(
        addProviderProvider(
          provider: ApiProvider(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: name,
            baseUrl: baseUrl,
            apiKey: apiKey,
            models: _models,
            selectedModel: _selectedModel,
            upstreamProtocol: _upstreamProtocol,
          ),
        ).future,
      );
    } else {
      await ref.read(
        updateProviderProvider(
          provider: existing.copyWith(
            name: name,
            baseUrl: baseUrl,
            apiKey: apiKey,
            models: _models,
            selectedModel: _selectedModel,
            upstreamProtocol: _upstreamProtocol,
          ),
        ).future,
      );
    }
    SmartDialog.dismiss();
    SmartDialog.showToast('已保存');
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.existing == null ? '新增供应商' : '编辑供应商',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: 'MuxueAI',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _baseUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://api.example.com/v1',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: 'sk-...',
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '供应商格式',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'responses', label: Text('Responses')),
                    ButtonSegment(value: 'chat', label: Text('Chat')),
                    ButtonSegment(value: 'messages', label: Text('Messages')),
                  ],
                  selected: {_upstreamProtocol},
                  onSelectionChanged: (v) =>
                      setState(() => _upstreamProtocol = v.first),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '模型',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _fetching ? null : _fetchModels,
                      icon: _fetching
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download_outlined, size: 18),
                      label: const Text('获取'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _modelCtrl,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'gpt-5.5 / claude-sonnet-4-6 ...',
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
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _selectedModel == null
                          ? null
                          : () => setState(() => _selectedModel = null),
                      child: const Text('用 Codex 默认（不覆盖）'),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _save,
                      child: const Text('保存'),
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

    return SurfaceCard(
      padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AutoSwitchRowLabel(
            label: '策略',
            help: 'manual: 只显示延迟,不自动切;\n'
                'failover: 当前连续失败 N 次后自动切到最快候选;\n'
                'fastest: 候选比当前快 ≥ 阈值就切',
          ),
          SizedBox(height: 6.ch(min: 4, max: 8)),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'manual', label: Text('手动')),
              ButtonSegment(value: 'failover', label: Text('故障转移')),
              ButtonSegment(value: 'fastest', label: Text('最快优先')),
            ],
            selected: {settings.strategy},
            onSelectionChanged: (v) => _save(
              ref,
              settings.copyWith(strategy: v.first),
            ),
          ),
          SizedBox(height: 14.ch(min: 10, max: 16)),
          _AutoSwitchRowLabel(
            label: '切换范围',
            help: 'same-type: 候选必须跟当前同模型家族(openai/claude/gemini);\n'
                'same-protocol: 候选必须跟当前同上游协议;\n'
                'any: 不限',
          ),
          SizedBox(height: 6.ch(min: 4, max: 8)),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'same-type', label: Text('同类型')),
              ButtonSegment(value: 'same-protocol', label: Text('同协议')),
              ButtonSegment(value: 'any', label: Text('任意')),
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
            label: '失败阈值',
            suffix: '次',
            value: settings.failureThreshold,
            min: 1,
            max: 10,
            help: 'failover 策略下,当前家连续失败几次后切换',
            onChanged: (v) => _save(
              ref,
              settings.copyWith(failureThreshold: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: '最快优先增益',
            suffix: 'ms',
            value: settings.fastestMarginMs,
            min: 50,
            max: 2000,
            step: 50,
            help: 'fastest 策略下,候选要比当前快多少 ms 才切',
            onChanged: (v) => _save(
              ref,
              settings.copyWith(fastestMarginMs: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: '冷却时间',
            suffix: '秒',
            value: settings.cooldownSeconds,
            min: 5,
            max: 600,
            step: 5,
            help: '切换后多少秒内不再二次切换,防反复横跳',
            onChanged: (v) => _save(
              ref,
              settings.copyWith(cooldownSeconds: v),
            ),
          ),
          _AutoSwitchNumberRow(
            label: '后台测速周期',
            suffix: '秒',
            value: settings.probeIntervalSeconds,
            min: 60,
            max: 1800,
            step: 30,
            help: '后台多少秒测一次速。manual 策略下完全不跑后台周期',
            onChanged: (v) => _save(
              ref,
              settings.copyWith(probeIntervalSeconds: v),
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
          child: Icon(
            Icons.help_outline_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
              tooltip: '编辑',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: '删除',
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/icon_badge.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/proxy_config.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

class ProvidersTab extends ConsumerWidget {
  const ProvidersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(providerListProvider);
    final state = listAsync.value;
    final proxyAsync = ref.watch(proxyConfigProvider);
    final proxy = proxyAsync.value ?? const ProxyConfig();
    final colorScheme = Theme.of(context).colorScheme;

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          _ProxyCard(proxy: proxy, isLoading: proxyAsync.isLoading),
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
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final baseUrlCtrl = TextEditingController(text: existing?.baseUrl ?? '');
    final apiKeyCtrl = TextEditingController(text: existing?.apiKey ?? '');

    SmartDialog.show(
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? '新增供应商' : '编辑供应商',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: 'MuxueAI',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: baseUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://api.example.com/v1',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: apiKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: 'sk-...',
                  ),
                ),
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
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final baseUrl = baseUrlCtrl.text.trim();
                        final apiKey = apiKeyCtrl.text.trim();
                        if (name.isEmpty || baseUrl.isEmpty || apiKey.isEmpty) {
                          SmartDialog.showToast('请填完整');
                          return;
                        }
                        if (existing == null) {
                          await ref.read(
                            addProviderProvider(
                              provider: ApiProvider(
                                id: DateTime.now()
                                    .microsecondsSinceEpoch
                                    .toString(),
                                name: name,
                                baseUrl: baseUrl,
                                apiKey: apiKey,
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
                              ),
                            ).future,
                          );
                        }
                        SmartDialog.dismiss();
                        SmartDialog.showToast('已保存');
                      },
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

class _ProxyCard extends ConsumerWidget {
  const _ProxyCard({required this.proxy, required this.isLoading});

  final ProxyConfig proxy;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceCard(
      padding: EdgeInsets.all(14.cw(min: 12, max: 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.route_rounded),
              SizedBox(width: 12.cw(min: 10, max: 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API 中转',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.ch(min: 3, max: 6)),
                    Text(
                      proxy.enabled
                          ? '已接管，请求转发到选中供应商 :${proxy.port}'
                          : '关闭时还原 config.toml',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSizes.sectionGap),
              Switch(
                value: proxy.enabled,
                onChanged: isLoading
                    ? null
                    : (value) => ref.read(
                        setProxyEnabledProvider(enabled: value).future,
                      ),
              ),
            ],
          ),
          if (proxy.enabled) ...[
            SizedBox(height: 12.ch(min: 10, max: 14)),
            TextFormField(
              key: ValueKey('port_${proxy.port}'),
              initialValue: proxy.port.toString(),
              enabled: !isLoading,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                isDense: true,
                labelText: '本地端口',
                hintText: '8787',
              ),
              onFieldSubmitted: (value) {
                final port = int.tryParse(value);
                if (port != null) {
                  ref.read(setProxyPortProvider(port: port).future);
                }
              },
            ),
          ],
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

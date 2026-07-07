import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/icon_badge.dart';
import 'package:shimx/common/widgets/surface_card.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/providers/domain/models/proxy_config.dart';
import 'package:shimx/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';

/// 本地代理总开关 + 端口编辑卡。
/// 开关由 [providerActionsProvider.setProxyEnabled] 驱动;端口由 [setProxyPort] 写入。
class ProxyCard extends HookConsumerWidget {
  const ProxyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final proxyAsync = ref.watch(proxyConfigProvider);
    final proxy = proxyAsync.value ?? const ProxyConfig();
    final isLoading = proxyAsync.isLoading;

    final portCtrl = useTextEditingController(text: proxy.port.toString());
    final syncedPort = useRef<int?>(null);

    // 持久化端口变化时同步到输入框(避免覆盖用户正在输入的内容)。
    if (syncedPort.value != proxy.port) {
      syncedPort.value = proxy.port;
      if (portCtrl.text != proxy.port.toString()) {
        portCtrl.text = proxy.port.toString();
      }
    }

    void savePort() {
      final parsed = int.tryParse(portCtrl.text);
      if (parsed == null || parsed < 1 || parsed > 65535) return;
      if (parsed == syncedPort.value) return;
      ref.read(providerActionsProvider.notifier).setProxyPort(parsed);
    }

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
                      l10n.proxy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: 4.ch(min: 3, max: 6)),
                    Text(
                      proxy.enabled
                          ? l10n.proxyEnabledDescription(proxy.port)
                          : l10n.proxyDisabledDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                    : (value) {
                        ref
                            .read(providerActionsProvider.notifier)
                            .setProxyEnabled(value);
                      },
              ),
            ],
          ),
          if (proxy.enabled) ...[
            SizedBox(height: 12.ch(min: 10, max: 14)),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: portCtrl,
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      isDense: true,
                      prefixText: ':',
                      labelText: l10n.proxyPort,
                    ),
                    onSubmitted: (_) => savePort(),
                  ),
                ),
                SizedBox(width: 12.cw(min: 8, max: 16)),
                FilledButton.tonal(
                  onPressed: isLoading ? null : savePort,
                  child: Text(l10n.providerSave),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

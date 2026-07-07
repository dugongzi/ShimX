import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/services/local_proxy_service.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';

/// 侧栏底部:本地代理服务状态。
/// 不带自身装饰,容器由 SidebarSystemPanel 统一提供。
class ProxyStatus extends ConsumerWidget {
  const ProxyStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final proxyConfig = ref.watch(proxyConfigProvider).value;
    final runningPortListenable = ref.watch(localProxyRunningPortProvider);

    return ValueListenableBuilder<int?>(
      valueListenable: runningPortListenable,
      builder: (context, runningPort, _) {
        final enabled = proxyConfig?.enabled == true;
        final running = runningPort != null;
        final dotColor = running
            ? Colors.green
            : enabled
                ? Colors.orange
                : colorScheme.onSurfaceVariant;
        final l10n = context.l10n;
        final text = running
            ? l10n.proxyRunningOnPort(runningPort)
            : enabled
                ? l10n.proxyEnabledOnPort(proxyConfig?.port ?? 8787)
                : l10n.proxyDisabled;

        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

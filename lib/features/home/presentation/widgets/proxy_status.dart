import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

/// 侧栏底部:本地代理服务状态。
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

        return Container(
          padding: EdgeInsets.all(10.cw(min: 8, max: 12)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: context.isDark ? 0.32 : 0.42,
            ),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: context.isDark ? 0.28 : 0.22,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSizes.itemGap),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

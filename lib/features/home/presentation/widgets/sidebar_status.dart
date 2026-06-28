import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/home/presentation/providers/inject_query_provider.dart';

/// 侧栏底部:Codex 调试端口连通状态(轮询)。
class SidebarStatus extends HookConsumerWidget {
  const SidebarStatus({super.key, this.debugPort = 9229});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncStatus = ref.watch(
      isDebugPortAliveProvider(debugPort: debugPort),
    );

    final pollInterval = asyncStatus.isLoading
        ? const Duration(seconds: 1)
        : asyncStatus.value == true
            ? const Duration(seconds: 10)
            : const Duration(seconds: 2);

    useEffect(() {
      final timer = Timer.periodic(pollInterval, (_) {
        ref.invalidate(isDebugPortAliveProvider(debugPort: debugPort));
      });
      return timer.cancel;
    }, [debugPort, pollInterval]);

    final Color dotColor;
    final String text;
    if (asyncStatus.isLoading) {
      dotColor = colorScheme.onSurfaceVariant;
      text = context.l10n.checkingStatus;
    } else if (asyncStatus.value == true) {
      dotColor = Colors.green;
      text = context.l10n.codexConnected;
    } else {
      dotColor = Colors.red;
      text = context.l10n.codexDisconnected;
    }

    return Container(
      padding: EdgeInsets.all(10.cw(min: 8, max: 12)),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.10 : 0.42,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
          IconButton(
            tooltip: context.l10n.refresh,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () =>
                ref.invalidate(isDebugPortAliveProvider(debugPort: debugPort)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

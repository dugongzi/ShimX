import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/home/presentation/providers/inject_query_provider.dart';

/// 侧栏底部:Codex 调试端口连通状态(轮询)。
/// 不带自身装饰,容器由父级提供;依赖 1s/10s 自动轮询,无手动刷新按钮。
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

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
  }
}

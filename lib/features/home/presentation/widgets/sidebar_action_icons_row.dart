import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/home/presentation/widgets/inject_icon.dart';
import 'package:shim/features/home/presentation/widgets/open_inspector_icon.dart';
import 'package:shim/features/home/presentation/widgets/reload_codex_icon.dart';

/// 侧栏底部一行三个动作图标:打开 inspector / 刷新 codex / 注入。
class SidebarActionIconsRow extends ConsumerWidget {
  const SidebarActionIconsRow({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OpenInspectorIcon(debugPort: debugPort),
          ReloadCodexIcon(debugPort: debugPort),
          InjectIcon(debugPort: debugPort),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/features/home/presentation/widgets/inject_icon.dart';
import 'package:shimx/features/home/presentation/widgets/open_inspector_icon.dart';
import 'package:shimx/features/home/presentation/widgets/reload_codex_icon.dart';

/// 侧栏底部一行三个动作图标:打开 inspector / 刷新 codex / 注入。
/// 不再带自身装饰,容器由 SidebarSystemPanel 统一提供。
class SidebarActionIconsRow extends ConsumerWidget {
  const SidebarActionIconsRow({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OpenInspectorIcon(debugPort: debugPort),
        ReloadCodexIcon(debugPort: debugPort),
        InjectIcon(debugPort: debugPort),
      ],
    );
  }
}

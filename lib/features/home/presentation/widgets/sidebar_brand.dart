import 'package:flutter/material.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/features/home/presentation/widgets/inject_icon.dart';
import 'package:shimx/features/home/presentation/widgets/open_inspector_icon.dart';
import 'package:shimx/features/home/presentation/widgets/reload_codex_icon.dart';

/// 侧栏顶部品牌区:SHIMX wordmark + 下方一行小图标动作。
class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.title, this.debugPort = 9229});

  final String title;
  final int debugPort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.itemGap,
        vertical: AppSizes.itemGap + 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamilyFallback: const [
                  'Segoe UI',
                  'SF Pro Display',
                  'Roboto',
                  'sans-serif',
                ],
                fontFamily: null,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 6,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 紧贴 wordmark 下方,三个小图标按钮,无容器、无背景
          IconTheme(
            data: IconThemeData(
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(28, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OpenInspectorIcon(debugPort: debugPort),
                  const SizedBox(width: 4),
                  ReloadCodexIcon(debugPort: debugPort),
                  const SizedBox(width: 4),
                  InjectIcon(debugPort: debugPort),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

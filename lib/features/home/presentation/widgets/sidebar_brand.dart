import 'package:flutter/material.dart';
import 'package:shim/core/constants/app_sizes.dart';

/// 侧栏顶部品牌区:标题居中,wordmark 风格。
class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.itemGap,
        vertical: AppSizes.itemGap + 6,
      ),
      child: Center(
        child: Text(
          title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            // 绕开 AppFonts.primary(AliMama),改用 sans-serif
            // 跨平台:Windows 用 Segoe UI,macOS 用 SF Pro,Linux 用 Roboto
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
            // 减薄 height,让 wordmark 更紧凑
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

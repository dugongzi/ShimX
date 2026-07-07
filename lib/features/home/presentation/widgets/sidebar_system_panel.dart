import 'package:flutter/material.dart';
import 'package:shimx/features/home/presentation/widgets/proxy_status.dart';
import 'package:shimx/features/home/presentation/widgets/sidebar_status.dart';

/// 侧栏底部两行裸文字状态:Codex 状态 / 代理状态。
/// 无容器,作为"系统脚注"轻量呈现。
class SidebarSystemPanel extends StatelessWidget {
  const SidebarSystemPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 横向内缩 ≈ tab item 内文字的起始位置,让状态行与 tab 视觉对齐
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SidebarStatus(),
          SizedBox(height: 6),
          ProxyStatus(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设置 tab 底部一行显示当前应用版本与构建号。
class AppVersionLine extends StatelessWidget {
  const AppVersionLine({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final text = info == null
            ? 'Shim'
            : 'Shim v${info.version} (${info.buildNumber})';
        return Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        );
      },
    );
  }
}

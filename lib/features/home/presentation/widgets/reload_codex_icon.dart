import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/home/presentation/providers/inject_orchestrator_provider.dart';

/// 侧栏底部:刷新 Codex 页面并重新注入。
class ReloadCodexIcon extends HookConsumerWidget {
  const ReloadCodexIcon({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReloading = useState(false);
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.refreshCodex,
      onPressed: isReloading.value
          ? null
          : () async {
              isReloading.value = true;
              try {
                ref.invalidate(
                  reloadCodexAndReinjectProvider(debugPort: debugPort),
                );
                await ref.read(
                  reloadCodexAndReinjectProvider(debugPort: debugPort).future,
                );
                SmartDialog.showToast(l10n.codexRefreshedToast);
              } catch (error) {
                SmartDialog.showToast(
                  l10n.codexRefreshFailedToast(error.toString()),
                );
              } finally {
                isReloading.value = false;
              }
            },
      icon: isReloading.value
          ? SizedBox(
              width: 18.cr(min: 16, max: 20),
              height: 18.cr(min: 16, max: 20),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
    );
  }
}

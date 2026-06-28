import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/codex_launcher_service.dart';
import 'package:shim/features/home/presentation/providers/inject_orchestrator_provider.dart';

/// 侧栏底部:启动 Codex + 注入 shim 的图标按钮。
class InjectIcon extends HookConsumerWidget {
  const InjectIcon({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInjecting = useState(false);
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.inject,
      onPressed: isInjecting.value
          ? null
          : () async {
              isInjecting.value = true;
              try {
                ref.invalidate(launchAndInjectProvider(debugPort: debugPort));
                await ref.read(
                  launchAndInjectProvider(debugPort: debugPort).future,
                );
                SmartDialog.showToast(l10n.injectSuccess);
              } on CodexNotInstalledException {
                SmartDialog.showToast(l10n.codexNotInstalled);
              } catch (e) {
                SmartDialog.showToast(l10n.launchFailed(e.toString()));
              } finally {
                isInjecting.value = false;
              }
            },
      icon: isInjecting.value
          ? SizedBox(
              width: 18.cr(min: 16, max: 20),
              height: 18.cr(min: 16, max: 20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.play_arrow_rounded),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/home/presentation/providers/inject_query_provider.dart';

/// 侧栏底部:在系统浏览器打开 Codex DevTools 的图标按钮。
class OpenInspectorIcon extends HookConsumerWidget {
  const OpenInspectorIcon({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpening = useState(false);
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.openInspector,
      onPressed: isOpening.value
          ? null
          : () async {
              isOpening.value = true;
              try {
                await ref.read(
                  openInspectorProvider(debugPort: debugPort).future,
                );
              } on CodexNotRunningException {
                SmartDialog.showToast(l10n.codexNotRunningError);
              } catch (e) {
                SmartDialog.showToast(l10n.openInspectorFailed(e.toString()));
              } finally {
                isOpening.value = false;
              }
            },
      icon: isOpening.value
          ? SizedBox(
              width: 18.cr(min: 16, max: 20),
              height: 18.cr(min: 16, max: 20),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.terminal_rounded),
    );
  }
}

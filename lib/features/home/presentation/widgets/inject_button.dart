import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/codex_launcher_service.dart';
import 'package:shim/features/home/presentation/providers/inject_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InjectButton extends HookConsumerWidget {
  const InjectButton({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInjecting = useState(false);

    return SizedBox(
      width: double.infinity,
      height: 46.ch(min: 42, max: 50),
      child: FilledButton.icon(
        onPressed: isInjecting.value
            ? null
            : () => _runInject(context, ref, isInjecting),
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
        label: Text(context.l10n.inject),
      ),
    );
  }

  Future<void> _runInject(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isInjecting,
  ) async {
    isInjecting.value = true;
    final l10n = context.l10n;
    try {
      ref.invalidate(launchAndInjectProvider(debugPort: debugPort));
      await ref.read(launchAndInjectProvider(debugPort: debugPort).future);
      SmartDialog.showToast(l10n.injectSuccess);
    } on CodexNotInstalledException {
      SmartDialog.showToast(l10n.codexNotInstalled);
    } catch (e) {
      SmartDialog.showToast(l10n.launchFailed(e.toString()));
    } finally {
      isInjecting.value = false;
    }
  }
}

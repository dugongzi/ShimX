import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/services/codex_launcher_service.dart';
import 'package:shimx/features/home/presentation/providers/inject_orchestrator_provider.dart';

/// 侧栏底部:启动 Codex + 注入 shimx 的图标按钮。
///
/// action 语义:按下才跑,`ref.read(.future)` 拿异步结果。
/// 用本地 `useState` 掌控转圈,不用 `ref.watch(provider)` —— 后者会在首帧
/// 立刻触发 provider,provider body 里的 IO / log 在 build 期间调 setState,
/// 会炸 setState-during-build。
class InjectIcon extends HookConsumerWidget {
  const InjectIcon({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isInjecting = useState(false);

    Future<void> handlePressed() async {
      isInjecting.value = true;
      try {
        // 直接调 core function,不走 provider —— provider 层是包装,body 抛异常
        // 时 autoDispose 生命周期会踩 "Ref after disposed",走 container 版本
        // 就没这坑,异常正常 rethrow。
        await runLaunchAndInject(ref.container, debugPort: debugPort);
        SmartDialog.showToast(l10n.injectSuccess);
      } on CodexNotInstalledException {
        SmartDialog.showToast(l10n.codexNotInstalled);
      } on CodexRunningWithoutDebugException {
        SmartDialog.showToast(l10n.codexRunningWithoutDebugBody);
      } catch (e) {
        SmartDialog.showToast(l10n.launchFailed(e.toString()));
      } finally {
        isInjecting.value = false;
      }
    }

    return IconButton(
      tooltip: l10n.inject,
      onPressed: isInjecting.value ? null : handlePressed,
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

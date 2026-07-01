import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/home/presentation/providers/inject_orchestrator_provider.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:shim/features/scripts/presentation/providers/script_action_provider.dart';
import 'package:shim/features/scripts/presentation/providers/script_query_provider.dart';
import 'package:shim/features/scripts/presentation/widgets/new_script_dialog.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_code_view.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_empty_view.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_sidebar.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_status_bar.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_title_bar.dart';

const _kNewScriptTemplate = '''// ==Shim==
// @name        My Script
// @description 脚本描述
// @version     1.0.0
// @author
// @layer       user
// ==/Shim==

(() => {
  if (!window.__shimCodex) return;

  // 在这里编写你的注入逻辑
  console.log('[MyScript] loaded');
})();
''';

const _kDebugPort = 9229;

class ScriptEditorShell extends HookConsumerWidget {
  const ScriptEditorShell({
    super.key,
    required this.scripts,
    required this.initialScriptId,
  });

  final List<InjectScript> scripts;
  final String? initialScriptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final selectedId = useState<String?>(initialScriptId);
    final current = selectedId.value == null
        ? null
        : scripts.where((s) => s.id == selectedId.value).firstOrNull;

    // 脚本被外部删除时,自动清空选中
    if (selectedId.value != null && current == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedId.value != null &&
            scripts.every((s) => s.id != selectedId.value)) {
          selectedId.value = null;
        }
      });
    }

    final controllerKey = current?.id ?? '__empty__';
    final controller = useMemoized(
      () => CodeLineEditingController.fromText(current?.code ?? ''),
      [controllerKey],
    );
    useEffect(() => controller.dispose, [controller]);

    final dirty = useState(false);
    final saving = useState(false);
    final running = useState(false);
    final line = useState<int?>(null);
    final column = useState<int?>(null);

    useEffect(() {
      final initialCode = current?.code ?? '';
      void schedule(void Function() body) {
        WidgetsBinding.instance.addPostFrameCallback((_) => body());
      }

      void onCode() {
        final selection = controller.selection;
        schedule(() {
          dirty.value = controller.text != initialCode;
          if (selection.baseIndex >= 0) {
            line.value = selection.baseIndex;
            column.value = selection.baseOffset;
          } else {
            line.value = null;
            column.value = null;
          }
        });
      }

      controller.addListener(onCode);
      return () => controller.removeListener(onCode);
    }, [controller]);

    // saveCurrent 是纯写盘 + invalidate,不弹 toast,让快捷键/自动保存/Run 共用。
    // dirty 由 onCode 用「controller.text != initialCode」判定,initialCode 是
    // useEffect 里的快照不会随保存刷新,所以这里成功后需要手动置 false。
    Future<bool> saveCurrent({bool silentOnMissing = false}) async {
      if (current == null) {
        if (!silentOnMissing) {
          SmartDialog.showToast(l10n.selectScriptFirst);
        }
        return false;
      }
      final ok = await ref.read(
        saveScriptProvider(id: current.id, code: controller.text).future,
      );
      if (!ok) {
        if (!silentOnMissing) SmartDialog.showToast(l10n.scriptSaveFailed);
        return false;
      }
      ref.invalidate(scriptsProvider);
      dirty.value = false;
      return true;
    }

    final hotRunAsync = ref.watch(hotRunProvider);
    final hotRun = hotRunAsync.value ?? false;

    Future<void> handleHotRunChanged(bool value) async {
      try {
        await ref.read(setHotRunProvider(value: value).future);
        ref.invalidate(hotRunProvider);
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    // handleRun 由下方定义,handleSave 里通过闭包引用可能拿不到最新值;
    // 用 ref cell 中转,让手动保存完成后能触发一次运行。
    final runAfterSaveRef = useRef<Future<void> Function()?>(null);

    // 手动/快捷键触发的显式保存,无 toast(状态栏会显示 Saved)。
    // 热运行开启时,仅手动路径(triggerRun=true)保存后自动 Run;
    // 1s 防抖自动保存传 triggerRun=false,避免每敲一下键就重跑。
    // 无 dirty 时手动路径不写盘,但仍要触发热运行(用户按 Ctrl+S 就是想跑一次)。
    Future<void> handleSave({bool triggerRun = true}) async {
      if (saving.value || current == null) return;
      if (dirty.value) {
        saving.value = true;
        try {
          await saveCurrent(silentOnMissing: true);
        } catch (e) {
          SmartDialog.showToast(e.toString());
        } finally {
          saving.value = false;
        }
      } else if (!triggerRun) {
        return;
      }
      if (triggerRun && hotRun) {
        await runAfterSaveRef.value?.call();
      }
    }

    // 内容变化后 1s 无输入自动保存(防抖),与 handleSave 共享 saving 锁。
    final autoSaveTimer = useRef<Timer?>(null);
    useEffect(() {
      void onDirty() {
        if (!dirty.value) return;
        autoSaveTimer.value?.cancel();
        autoSaveTimer.value = Timer(const Duration(seconds: 1), () {
          if (dirty.value && !saving.value) handleSave(triggerRun: false);
        });
      }

      dirty.addListener(onDirty);
      return () {
        dirty.removeListener(onDirty);
        autoSaveTimer.value?.cancel();
      };
    }, [dirty, current?.id]);

    final reloadOnRunAsync = ref.watch(reloadOnRunProvider);
    final reloadOnRun = reloadOnRunAsync.value ?? true;

    Future<void> handleReloadOnRunChanged(bool value) async {
      try {
        await ref.read(setReloadOnRunProvider(value: value).future);
        ref.invalidate(reloadOnRunProvider);
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    Future<void> handleRun() async {
      if (running.value || saving.value) return;
      if (current == null) {
        SmartDialog.showToast(l10n.selectScriptFirst);
        return;
      }
      running.value = true;
      try {
        if (!await saveCurrent()) return;
        await ref.read(
          setScriptsEnabledProvider(ids: [current.id], enabled: true).future,
        );
        ref.invalidate(scriptEnabledProvider(id: current.id));
        if (reloadOnRun) {
          ref.invalidate(
            reloadCodexAndReinjectProvider(debugPort: _kDebugPort),
          );
          await ref.read(
            reloadCodexAndReinjectProvider(debugPort: _kDebugPort).future,
          );
        } else {
          ref.invalidate(
            injectToRunningPortProvider(debugPort: _kDebugPort),
          );
          await ref.read(
            injectToRunningPortProvider(debugPort: _kDebugPort).future,
          );
        }
        SmartDialog.showToast(l10n.scriptRunSuccess);
      } catch (e) {
        SmartDialog.showToast(e.toString());
      } finally {
        running.value = false;
      }
    }

    // 让 handleSave 通过 ref 拿到最新的 handleRun 闭包。
    runAfterSaveRef.value = handleRun;

    Future<void> handleNew() async {
      final existingNames = scripts.map((s) => s.id.toLowerCase()).toSet();
      final name = await NewScriptDialog.show(context, existingNames);
      if (name == null) return;
      try {
        final id = await ref.read(
          createScriptProvider(name: name, code: _kNewScriptTemplate).future,
        );
        ref.invalidate(scriptsProvider);
        SmartDialog.showToast(l10n.scriptCreateSuccess);
        selectedId.value = id;
      } catch (e) {
        SmartDialog.showToast(e.toString());
      }
    }

    void selectScript(InjectScript script) {
      if (script.id == selectedId.value) return;
      selectedId.value = script.id;
    }

    return CallbackShortcuts(
      bindings: {
        // 快捷键跟平台走:mac 用 Cmd+S,其它平台用 Ctrl+S
        SingleActivator(
          LogicalKeyboardKey.keyS,
          control: !Platform.isMacOS,
          meta: Platform.isMacOS,
        ): handleSave,
      },
      child: Focus(
        autofocus: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScriptEditorTitleBar(
                script: current,
                dirty: dirty.value,
                running: running.value,
                onRun: current != null && !running.value ? handleRun : null,
                onClose: () => context.pop(),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScriptEditorSidebar(
                      scripts: scripts,
                      selectedId: selectedId.value,
                      dirty: dirty.value,
                      onSelect: selectScript,
                      onNew: handleNew,
                    ),
                    Expanded(
                      child: current == null
                          ? const ScriptEditorEmptyView()
                          : ScriptEditorCodeView(
                              controller: controller,
                              onSave: handleSave,
                            ),
                    ),
                  ],
                ),
              ),
              ScriptEditorStatusBar(
                line: line.value,
                column: column.value,
                language: 'JavaScript',
                encoding: 'UTF-8',
                dirty: dirty.value,
                saving: saving.value,
                hasScript: current != null,
                hotRun: hotRun,
                onHotRunChanged: handleHotRunChanged,
                reloadOnRun: reloadOnRun,
                onReloadOnRunChanged: handleReloadOnRunChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

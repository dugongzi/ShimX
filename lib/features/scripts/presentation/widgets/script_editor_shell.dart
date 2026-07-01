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
      return true;
    }

    // 手动/快捷键触发的显式保存,无 toast(状态栏会显示 Saved)。
    Future<void> handleSave() async {
      if (saving.value || current == null || !dirty.value) return;
      saving.value = true;
      try {
        await saveCurrent(silentOnMissing: true);
      } catch (e) {
        SmartDialog.showToast(e.toString());
      } finally {
        saving.value = false;
      }
    }

    // 内容变化后 1s 无输入自动保存(防抖),与 handleSave 共享 saving 锁。
    final autoSaveTimer = useRef<Timer?>(null);
    useEffect(() {
      void onDirty() {
        if (!dirty.value) return;
        autoSaveTimer.value?.cancel();
        autoSaveTimer.value = Timer(const Duration(seconds: 1), () {
          if (dirty.value && !saving.value) handleSave();
        });
      }

      dirty.addListener(onDirty);
      return () {
        dirty.removeListener(onDirty);
        autoSaveTimer.value?.cancel();
      };
    }, [dirty, current?.id]);

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
        ref.invalidate(
          reloadCodexAndReinjectProvider(debugPort: _kDebugPort),
        );
        await ref.read(
          reloadCodexAndReinjectProvider(debugPort: _kDebugPort).future,
        );
        SmartDialog.showToast(l10n.scriptRunSuccess);
      } catch (e) {
        SmartDialog.showToast(e.toString());
      } finally {
        running.value = false;
      }
    }

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
                          : ScriptEditorCodeView(controller: controller),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

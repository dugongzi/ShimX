import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/home/presentation/providers/inject_query_provider.dart';
import 'package:shimx/features/scripts/presentation/widgets/script_editor_status_item.dart';

class ScriptEditorStatusBar extends StatelessWidget {
  const ScriptEditorStatusBar({
    super.key,
    required this.line,
    required this.column,
    required this.language,
    required this.encoding,
    required this.dirty,
    required this.saving,
    required this.hasScript,
    required this.hotRun,
    required this.onHotRunChanged,
    required this.reloadOnRun,
    required this.onReloadOnRunChanged,
    required this.debugPort,
  });

  /// 光标行(1-based 展示前 +1);null 表示无光标信息
  final int? line;
  final int? column;
  final String language;
  final String encoding;
  final bool dirty;
  final bool saving;
  final bool hasScript;
  final bool hotRun;
  final ValueChanged<bool> onHotRunChanged;
  final bool reloadOnRun;
  final ValueChanged<bool> onReloadOnRunChanged;
  final int debugPort;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = colorScheme.primary;
    final l10n = context.l10n;

    String? saveLabel;
    if (hasScript) {
      if (saving) {
        saveLabel = l10n.editorSavingLabel;
      } else if (dirty) {
        saveLabel = l10n.editorUnsavedLabel;
      } else {
        saveLabel = l10n.editorSavedLabel;
      }
    }

    return Container(
      height: 22,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (saveLabel != null) ScriptEditorStatusItem(text: saveLabel),
          const Spacer(),
          _OpenInspectorButton(debugPort: debugPort),
          const SizedBox(width: 12),
          _StatusSwitch(
            label: l10n.editorHotRun,
            tooltip: l10n.editorHotRunTooltip,
            value: hotRun,
            onChanged: onHotRunChanged,
          ),
          const SizedBox(width: 12),
          _StatusSwitch(
            label: l10n.editorReloadOnRun,
            tooltip: l10n.editorReloadOnRunTooltip,
            value: reloadOnRun,
            onChanged: onReloadOnRunChanged,
          ),
          const SizedBox(width: 16),
          if (line != null && column != null)
            ScriptEditorStatusItem(
              text: '${l10n.editorLine} ${line! + 1}, ${l10n.editorColumn} ${column! + 1}',
            ),
          const SizedBox(width: 16),
          ScriptEditorStatusItem(text: language),
          const SizedBox(width: 16),
          ScriptEditorStatusItem(text: encoding),
        ],
      ),
    );
  }
}

/// 22px 状态栏里的紧凑版控制台按钮,复用 [openInspectorProvider]。
/// 用点击 icon + label 的形式,不用 IconButton 避免最小 44px 命中区把状态栏撑爆。
class _OpenInspectorButton extends HookConsumerWidget {
  const _OpenInspectorButton({required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final isOpening = useState(false);

    Future<void> onTap() async {
      if (isOpening.value) return;
      isOpening.value = true;
      try {
        await ref.read(openInspectorProvider(debugPort: debugPort).future);
      } on CodexNotRunningException {
        SmartDialog.showToast(l10n.codexNotRunningError);
      } catch (e) {
        SmartDialog.showToast(l10n.openInspectorFailed(e.toString()));
      } finally {
        isOpening.value = false;
      }
    }

    return Tooltip(
      message: l10n.openInspector,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOpening.value)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onPrimary,
                  ),
                )
              else
                Icon(
                  Icons.terminal_rounded,
                  size: 14,
                  color: onPrimary,
                ),
              const SizedBox(width: 4),
              ScriptEditorStatusItem(text: l10n.openInspector),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  const _StatusSwitch({
    required this.label,
    required this.tooltip,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String tooltip;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScriptEditorStatusItem(text: label),
          const SizedBox(width: 6),
          SizedBox(
            height: 18,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeThumbColor: onPrimary,
                activeTrackColor: onPrimary.withValues(alpha: 0.35),
                inactiveThumbColor: onPrimary.withValues(alpha: 0.85),
                inactiveTrackColor: onPrimary.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

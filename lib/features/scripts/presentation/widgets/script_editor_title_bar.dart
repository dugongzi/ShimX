import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';

class ScriptEditorTitleBar extends StatelessWidget {
  const ScriptEditorTitleBar({
    super.key,
    required this.script,
    required this.dirty,
    required this.running,
    required this.onRun,
    required this.onClose,
  });

  final InjectScript? script;
  final bool dirty;
  final bool running;
  final VoidCallback? onRun;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    // seedColor 深染:略强于 sidebar,构成层次
    final bg = colorScheme.surfaceContainerHigh;
    final fg = colorScheme.onSurface;
    final divider = colorScheme.outlineVariant;

    final filePath = script?.filePath;
    final dirPath = filePath == null ? null : p.dirname(filePath);

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  tooltip: l10n.back,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: onClose,
                  icon: Icon(Icons.arrow_back_rounded, color: fg),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.javascript_rounded,
                  size: 16,
                  color: Color(0xFFF7DF1E),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Text(
                    script?.id ?? l10n.noScriptSelected,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: script == null
                          ? fg.withValues(alpha: 0.45)
                          : fg,
                      fontSize: 13,
                      fontStyle:
                          script == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                if (dirty) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  tooltip: l10n.run,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: onRun,
                  icon: running
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          color: onRun == null
                              ? fg.withValues(alpha: 0.35)
                              : const Color(0xFF16A34A),
                        ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (dirPath != null) _FilePathBar(path: dirPath, fg: fg),
          Container(height: 1, color: divider),
        ],
      ),
    );
  }
}

/// 显示脚本磁盘绝对路径,方便用户复制给 AI/文件管理器。
/// 单独一行,支持横向滚动,避免长路径挤爆 title bar。
class _FilePathBar extends StatelessWidget {
  const _FilePathBar({required this.path, required this.fg});

  final String path;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtleFg = fg.withValues(alpha: 0.65);

    Future<void> handleCopy() async {
      await Clipboard.setData(ClipboardData(text: path));
      SmartDialog.showToast(l10n.copied);
    }

    return SizedBox(
      height: 24,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.folder_open_rounded, size: 14, color: subtleFg),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                path,
                maxLines: 1,
                style: TextStyle(
                  color: subtleFg,
                  fontSize: 11,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: l10n.copy,
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: handleCopy,
            icon: Icon(Icons.copy_rounded, color: subtleFg),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

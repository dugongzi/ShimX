import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

/// 用户脚本手册弹窗。按当前界面语言选择 zh/en 一份 md 文件,
/// flutter_markdown 渲染。右上角复制按钮把当前手册原文写入剪贴板。
class ScriptEditorManualDialog extends StatefulWidget {
  const ScriptEditorManualDialog({super.key});

  static const _zhAsset = 'assets/docs/user_script_manual_zh.md';
  static const _enAsset = 'assets/docs/user_script_manual_en.md';

  /// 通过 SmartDialog 弹出。dialog 自身处理关闭。
  static void show(BuildContext context) {
    SmartDialog.show(
      alignment: Alignment.center,
      clickMaskDismiss: true,
      builder: (_) => const ScriptEditorManualDialog(),
    );
  }

  @override
  State<ScriptEditorManualDialog> createState() =>
      _ScriptEditorManualDialogState();
}

class _ScriptEditorManualDialogState extends State<ScriptEditorManualDialog> {
  Future<String>? _future;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final asset = context.isZh
        ? ScriptEditorManualDialog._zhAsset
        : ScriptEditorManualDialog._enAsset;
    // 语言变了(用户设置里切) → 重新读一次。缓存 future 避免每次 rebuild 重复 IO。
    _future ??= rootBundle.loadString(asset);

    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.72).clamp(480.0, 900.0);
    final height = (size.height * 0.82).clamp(400.0, 900.0);

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: width,
        height: height,
        child: FutureBuilder<String>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(
                message: l10n.editorManualLoadFailed(
                  snapshot.error.toString(),
                ),
              );
            }
            final md = snapshot.data ?? '';
            return _ManualContent(markdown: md);
          },
        ),
      ),
    );
  }
}

class _ManualContent extends StatelessWidget {
  const _ManualContent({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> handleCopy() async {
      await Clipboard.setData(ClipboardData(text: markdown));
      SmartDialog.showToast(l10n.copied);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(onCopy: handleCopy, onClose: () => SmartDialog.dismiss()),
        Divider(height: 1, color: colorScheme.outlineVariant),
        Expanded(
          child: Markdown(
            data: markdown,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            selectable: true,
            styleSheet: _buildStyleSheet(context),
            onTapLink: (text, href, title) {
              // 手册里没有需要跳转的外链,忽略即可。
            },
          ),
        ),
      ],
    );
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return base.copyWith(
      p: base.p?.copyWith(fontSize: 14, height: 1.6),
      h1: base.h1?.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
      h2: base.h2?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      h3: base.h3?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
      code: base.code?.copyWith(
        fontFamily: 'Courier',
        fontSize: 13,
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableBorder: TableBorder.all(
        color: colorScheme.outlineVariant,
        width: 1,
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCopy, required this.onClose});

  final VoidCallback onCopy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.editorManual,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(l10n.copy),
          ),
          IconButton(
            tooltip: l10n.close,
            visualDensity: VisualDensity.compact,
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

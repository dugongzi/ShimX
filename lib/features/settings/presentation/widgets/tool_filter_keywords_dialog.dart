import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/providers/tool_filter_keywords_provider.dart';

/// 工具过滤关键词管理弹窗。
///
/// 每次增删立即持久化 + 立即推给运行中的 proxy。用户可自由删掉默认项。
class ToolFilterKeywordsDialog extends ConsumerStatefulWidget {
  const ToolFilterKeywordsDialog({super.key});

  @override
  ConsumerState<ToolFilterKeywordsDialog> createState() =>
      _ToolFilterKeywordsDialogState();
}

class _ToolFilterKeywordsDialogState
    extends ConsumerState<ToolFilterKeywordsDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() => _errorText = context.l10n.toolFilterKeywordEmpty);
      return;
    }
    final list = ref.read(toolFilterKeywordsProvider);
    if (list.any((k) => k.keyword == raw)) {
      setState(() => _errorText = context.l10n.toolFilterKeywordDuplicate);
      return;
    }
    await ref.read(toolFilterKeywordsProvider.notifier).add(raw);
    _controller.clear();
    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final keywords = ref.watch(toolFilterKeywordsProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.toolFilterKeywordsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: SmartDialog.dismiss,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.toolFilterKeywordsDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        isDense: true,
                        hintText: l10n.toolFilterKeywordHint,
                        errorText: _errorText,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      onSubmitted: (_) => _add(),
                      onChanged: (_) {
                        if (_errorText != null) {
                          setState(() => _errorText = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: IconButton.filled(
                      onPressed: _add,
                      icon: const Icon(Icons.add_rounded),
                      tooltip: l10n.toolFilterKeywordAdd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: keywords.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.toolFilterKeywordsEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final kw in keywords)
                              _KeywordChip(
                                entry: kw,
                                onToggle: (v) => ref
                                    .read(toolFilterKeywordsProvider.notifier)
                                    .setEnabled(kw.keyword, v),
                                onRemove: () => ref
                                    .read(toolFilterKeywordsProvider.notifier)
                                    .remove(kw.keyword),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({
    required this.entry,
    required this.onToggle,
    required this.onRemove,
  });

  final ToolFilterKeyword entry;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = entry.enabled;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 2, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: enabled
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: enabled ? colorScheme.outlineVariant : colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 用缩放让 Switch 更贴合 chip 高度
          Transform.scale(
            scale: 0.6,
            child: Switch(
              value: enabled,
              onChanged: onToggle,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              entry.keyword,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                decoration:
                    enabled ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

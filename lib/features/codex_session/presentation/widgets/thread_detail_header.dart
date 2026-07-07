import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_action_provider.dart';

/// 详情视图顶部:标题 + cwd 路径 + 右上角导出菜单。
class ThreadDetailHeader extends ConsumerWidget {
  const ThreadDetailHeader({super.key, required this.detail});

  final CodexThreadDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = detail.title.isEmpty ? detail.id : detail.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                detail.cwd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: l10n.sessionExport,
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (value) => _export(context, ref, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'markdown',
              child: Text(l10n.sessionExportMarkdown),
            ),
            PopupMenuItem(
              value: 'raws',
              child: Text(l10n.sessionExportRaw),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    final l10n = context.l10n;
    try {
      final path = await ref.read(
        exportCodexThreadProvider(detail: detail, format: format).future,
      );
      if (path == null) return;
      SmartDialog.showToast(l10n.sessionExportSuccess);
    } catch (e) {
      SmartDialog.showToast(l10n.sessionExportFailed(e.toString()));
    }
  }
}

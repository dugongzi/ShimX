import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/section_title.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/logs/presentation/providers/logs_query_provider.dart';
import 'package:shimx/core/utils/log_format.dart';

/// 日志 tab 顶部:标题 + 复制全部 + 清空 两个 icon 按钮。
class LogsToolbar extends ConsumerWidget {
  const LogsToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final logService = ref.watch(logsServiceProvider);

    return Row(
      children: [
        Expanded(child: SectionTitle(title: l10n.logs)),
        IconButton(
          tooltip: l10n.logsCopy,
          onPressed: () async {
            final text = logService.value.map(formatLogEntryForCopy).join('\n');
            await Clipboard.setData(ClipboardData(text: text));
            SmartDialog.showToast(l10n.logsCopiedToast);
          },
          icon: const Icon(Icons.content_copy_rounded),
        ),
        IconButton(
          tooltip: l10n.logsClear,
          onPressed: logService.clear,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

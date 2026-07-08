import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/update/presentation/providers/app_update_provider.dart';

/// 侧栏品牌区:有新版本时展示绿色下载按钮。
class UpdateDownloadIcon extends ConsumerWidget {
  const UpdateDownloadIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateAsync = ref.watch(appUpdateCheckProvider);
    final l10n = context.l10n;
    final result = updateAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final release = result?.canDownload == true ? result!.item : null;
    final visible = release != null;

    if (!visible) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        SizedBox.square(
          dimension: 28,
          child: IconButton(
            tooltip: l10n.updateDownload,
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green.shade600,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: Colors.transparent,
              hoverColor: Colors.green.shade500,
              minimumSize: const Size(28, 28),
              padding: const EdgeInsets.all(6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () async {
              try {
                await ref
                    .read(appUpdateActionRepositoryProvider)
                    .openDownload(release);
              } catch (e) {
                SmartDialog.showToast(l10n.updateDownloadFailed(e.toString()));
              }
            },
            icon: const Icon(Icons.download_rounded),
          ),
        ),
      ],
    );
  }
}

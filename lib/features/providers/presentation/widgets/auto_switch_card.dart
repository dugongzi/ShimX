import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/utils/auto_switch_label.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shim/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shim/features/providers/presentation/widgets/auto_switch_dialog.dart';

/// providers tab 顶部:展示当前自动切换策略 + 一个按钮打开详细设置 dialog。
class AutoSwitchCard extends ConsumerWidget {
  const AutoSwitchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncSettings = ref.watch(autoSwitchSettingsProvider);
    final settings = asyncSettings.value ?? const AutoSwitchSettings();
    final l10n = context.l10n;

    return SurfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: 14.cw(min: 12, max: 16),
        vertical: 10.ch(min: 8, max: 12),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz_rounded, color: colorScheme.primary),
          SizedBox(width: 12.cw(min: 10, max: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.autoSwitch,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: 2.ch(min: 1, max: 4)),
                Text(
                  autoSwitchStrategyLabel(context, settings.strategy),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.autoSwitch,
            onPressed: () => SmartDialog.show(
              builder: (_) => const AutoSwitchDialog(),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }
}

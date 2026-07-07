import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/constants/auto_switch_options.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shimx/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shimx/features/providers/presentation/widgets/auto_switch_number_row.dart';
import 'package:shimx/features/providers/presentation/widgets/auto_switch_row_label.dart';

/// 自动切换详细参数对话框:策略 / 范围 / 各阈值。
class AutoSwitchDialog extends ConsumerWidget {
  const AutoSwitchDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncSettings = ref.watch(autoSwitchSettingsProvider);
    final settings = asyncSettings.value ?? const AutoSwitchSettings();
    final l10n = context.l10n;

    Future<void> save(AutoSwitchSettings next) async {
      await ref.read(autoSwitchRepositoryProvider).save(settings: next);
      ref.invalidate(autoSwitchSettingsProvider);
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.autoSwitch,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => SmartDialog.dismiss(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AutoSwitchRowLabel(
                        label: l10n.autoSwitchStrategy,
                        help: l10n.autoSwitchStrategyHelp,
                      ),
                      SizedBox(height: 6.ch(min: 4, max: 8)),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: autoSwitchStrategyManual,
                            label: Text(l10n.autoSwitchStrategyManual),
                          ),
                          ButtonSegment(
                            value: autoSwitchStrategyFailover,
                            label: Text(l10n.autoSwitchStrategyFailover),
                          ),
                          ButtonSegment(
                            value: autoSwitchStrategyFastest,
                            label: Text(l10n.autoSwitchStrategyFastest),
                          ),
                        ],
                        selected: {settings.strategy},
                        onSelectionChanged: (v) =>
                            save(settings.copyWith(strategy: v.first)),
                      ),
                      SizedBox(height: 14.ch(min: 10, max: 16)),
                      AutoSwitchRowLabel(
                        label: l10n.autoSwitchScope,
                        help: l10n.autoSwitchScopeHelp,
                      ),
                      SizedBox(height: 6.ch(min: 4, max: 8)),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: autoSwitchScopeSameType,
                            label: Text(l10n.autoSwitchScopeSameType),
                          ),
                          ButtonSegment(
                            value: autoSwitchScopeSameProtocol,
                            label: Text(l10n.autoSwitchScopeSameProtocol),
                          ),
                          ButtonSegment(
                            value: autoSwitchScopeAny,
                            label: Text(l10n.autoSwitchScopeAny),
                          ),
                        ],
                        selected: {settings.scope},
                        onSelectionChanged: (v) =>
                            save(settings.copyWith(scope: v.first)),
                      ),
                      SizedBox(height: 14.ch(min: 10, max: 16)),
                      Divider(color: colorScheme.outlineVariant, height: 1),
                      SizedBox(height: 12.ch(min: 8, max: 14)),
                      AutoSwitchNumberRow(
                        label: l10n.autoSwitchFailureThreshold,
                        suffix: l10n.autoSwitchFailureThresholdUnit,
                        value: settings.failureThreshold,
                        min: 1,
                        max: 10,
                        help: l10n.autoSwitchFailureThresholdHelp,
                        onChanged: (v) =>
                            save(settings.copyWith(failureThreshold: v)),
                      ),
                      AutoSwitchNumberRow(
                        label: l10n.autoSwitchFastestMargin,
                        suffix: l10n.autoSwitchFastestMarginUnit,
                        value: settings.fastestMarginMs,
                        min: 50,
                        max: 2000,
                        step: 50,
                        help: l10n.autoSwitchFastestMarginHelp,
                        onChanged: (v) =>
                            save(settings.copyWith(fastestMarginMs: v)),
                      ),
                      AutoSwitchNumberRow(
                        label: l10n.autoSwitchCooldown,
                        suffix: l10n.autoSwitchCooldownUnit,
                        value: settings.cooldownSeconds,
                        min: 5,
                        max: 600,
                        step: 5,
                        help: l10n.autoSwitchCooldownHelp,
                        onChanged: (v) =>
                            save(settings.copyWith(cooldownSeconds: v)),
                      ),
                      AutoSwitchNumberRow(
                        label: l10n.autoSwitchProbeInterval,
                        suffix: l10n.autoSwitchProbeIntervalUnit,
                        value: settings.probeIntervalSeconds,
                        min: 60,
                        max: 1800,
                        step: 30,
                        help: l10n.autoSwitchProbeIntervalHelp,
                        onChanged: (v) =>
                            save(settings.copyWith(probeIntervalSeconds: v)),
                      ),
                      AutoSwitchNumberRow(
                        label: l10n.autoSwitchSlowTimeout,
                        suffix: l10n.autoSwitchSlowTimeoutUnit,
                        value: settings.slowRequestTimeoutSeconds,
                        min: 0,
                        max: 120,
                        step: 5,
                        help: l10n.autoSwitchSlowTimeoutHelp,
                        onChanged: (v) => save(
                          settings.copyWith(slowRequestTimeoutSeconds: v),
                        ),
                      ),
                      AutoSwitchNumberRow(
                        label: l10n.autoSwitchSlowThreshold,
                        suffix: l10n.autoSwitchSlowThresholdUnit,
                        value: settings.slowRequestSwitchThreshold,
                        min: 1,
                        max: 10,
                        help: l10n.autoSwitchSlowThresholdHelp,
                        onChanged: (v) => save(
                          settings.copyWith(slowRequestSwitchThreshold: v),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.ch(min: 2, max: 6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AutoSwitchRowLabel(
                                label: l10n.autoSwitchAllowSibling,
                                help: l10n.autoSwitchAllowSiblingHelp,
                              ),
                            ),
                            Switch(
                              value: settings.allowSameProviderSibling,
                              onChanged: (v) => save(
                                settings.copyWith(allowSameProviderSibling: v),
                              ),
                            ),
                          ],
                        ),
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

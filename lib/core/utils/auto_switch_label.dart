import 'package:flutter/widgets.dart';
import 'package:shim/core/constants/auto_switch_options.dart';
import 'package:shim/core/extensions/context_extensions.dart';

/// 自动切换策略字符串 → 本地化标签。未知值兜底为 manual。
String autoSwitchStrategyLabel(BuildContext context, String key) {
  final l10n = context.l10n;
  switch (key) {
    case autoSwitchStrategyFailover:
      return l10n.autoSwitchStrategyFailover;
    case autoSwitchStrategyFastest:
      return l10n.autoSwitchStrategyFastest;
    case autoSwitchStrategyManual:
    default:
      return l10n.autoSwitchStrategyManual;
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auto_switch_settings.freezed.dart';

/// 自动切换配置：策略 + 范围 + 阈值。仿 ProxyConfig 用 @Default，
/// 允许 `const AutoSwitchSettings()` 直接造一份合理默认。
///
/// strategy: manual | failover | fastest
///   manual    ── 只显示延迟，不自动切
///   failover  ── 当前供应商连续失败 N 次后切到最快的同范围供应商
///   fastest   ── 后台测速后，有比当前快 ≥ X ms 的同范围供应商就切
///
/// scope: same-type | same-protocol | any
///   same-type      ── 候选必须跟当前是同一个 modelFamily（openai/claude/gemini）
///   same-protocol  ── 候选必须跟当前 upstreamProtocol 一致
///   any            ── 不限
@freezed
abstract class AutoSwitchSettings with _$AutoSwitchSettings {
  const AutoSwitchSettings._();

  const factory AutoSwitchSettings({
    @Default('manual') String strategy,
    @Default('same-type') String scope,
    /// failover: 连续失败几次后触发切换
    @Default(3) int failureThreshold,
    /// fastest: 候选比当前快多少 ms 才切，防止抖动
    @Default(200) int fastestMarginMs,
    /// 切换后冷却秒数，防止反复横跳
    @Default(10) int cooldownSeconds,
    /// 后台测速周期秒数。默认 5 分钟,避免给上游中转造成压力。
    /// strategy=manual 时此值不生效(完全不跑后台周期)。
    @Default(300) int probeIntervalSeconds,
  }) = _AutoSwitchSettings;
}

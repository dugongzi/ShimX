import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_health.freezed.dart';

/// 单家供应商在一次测速后的健康快照。
///
/// status 是字符串而不是 enum，跟 ApiProvider.upstreamProtocol 风格保持一致：
///   unknown      ── 未测过 / 还没结果
///   healthy      ── 延迟 < slow 阈值
///   slow         ── 延迟超过 slow 阈值但能通
///   unreachable  ── 测速失败 / 连续失败超过阈值
///
/// 仅内存态，不持久化（每次启动重测）。
@freezed
abstract class ProviderHealth with _$ProviderHealth {
  const ProviderHealth._();

  const factory ProviderHealth({
    required String providerId,
    required String status,
    /// 测速延迟毫秒。null 表示没拿到有效延迟（测速失败 / 未测过）。
    required int? latencyMs,
    /// 上次测速时间（ISO 8601 UTC）。null 表示从未测过。
    required String? measuredAt,
    /// 连续失败次数，用于触发故障转移阈值判定。
    required int failureStreak,
  }) = _ProviderHealth;
}

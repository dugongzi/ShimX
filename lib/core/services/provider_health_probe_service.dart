import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/utils/model_family.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';

/// 供应商测速调度器。跟 LocalProxyService 并列的运行时 service。
///
/// 友善对待上游中转的几条节流红线：
///   - 默认不跑后台周期；strategy=manual 完全不启调度器
///   - 单家 60s 窗口内不重复测，避免反复点 picker / 反复触发 bridge
///   - 单家 inflight 去重，并发触发只跑一次
///   - probeAll 只测 onlyIds 指定的家(默认 = 当前选中),不要无脑全跑
///   - 并发上限 3,间隔 200ms,避免一次性怼上游
class ProviderHealthProbeService {
  ProviderHealthProbeService({required this.repository});

  final ProviderHealthRepository repository;

  Timer? _periodic;
  Duration _interval = const Duration(minutes: 5);
  List<ApiProvider> _targets = const [];

  /// 单家 60s 内不重测的窗口
  static const _probeCooldown = Duration(seconds: 60);

  /// 并发上限
  static const _maxConcurrent = 3;

  /// healthy/slow 切分阈值（毫秒）
  static const _slowMs = 1500;
  /// 连续失败到这个数会标记 unreachable
  static const _unreachableStreak = 2;

  /// 单家最近一次测速完成时间(用于 cooldown 判定)
  final Map<String, DateTime> _lastProbedAt = {};
  /// 单家进行中的 future,去重并发触发
  final Map<String, Future<void>> _inflight = {};

  bool get isRunning => _periodic != null;

  /// 启动周期测速。可重复调，参数变就重起。
  /// 注意:**不**会立刻全测,首次测速由调用方按需触发(picker 打开 / 失败上报)。
  void start({
    required List<ApiProvider> providers,
    required Duration interval,
  }) {
    _targets = providers;
    _interval = interval;
    _restartTimer();
  }

  /// 停止周期测速（不清健康数据，UI 仍能拿到最后一次结果）
  void stop() {
    _periodic?.cancel();
    _periodic = null;
    AppLogService.instance.info('HealthProbe', '调度器已停止');
  }

  /// 更新目标列表（供应商增删改时调）
  void updateTargets({required List<ApiProvider> providers}) {
    _targets = providers;
    // 顺手清掉已删除的供应商健康
    final ids = providers.map((p) => p.id).toSet();
    for (final id in repository.snapshot().keys.toList()) {
      if (!ids.contains(id)) {
        repository.remove(providerId: id);
      }
    }
    for (final id in _lastProbedAt.keys.toList()) {
      if (!ids.contains(id)) _lastProbedAt.remove(id);
    }
  }

  /// 测速。
  ///
  /// [onlyIds] 限定要测哪几家。null 表示当前所有目标——但通常调用方传"当前选中 +
  /// 自动切换候选"这种小范围;不要全量。
  /// [force] 为 true 时跳过 60s cooldown(用户点了"立即刷新"按钮才该用)。
  Future<void> probeAll({Set<String>? onlyIds, bool force = false}) async {
    final scope = _targets
        .where((p) => onlyIds == null || onlyIds.contains(p.id))
        .toList();
    if (scope.isEmpty) return;

    final eligible = scope
        .where((p) => force || _eligibleForProbe(p.id))
        .toList();
    if (eligible.isEmpty) {
      AppLogService.instance.info('HealthProbe', '全部在 cooldown,跳过');
      return;
    }

    AppLogService.instance.info(
      'HealthProbe',
      '开始测速',
      details: 'count=${eligible.length} total=${scope.length} force=$force',
    );

    // 并发上限 + 间隔。分批跑:每批最多 _maxConcurrent 家,批次间留 200ms。
    final queue = List<ApiProvider>.from(eligible);
    while (queue.isNotEmpty) {
      final batch = queue.take(_maxConcurrent).toList();
      queue.removeRange(0, batch.length);
      await Future.wait(batch.map((p) => probeOne(p, force: force)));
      if (queue.isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  /// 单家测速。先 HTTP /models 拿延迟（顺带能发现密钥失效等业务错），
  /// HTTP 不可用再退 TCP 握手。
  ///
  /// 60s 窗口内重复触发会复用 inflight future,不会真发请求。
  Future<void> probeOne(ApiProvider provider, {bool force = false}) async {
    if (provider.baseUrl.isEmpty) {
      _writeUnreachable(provider, reason: 'baseUrl 为空');
      return;
    }
    if (!force && !_eligibleForProbe(provider.id)) {
      return; // cooldown 内,直接跳过
    }
    final existing = _inflight[provider.id];
    if (existing != null) return existing;

    final future = _runProbe(provider);
    _inflight[provider.id] = future;
    try {
      await future;
    } finally {
      _inflight.remove(provider.id);
      _lastProbedAt[provider.id] = DateTime.now();
    }
  }

  Future<void> _runProbe(ApiProvider provider) async {
    final httpResult = await _probeHttp(provider);
    if (httpResult != null) {
      _writeResult(provider, latencyMs: httpResult);
      return;
    }
    final tcpResult = await _probeTcp(provider);
    if (tcpResult != null) {
      _writeResult(provider, latencyMs: tcpResult);
      return;
    }
    _writeUnreachable(provider, reason: 'HTTP/TCP 均失败');
  }

  bool _eligibleForProbe(String providerId) {
    final last = _lastProbedAt[providerId];
    if (last == null) return true;
    return DateTime.now().difference(last) >= _probeCooldown;
  }

  /// 请求层失败回调，由 LocalProxyService 在转发失败时调用。
  /// 不重新跑测速，只累计失败次数；超过阈值就标 unreachable。
  void reportRequestFailure({required String providerId}) {
    final prev = repository.read(providerId: providerId);
    final streak = (prev?.failureStreak ?? 0) + 1;
    final status = streak >= _unreachableStreak ? 'unreachable' : (prev?.status ?? 'unknown');
    repository.write(
      health: ProviderHealth(
        providerId: providerId,
        status: status,
        latencyMs: status == 'unreachable' ? null : prev?.latencyMs,
        measuredAt: prev?.measuredAt,
        failureStreak: streak,
      ),
    );
    AppLogService.instance.warning(
      'HealthProbe',
      '请求失败累计',
      details: 'provider=$providerId streak=$streak status=$status',
    );
  }

  /// 慢响应专用上报。累计 slowStreak,到阈值直接写 unreachable + 触发 watch。
  /// 不走常规 failureStreak 通道,响应更快。
  ///
  /// [threshold] 来自 AutoSwitchSettings.slowRequestSwitchThreshold,
  /// 1 = 1 次慢响应就直接标 unreachable。
  void reportSlowTimeout({
    required String providerId,
    required int waitedMs,
    required int threshold,
  }) {
    if (threshold <= 0) return; // 用户关了
    final prev = repository.read(providerId: providerId);
    final slowStreak = (_slowStreaks[providerId] ?? 0) + 1;
    _slowStreaks[providerId] = slowStreak;

    AppLogService.instance.warning(
      'HealthProbe',
      '慢响应累计',
      details: 'provider=$providerId waited=${waitedMs}ms slowStreak=$slowStreak threshold=$threshold',
    );

    if (slowStreak < threshold) return;

    _slowStreaks[providerId] = 0;
    repository.write(
      health: ProviderHealth(
        providerId: providerId,
        status: 'unreachable',
        latencyMs: null,
        measuredAt: DateTime.now().toUtc().toIso8601String(),
        failureStreak: (prev?.failureStreak ?? 0) + 1,
      ),
    );
    AppLogService.instance.error(
      'HealthProbe',
      '慢响应达到阈值,已标 unreachable',
      details: 'provider=$providerId waited=${waitedMs}ms',
    );
  }

  /// 慢响应累计次数表(内存)
  final Map<String, int> _slowStreaks = {};

  void reportRequestSuccess({required String providerId}) {
    _slowStreaks[providerId] = 0;
    final prev = repository.read(providerId: providerId);
    if (prev == null || prev.failureStreak == 0) return;
    repository.write(
      health: ProviderHealth(
        providerId: providerId,
        status: prev.status == 'unreachable' ? 'unknown' : prev.status,
        latencyMs: prev.latencyMs,
        measuredAt: prev.measuredAt,
        failureStreak: 0,
      ),
    );
  }

  /// 周期任务里只测哪几家。由调用方设置(通常是当前选中 + 候选)。
  /// 空集表示"当前所有目标"(等价于全扫,默认不推荐)。
  Set<String>? _periodicOnlyIds;

  void setPeriodicScope({required Set<String> onlyIds}) {
    _periodicOnlyIds = onlyIds;
  }

  /// 按当前选中 + top2 同 scope 候选刷新周期 scope。
  /// 这样 failover/fastest 策略要切的时候,候选 latency 已经被预热过了,可比可切。
  void refreshPeriodicScopeFor({
    required String currentProviderId,
    required List<ApiProvider> providers,
    required String scope,
  }) {
    final ids = <String>{currentProviderId};
    final candidates = topCandidatesForScope(
      currentProviderId: currentProviderId,
      providers: providers,
      scope: scope,
      n: 2,
    );
    for (final c in candidates) {
      ids.add(c.id);
    }
    _periodicOnlyIds = ids;
    AppLogService.instance.info(
      'HealthProbe',
      '周期 scope 已更新',
      details: 'current=$currentProviderId candidates=${candidates.map((p) => p.id).join(",")}',
    );
  }

  /// 候选筛选:同 scope 限制下,按上次 latency 升序取前 n 个。
  /// 没 latency 数据的家排在最后,字典序排序作为冷启动垫底。
  List<ApiProvider> topCandidatesForScope({
    required String currentProviderId,
    required List<ApiProvider> providers,
    required String scope,
    required int n,
  }) {
    final current = providers.where((p) => p.id == currentProviderId).cast<ApiProvider?>().firstOrNull;
    if (current == null) return const [];
    final currentFamily = modelFamily(current.selectedModel);
    final filtered = <ApiProvider>[];
    for (final p in providers) {
      if (p.id == currentProviderId) continue;
      if (p.baseUrl.isEmpty || p.apiKey.isEmpty) continue;
      switch (scope) {
        case 'same-type':
          if (modelFamily(p.selectedModel) != currentFamily) continue;
          break;
        case 'same-protocol':
          if (p.upstreamProtocol != current.upstreamProtocol) continue;
          break;
        case 'any':
        default:
          break;
      }
      filtered.add(p);
    }
    int latencyOf(ApiProvider p) {
      final h = repository.read(providerId: p.id);
      return h?.latencyMs ?? 0x7fffffff;
    }
    filtered.sort((a, b) {
      final cmp = latencyOf(a).compareTo(latencyOf(b));
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });
    return filtered.take(n).toList();
  }

  void _restartTimer() {
    _periodic?.cancel();
    _periodic = Timer.periodic(_interval, (_) {
      unawaited(probeAll(onlyIds: _periodicOnlyIds));
    });
    AppLogService.instance.info(
      'HealthProbe',
      '调度器已启动',
      details: 'interval=${_interval.inSeconds}s targets=${_targets.length}',
    );
  }

  Future<int?> _probeHttp(ApiProvider provider) async {
    final trimmed = provider.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final url = '$trimmed/models';
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          if (provider.apiKey.isNotEmpty) 'Authorization': 'Bearer ${provider.apiKey}',
        },
        responseType: ResponseType.plain,
      ),
    );
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) => 'DIRECT';
      return client;
    };
    final stopwatch = Stopwatch()..start();
    try {
      final res = await dio.getUri(Uri.parse(url));
      stopwatch.stop();
      // 2xx / 401 / 403 都算"连得通"——业务错也证明网络层 OK
      final code = res.statusCode ?? 0;
      if (code >= 200 && code < 500) {
        return stopwatch.elapsedMilliseconds;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      dio.close(force: true);
    }
  }

  Future<int?> _probeTcp(ApiProvider provider) async {
    final uri = Uri.tryParse(provider.baseUrl);
    if (uri == null || uri.host.isEmpty) return null;
    final port = uri.port == 0 ? (uri.scheme == 'https' ? 443 : 80) : uri.port;
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        uri.host,
        port,
        timeout: const Duration(seconds: 5),
      );
      stopwatch.stop();
      socket.destroy();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  void _writeResult(ApiProvider provider, {required int latencyMs}) {
    final status = latencyMs >= _slowMs ? 'slow' : 'healthy';
    repository.write(
      health: ProviderHealth(
        providerId: provider.id,
        status: status,
        latencyMs: latencyMs,
        measuredAt: DateTime.now().toUtc().toIso8601String(),
        failureStreak: 0,
      ),
    );
    AppLogService.instance.info(
      'HealthProbe',
      '测速完成',
      details: 'provider=${provider.id} latency=${latencyMs}ms status=$status',
    );
  }

  void _writeUnreachable(ApiProvider provider, {required String reason}) {
    final prev = repository.read(providerId: provider.id);
    repository.write(
      health: ProviderHealth(
        providerId: provider.id,
        status: 'unreachable',
        latencyMs: null,
        measuredAt: DateTime.now().toUtc().toIso8601String(),
        failureStreak: (prev?.failureStreak ?? 0) + 1,
      ),
    );
    AppLogService.instance.warning(
      'HealthProbe',
      '测速失败',
      details: 'provider=${provider.id} reason=$reason',
    );
  }
}

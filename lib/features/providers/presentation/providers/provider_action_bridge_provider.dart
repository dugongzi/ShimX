import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/constants/reasoning_effort.dart';
import 'package:shim/core/constants/shim_bridge_labels.dart';
import 'package:shim/core/constants/storage_keys.dart';
import 'package:shim/core/providers/locale_provider.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/takeover_service.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';
import 'package:shim/features/providers/domain/models/provider_health.dart';
import 'package:shim/features/providers/domain/repositories/provider_health_repository.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';

part 'provider_action_bridge_provider.g.dart';

/// 注册 JS 侧供应商/模型选择路由。
///
/// /provider/list                  列出全部供应商 + 当前选中 + reasoningEffort + i18n labels
/// /provider/select                选择供应商
/// /provider/select-model          切换某供应商的模型
/// /provider/set-reasoning-effort  写思考深度
@Riverpod(keepAlive: true)
bool providerActionRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final actionRepo = ref.read(providerActionRepositoryProvider);
  final queryRepo = ref.read(providerQueryRepositoryProvider);
  final appStorage = ref.read(appStorageProvider);
  final healthRepo = ref.read(providerHealthRepositoryProvider);

  bool isZh() => ref.read(localeProvider).languageCode == 'zh';

  bridge.register('/provider/list', (payload) async {
    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(reasoningEffortKey);
    return _providerListPayload(
      providers,
      selectedId,
      reasoningEffort,
      healthRepo,
      isZh(),
    );
  });

  bridge.register('/provider/select', (payload) async {
    final id = payload['id'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError('provider id is required');
    }
    final prevSelected = await queryRepo.selectedId();
    await actionRepo.saveSelectedId(id);
    if (prevSelected == id) {
      AppLogService.instance.debug(
        'Provider',
        '选中供应商(无变化)',
        details: 'id=$id 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    } else {
      AppLogService.instance.info(
        'Provider',
        '选中供应商',
        details:
            'id=$id prev=$prevSelected 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    }
    ref.invalidate(providerListProvider);
    await syncRunningProxyTarget(ref);

    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(reasoningEffortKey);
    return _providerListPayload(
      providers,
      selectedId,
      reasoningEffort,
      healthRepo,
      isZh(),
    );
  });

  bridge.register('/provider/select-model', (payload) async {
    final id = payload['id'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError('provider id is required');
    }
    final rawModel = payload['model'];
    final model = rawModel is String && rawModel.isNotEmpty ? rawModel : null;
    final providers = await queryRepo.listProviders();
    var found = false;
    String? prevModel;
    final next = providers.map<ApiProvider>((provider) {
      if (provider.id != id) return provider;
      found = true;
      prevModel = provider.selectedModel;
      return provider.copyWith(selectedModel: model);
    }).toList();
    if (!found) throw ArgumentError('provider not found: $id');

    final prevSelected = await queryRepo.selectedId();
    await actionRepo.saveProviders(next);
    if (prevModel == model) {
      AppLogService.instance.debug(
        'Provider',
        '切换模型(无变化)',
        details:
            'id=$id model=${model ?? "(null)"} 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    } else {
      AppLogService.instance.info(
        'Provider',
        '切换模型',
        details:
            'id=$id ${prevModel ?? "(null)"} -> ${model ?? "(null)"} 调用方=${payload['__caller'] ?? '(unknown)'}',
      );
    }
    await actionRepo.saveSelectedId(id);
    if (prevSelected != id) {
      AppLogService.instance.info(
        'Provider',
        '选中供应商',
        details: 'id=$id prev=$prevSelected (via select-model)',
      );
    }
    ref.invalidate(providerListProvider);
    await syncRunningProxyTarget(ref);

    final selectedId = await queryRepo.selectedId();
    final reasoningEffort = await appStorage.getString(reasoningEffortKey);
    return _providerListPayload(
      next,
      selectedId,
      reasoningEffort,
      healthRepo,
      isZh(),
    );
  });

  bridge.register('/provider/set-reasoning-effort', (payload) async {
    final rawEffort = payload['effort'];
    final effort = rawEffort is String ? rawEffort : '';
    if (!isSupportedReasoningEffort(effort)) {
      throw ArgumentError('unsupported reasoning effort: $effort');
    }
    await appStorage.setString(reasoningEffortKey, effort);
    AppLogService.instance.info('Provider', '切换思考深度', details: effort);
    await syncRunningProxyTarget(ref);

    final providers = await queryRepo.listProviders();
    final selectedId = await queryRepo.selectedId();
    return _providerListPayload(
      providers,
      selectedId,
      effort,
      healthRepo,
      isZh(),
    );
  });

  return true;
}

Map<String, dynamic> _providerListPayload(
  List<ApiProvider> providers,
  String? selectedId,
  String? reasoningEffort,
  ProviderHealthRepository healthRepo,
  bool isZh,
) {
  return {
    'selectedId': selectedId,
    'reasoningEffort': isSupportedReasoningEffort(reasoningEffort)
        ? reasoningEffort
        : defaultReasoningEffort,
    'providers': providers
        .map(
          (provider) => {
            'id': provider.id,
            'name': provider.name,
            'models': provider.models,
            'selectedModel': provider.selectedModel,
            'protocol': provider.upstreamProtocol,
            'providerWeight': provider.providerWeight,
            'modelWeight': provider.modelWeight,
            'health': _healthJson(healthRepo.read(providerId: provider.id)),
          },
        )
        .toList(),
    'labels': shimBridgeLabels(isZh: isZh),
  };
}

Map<String, dynamic>? _healthJson(ProviderHealth? h) {
  if (h == null) return null;
  return {
    'status': h.status,
    'latencyMs': h.latencyMs,
    'measuredAt': h.measuredAt,
    'failureStreak': h.failureStreak,
  };
}

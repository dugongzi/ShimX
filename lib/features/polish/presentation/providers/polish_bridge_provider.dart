import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/polish/presentation/providers/polish_action_provider.dart';

part 'polish_bridge_provider.g.dart';

/// 注册文本润色的 bridge 路由。
///
/// `/polish/text` payload: `{ text: string, instruction: string }`
///                   → `{ polished: string }`
///
/// instruction 是「更简洁」/「更正式」/「更口语」/「更详细」之类的短语,
/// JS 侧不做校验, dart 也不做校验(纯 pass-through 到 datasource)。
@Riverpod(keepAlive: true)
bool polishBridgeRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  // handler 长期存活,不提前抓 repo(action provider 是 autoDispose)。
  // 每次触发时通过 ref 拿新的 repo 实例。
  bridge.register('/polish/text', (payload) async {
    final text = payload['text'];
    final instruction = payload['instruction'];
    if (text is! String || text.trim().isEmpty) {
      throw StateError('text is required and non-empty');
    }
    if (instruction is! String || instruction.trim().isEmpty) {
      throw StateError('instruction is required and non-empty');
    }
    final repo = ref.read(polishActionRepositoryProvider);
    final polished = await repo.polish(
      text: text,
      instruction: instruction,
    );
    return {'polished': polished};
  });

  AppLogService.instance.info('Polish', '路由已注册');
  return true;
}

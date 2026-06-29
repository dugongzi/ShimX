import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/mcp/data/datasources/claude_bridge_binding_datasource.dart';
import 'package:shim/features/mcp/data/models/claude_bridge_binding_dto.dart';

/// 内存中维护当前 Claude 桥绑定状态,与 [LocalProxyService] 同步并按需持久化。
///
/// 由两个 repository(query / action)共享同一实例:
///   - query impl 读 statePayload / bindingsPayload / 触发 hydrate
///   - action impl 写 bind/unbind 后调 [persist]
///
/// 单例化交给 provider 层(`@Riverpod(keepAlive: true)`)保证两个 repo 拿到同一份。
class ClaudeBridgeStateController {
  ClaudeBridgeStateController({
    required LocalProxyService proxy,
    required ClaudeBridgeBindingDatasource datasource,
  }) : _proxy = proxy,
       _datasource = datasource;

  final LocalProxyService _proxy;
  final ClaudeBridgeBindingDatasource _datasource;

  Future<void>? _hydrating;
  bool _hydrated = false;

  Future<void> ensureHydrated() {
    if (_hydrated) return Future.value();
    final running = _hydrating;
    if (running != null) return running;
    final future = _hydrate();
    _hydrating = future;
    return future;
  }

  Future<void> _hydrate() async {
    try {
      final saved = await _datasource.read();
      _proxy.replaceClaudeBindings(
        saved.map((key, value) => MapEntry(key, value.toBinding())),
      );
      _hydrated = true;
    } finally {
      _hydrating = null;
    }
  }

  /// 把 LocalProxy 内存里的绑定写回 storage。
  Future<void> persist() async {
    await ensureHydrated();
    final snapshot = _proxy.claudeBindingsSnapshot.map(
      (key, value) => MapEntry(
        key,
        ClaudeBridgeBindingDto.fromBinding(codexThreadId: key, binding: value),
      ),
    );
    await _datasource.write(snapshot);
  }

  Map<String, dynamic> statePayload(String codexThreadId) {
    if (codexThreadId.isEmpty) return const {'bound': false};
    final binding = _proxy.claudeBindingFor(codexThreadId);
    if (binding == null) {
      return {'bound': false, 'codexThreadId': codexThreadId};
    }
    return {
      'bound': true,
      'codexThreadId': codexThreadId,
      'sessionId': binding.sessionId,
      'jsonlPath': binding.jsonlPath,
      'title': binding.title,
    };
  }

  Map<String, dynamic> bindingsPayload() {
    final items = _proxy.claudeBindingsSnapshot.entries
        .map(
          (entry) => {
            'codexThreadId': entry.key,
            'sessionId': entry.value.sessionId,
            'jsonlPath': entry.value.jsonlPath,
            'title': entry.value.title,
          },
        )
        .toList();
    return {'bindings': items};
  }

  void setBinding({
    required String codexThreadId,
    required String sessionId,
    required String jsonlPath,
    String? title,
  }) {
    _proxy.setClaudeBinding(
      codexThreadId: codexThreadId,
      binding: ClaudeBridgeBinding(
        sessionId: sessionId,
        jsonlPath: jsonlPath,
        title: title,
      ),
    );
  }

  void clearBinding({required String codexThreadId}) {
    _proxy.clearClaudeBinding(codexThreadId: codexThreadId);
  }
}

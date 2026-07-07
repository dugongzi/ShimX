import 'dart:async';

import 'package:shimx/features/providers/domain/models/provider_health.dart';

/// 内存态健康数据源。生命周期内活着，每次 write 推一份快照给订阅者。
///
/// 不写盘——health 是观察结果，重启重测；持久化只对 AutoSwitchSettings 做。
class ProviderHealthDatasource {
  final Map<String, ProviderHealth> _store = {};
  final StreamController<Map<String, ProviderHealth>> _controller =
      StreamController.broadcast();

  Map<String, ProviderHealth> snapshot() => Map.unmodifiable(_store);

  ProviderHealth? read(String providerId) => _store[providerId];

  void write(ProviderHealth health) {
    _store[health.providerId] = health;
    _emit();
  }

  void remove(String providerId) {
    if (_store.remove(providerId) != null) {
      _emit();
    }
  }

  Stream<Map<String, ProviderHealth>> watch() => _controller.stream;

  void dispose() {
    _controller.close();
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(Map.unmodifiable(_store));
  }
}

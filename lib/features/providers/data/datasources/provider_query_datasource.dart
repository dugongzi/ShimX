import 'dart:convert';

import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/providers/data/models/api_provider_dto.dart';

class ProviderQueryDatasource {
  ProviderQueryDatasource({required this.appStorage});

  final AppStorage appStorage;

  static const _listKey = 'api_provider_list';
  static const _selectedKey = 'api_provider_selected';
  static const _proxyEnabledKey = 'codex_proxy_enabled';
  static const _proxyPortKey = 'codex_proxy_port';

  Future<List<ApiProviderDto>> listProviders() async {
    final raw = await appStorage.getString(_listKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ApiProviderDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String?> selectedId() {
    return appStorage.getString(_selectedKey);
  }

  Future<bool?> proxyEnabled() {
    return appStorage.getBool(_proxyEnabledKey);
  }

  Future<int?> proxyPort() {
    return appStorage.getInt(_proxyPortKey);
  }
}

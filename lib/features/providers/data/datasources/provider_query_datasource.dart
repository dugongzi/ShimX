import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<Map>().map((item) {
      return ApiProviderDto.fromJson(
        item.map((key, value) => MapEntry(key.toString(), value)),
      );
    }).toList();
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

  /// 调供应商的 OpenAI 兼容 GET {baseUrl}/models 拉取可用模型 id 列表。
  Future<List<String>> fetchModels({
    required String baseUrl,
    required String apiKey,
  }) async {
    final trimmed = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Authorization': 'Bearer $apiKey'},
        responseType: ResponseType.plain,
      ),
    );
    // 禁用系统代理直连，避免 VPN 把请求劫持到返回 HTML 的页面
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) => 'DIRECT';
      return client;
    };
    final url = '$trimmed/models';
    // ignore: avoid_print
    print('[FetchModels] GET $url');
    final response = await dio.getUri<String>(Uri.parse(url));
    final body = response.data;
    // ignore: avoid_print
    print('[FetchModels] status=${response.statusCode} '
        'len=${body?.length} head=${body?.substring(0, body.length.clamp(0, 120))}');
    if (body == null || body.isEmpty) return const [];
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];
    final data = decoded['data'];
    if (data is! List) return const [];
    final ids = <String>[];
    for (final item in data) {
      if (item is Map && item['id'] is String) {
        ids.add(item['id'] as String);
      }
    }
    return ids;
  }
}


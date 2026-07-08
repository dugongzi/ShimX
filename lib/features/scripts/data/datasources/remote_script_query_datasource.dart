import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shimx/core/constants/app_links.dart';
import 'package:shimx/core/networks/http_service.dart';
import 'package:shimx/features/scripts/data/models/remote_script_catalog_dto.dart';

class RemoteScriptQueryDatasource {
  const RemoteScriptQueryDatasource({required HttpService httpService})
      : _httpService = httpService;

  final HttpService _httpService;

  Future<RemoteScriptCatalogDto> fetchCatalog() async {
    final response = await _httpService.get<dynamic>(
      shimxRemoteScriptIndexUrl,
      options: Options(responseType: ResponseType.json),
    );
    final raw = response.data;
    final data = raw is String ? jsonDecode(raw) : raw;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid remote script catalog.');
    }
    return RemoteScriptCatalogDto.fromJson(data);
  }
}

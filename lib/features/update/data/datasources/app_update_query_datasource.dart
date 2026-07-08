import 'package:dio/dio.dart';
import 'package:shimx/core/constants/app_links.dart';
import 'package:shimx/core/networks/http_service.dart';
import 'package:shimx/features/update/data/models/app_update_check_dto.dart';
import 'package:shimx/features/update/data/models/app_update_release_dto.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';

class AppUpdateQueryDatasource {
  const AppUpdateQueryDatasource({required HttpService httpService})
      : _httpService = httpService;

  final HttpService _httpService;

  Future<AppUpdateCheckDto> checkForUpdate({
    required AppUpdateSystem system,
    required String currentVersion,
  }) async {
    final response = await _httpService.get<dynamic>(
      '$shimxUpdateApiBaseUrl/api/update/check',
      queryParameters: {
        'system': system.code,
        'currentVersion': currentVersion,
      },
    );
    final data = _readResponseMap(response);
    return AppUpdateCheckDto.fromJson(data);
  }

  Future<List<AppUpdateReleaseDto>> fetchLogs({
    AppUpdateSystem? system,
    int limit = 50,
  }) async {
    final response = await _httpService.get<dynamic>(
      '$shimxUpdateApiBaseUrl/api/update/logs',
      queryParameters: {
        if (system != null) 'system': system.code,
        'limit': limit,
      },
    );
    final data = _readResponseMap(response);
    final rawItems = data['items'];
    if (rawItems is! List) return const [];
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(AppUpdateReleaseDto.fromJson)
        .toList(growable: false);
  }
}

Map<String, dynamic> _readResponseMap(Response<dynamic> response) {
  final data = response.data;
  final statusCode = response.statusCode ?? 0;
  if (data is! Map<String, dynamic>) {
    throw StateError('Invalid update API response.');
  }
  if (statusCode >= 400) {
    throw StateError(
      data['error']?.toString() ??
          data['message']?.toString() ??
          'Update API request failed.',
    );
  }
  return data;
}

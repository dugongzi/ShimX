import 'package:shimx/features/update/data/datasources/app_update_query_datasource.dart';
import 'package:shimx/features/update/domain/models/app_update_check.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';
import 'package:shimx/features/update/domain/repositories/app_update_query_repository.dart';

class AppUpdateQueryRepositoryImpl implements AppUpdateQueryRepository {
  const AppUpdateQueryRepositoryImpl({required AppUpdateQueryDatasource dataSource})
      : _dataSource = dataSource;

  final AppUpdateQueryDatasource _dataSource;

  @override
  Future<AppUpdateCheck> checkForUpdate({
    required AppUpdateSystem system,
    required String currentVersion,
  }) async {
    final dto = await _dataSource.checkForUpdate(
      system: system,
      currentVersion: currentVersion,
    );
    return dto.toEntity(system);
  }

  @override
  Future<List<AppUpdateRelease>> fetchLogs({
    AppUpdateSystem? system,
    int limit = 50,
  }) async {
    final dtos = await _dataSource.fetchLogs(system: system, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }
}

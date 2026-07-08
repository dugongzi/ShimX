import 'package:shimx/features/update/data/datasources/app_update_action_datasource.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/domain/repositories/app_update_action_repository.dart';

class AppUpdateActionRepositoryImpl implements AppUpdateActionRepository {
  const AppUpdateActionRepositoryImpl({required AppUpdateActionDatasource dataSource})
      : _dataSource = dataSource;

  final AppUpdateActionDatasource _dataSource;

  @override
  Future<void> openDownload(AppUpdateRelease release) {
    return _dataSource.openDownload(release);
  }
}

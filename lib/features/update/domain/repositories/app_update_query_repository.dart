import 'package:shimx/features/update/domain/models/app_update_check.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';

abstract class AppUpdateQueryRepository {
  Future<AppUpdateCheck> checkForUpdate({
    required AppUpdateSystem system,
    required String currentVersion,
  });

  Future<List<AppUpdateRelease>> fetchLogs({
    AppUpdateSystem? system,
    int limit = 50,
  });
}

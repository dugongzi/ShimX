import 'package:shimx/features/update/domain/models/app_update_release.dart';

abstract class AppUpdateActionRepository {
  Future<void> openDownload(AppUpdateRelease release);
}

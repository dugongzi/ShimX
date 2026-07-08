import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/networks/http_service.dart';
import 'package:shimx/features/update/data/datasources/app_update_action_datasource.dart';
import 'package:shimx/features/update/data/datasources/app_update_platform_datasource.dart';
import 'package:shimx/features/update/data/datasources/app_update_query_datasource.dart';
import 'package:shimx/features/update/data/repositories/app_update_action_repository_impl.dart';
import 'package:shimx/features/update/data/repositories/app_update_query_repository_impl.dart';
import 'package:shimx/features/update/domain/models/app_update_check.dart';
import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:shimx/features/update/domain/models/app_update_system.dart';
import 'package:shimx/features/update/domain/repositories/app_update_action_repository.dart';
import 'package:shimx/features/update/domain/repositories/app_update_query_repository.dart';

part 'app_update_provider.g.dart';

@riverpod
AppUpdateQueryRepository appUpdateQueryRepository(Ref ref) {
  return AppUpdateQueryRepositoryImpl(
    dataSource: AppUpdateQueryDatasource(
      httpService: ref.watch(httpServiceProvider),
    ),
  );
}

@riverpod
AppUpdateActionRepository appUpdateActionRepository(Ref ref) {
  return AppUpdateActionRepositoryImpl(
    dataSource: AppUpdateActionDatasource(),
  );
}

@riverpod
AppUpdateSystem? currentAppUpdateSystem(Ref ref) {
  return AppUpdatePlatformDatasource().currentSystem();
}

@riverpod
Future<AppUpdateCheck?> appUpdateCheck(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  final system = ref.watch(currentAppUpdateSystemProvider);
  if (system == null) {
    return null;
  }
  return ref.read(appUpdateQueryRepositoryProvider).checkForUpdate(
        system: system,
        currentVersion: info.version,
      );
}

@riverpod
Future<List<AppUpdateRelease>> appUpdateLogs(
  Ref ref, {
  bool currentSystemOnly = true,
}) {
  final system = currentSystemOnly
      ? ref.watch(currentAppUpdateSystemProvider)
      : null;
  if (currentSystemOnly && system == null) {
    return Future.value(const []);
  }
  return ref
      .read(appUpdateQueryRepositoryProvider)
      .fetchLogs(system: system, limit: 50);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/features/settings/data/datasources/config_action_datasource.dart';
import 'package:shimx/features/settings/data/repositories/config_action_repository_impl.dart';
import 'package:shimx/features/settings/domain/repositories/config_action_repository.dart';

part 'config_action_provider.g.dart';

@riverpod
ConfigActionRepository configActionRepository(Ref ref) {
  final appStorage = ref.watch(appStorageProvider);
  final dataSource = ConfigActionDatasource(appStorage: appStorage);
  return ConfigActionRepositoryImpl(dataSource: dataSource);
}

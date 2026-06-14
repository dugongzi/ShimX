import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/settings/data/datasources/config_query_datasource.dart';
import 'package:shim/features/settings/data/repositories/config_query_repository_impl.dart';
import 'package:shim/features/settings/domain/repositories/config_query_repository.dart';

part 'config_query_provider.g.dart';

@riverpod
ConfigQueryRepository configQueryRepository(Ref ref) {
  final appStorage = ref.watch(appStorageProvider);
  final dataSource = ConfigQueryDatasource(appStorage: appStorage);
  return ConfigQueryRepositoryImpl(dataSource: dataSource);
}

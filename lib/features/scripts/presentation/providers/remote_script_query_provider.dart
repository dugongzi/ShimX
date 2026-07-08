import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/networks/http_service.dart';
import 'package:shimx/features/scripts/data/datasources/remote_script_query_datasource.dart';
import 'package:shimx/features/scripts/data/repositories/remote_script_query_repository_impl.dart';
import 'package:shimx/features/scripts/domain/models/remote_script_catalog.dart';
import 'package:shimx/features/scripts/domain/repositories/remote_script_query_repository.dart';

part 'remote_script_query_provider.g.dart';

@riverpod
RemoteScriptQueryRepository remoteScriptQueryRepository(Ref ref) {
  return RemoteScriptQueryRepositoryImpl(
    dataSource: RemoteScriptQueryDatasource(
      httpService: ref.watch(httpServiceProvider),
    ),
  );
}

@riverpod
Future<RemoteScriptCatalog> remoteScriptCatalog(Ref ref) {
  return ref.read(remoteScriptQueryRepositoryProvider).fetchCatalog();
}

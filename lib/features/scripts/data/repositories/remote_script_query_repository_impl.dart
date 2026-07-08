import 'package:shimx/features/scripts/data/datasources/remote_script_query_datasource.dart';
import 'package:shimx/features/scripts/domain/models/remote_script_catalog.dart';
import 'package:shimx/features/scripts/domain/repositories/remote_script_query_repository.dart';

class RemoteScriptQueryRepositoryImpl implements RemoteScriptQueryRepository {
  const RemoteScriptQueryRepositoryImpl({required RemoteScriptQueryDatasource dataSource})
      : _dataSource = dataSource;

  final RemoteScriptQueryDatasource _dataSource;

  @override
  Future<RemoteScriptCatalog> fetchCatalog() async {
    final dto = await _dataSource.fetchCatalog();
    return dto.toEntity();
  }
}

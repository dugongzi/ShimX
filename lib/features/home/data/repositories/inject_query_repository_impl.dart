import 'package:shimx/features/home/data/datasources/inject_query_datasource.dart';
import 'package:shimx/features/home/domain/repositories/inject_query_repository.dart';

class InjectQueryRepositoryImpl implements InjectQueryRepository {
  final InjectQueryDatasource _dataSource;

  InjectQueryRepositoryImpl({required InjectQueryDatasource dataSource})
      : _dataSource = dataSource;

  @override
  Future<bool> isDebugPortAlive({required int debugPort}) {
    return _dataSource.isDebugPortAlive(debugPort);
  }

  @override
  Future<String?> findDevtoolsUrl({required int debugPort}) {
    return _dataSource.findDevtoolsUrl(debugPort);
  }

  @override
  Future<void> waitForDebugPort({required int debugPort}) {
    return _dataSource.waitForDebugPort(debugPort: debugPort);
  }

  @override
  Future<String> loadInjectScript() {
    return _dataSource.loadInjectScript();
  }
}

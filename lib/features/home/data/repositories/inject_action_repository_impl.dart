import 'package:shim/features/home/data/datasources/inject_action_datasource.dart';
import 'package:shim/features/home/domain/repositories/inject_action_repository.dart';

class InjectActionRepositoryImpl implements InjectActionRepository {
  final InjectActionDatasource _dataSource;

  InjectActionRepositoryImpl({required InjectActionDatasource dataSource})
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

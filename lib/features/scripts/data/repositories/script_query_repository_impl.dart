import 'package:shimx/features/scripts/data/datasources/script_query_datasource.dart';
import 'package:shimx/features/scripts/domain/models/inject_script.dart';
import 'package:shimx/features/scripts/domain/repositories/script_query_repository.dart';

class ScriptQueryRepositoryImpl implements ScriptQueryRepository {
  final ScriptQueryDatasource _dataSource;

  ScriptQueryRepositoryImpl({required ScriptQueryDatasource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<InjectScript>> listScripts() {
    return _dataSource.listScripts();
  }

  @override
  Future<bool> isScriptEnabled({required String id}) {
    return _dataSource.isScriptEnabled(id: id);
  }

  @override
  Future<bool> isReloadOnRun() => _dataSource.isReloadOnRun();

  @override
  Future<bool> isHotRun() => _dataSource.isHotRun();
}

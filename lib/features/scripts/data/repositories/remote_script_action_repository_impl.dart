import 'package:shimx/features/scripts/data/datasources/remote_script_action_datasource.dart';
import 'package:shimx/features/scripts/domain/models/remote_script.dart';
import 'package:shimx/features/scripts/domain/repositories/remote_script_action_repository.dart';

class RemoteScriptActionRepositoryImpl implements RemoteScriptActionRepository {
  const RemoteScriptActionRepositoryImpl({required RemoteScriptActionDatasource dataSource})
      : _dataSource = dataSource;

  final RemoteScriptActionDatasource _dataSource;

  @override
  Future<String> install(RemoteScript script) {
    return _dataSource.install(script);
  }
}

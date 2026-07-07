import 'package:shimx/features/scripts/data/datasources/script_action_datasource.dart';
import 'package:shimx/features/scripts/domain/repositories/script_action_repository.dart';

class ScriptActionRepositoryImpl implements ScriptActionRepository {
  ScriptActionRepositoryImpl({required ScriptActionDatasource dataSource})
      : _dataSource = dataSource;

  final ScriptActionDatasource _dataSource;

  @override
  Future<String?> importScript() => _dataSource.importScript();

  @override
  Future<void> deleteScript({required String id}) =>
      _dataSource.deleteScript(id: id);

  @override
  Future<void> setEnabled({
    required Iterable<String> ids,
    required bool enabled,
  }) =>
      _dataSource.setEnabled(ids: ids, enabled: enabled);

  @override
  Future<bool> saveScript({required String id, required String code}) =>
      _dataSource.saveScript(id: id, code: code);

  @override
  Future<String> createScript({required String name, required String code}) =>
      _dataSource.createScript(name: name, code: code);

  @override
  Future<void> setReloadOnRun({required bool value}) =>
      _dataSource.setReloadOnRun(value: value);

  @override
  Future<void> setHotRun({required bool value}) =>
      _dataSource.setHotRun(value: value);
}

import 'package:shim/features/codex_session/data/datasources/codex_session_action_datasource.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_action_repository.dart';

class CodexSessionActionRepositoryImpl implements CodexSessionActionRepository {
  final CodexSessionActionDatasource dataSource;

  CodexSessionActionRepositoryImpl({required this.dataSource});

  @override
  Future<String> deleteThread({required String id}) {
    return dataSource.deleteThread(id: id);
  }
}

import 'package:shim/features/codex_session/data/datasources/codex_session_query_datasource.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_query_repository.dart';

class CodexSessionQueryRepositoryImpl implements CodexSessionQueryRepository {
  final CodexSessionQueryDatasource dataSource;

  CodexSessionQueryRepositoryImpl({required this.dataSource});

  @override
  Future<List<CodexThread>> listThreads({int limit = 100}) async {
    final dtos = await dataSource.listThreads(limit: limit);
    return dtos.map((d) => d.toEntity()).toList();
  }
}

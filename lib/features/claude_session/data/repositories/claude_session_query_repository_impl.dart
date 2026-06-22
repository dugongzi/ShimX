import 'package:shim/features/claude_session/data/datasources/claude_session_query_datasource.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/domain/repositories/claude_session_query_repository.dart';

class ClaudeSessionQueryRepositoryImpl implements ClaudeSessionQueryRepository {
  final ClaudeSessionQueryDatasource dataSource;

  ClaudeSessionQueryRepositoryImpl({required this.dataSource});

  @override
  Future<List<ClaudeProject>> listProjects() async {
    final dtos = await dataSource.listProjects();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<ClaudeThread>> listThreads({
    required String encodedDir,
    int limit = 200,
  }) async {
    final dtos =
        await dataSource.listThreads(encodedDir: encodedDir, limit: limit);
    return dtos.map((d) => d.toEntity()).toList();
  }
}

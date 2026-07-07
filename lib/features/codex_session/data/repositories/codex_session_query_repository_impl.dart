import 'package:shimx/features/codex_session/data/datasources/codex_session_query_datasource.dart';
import 'package:shimx/features/codex_session/domain/models/codex_bucket.dart';
import 'package:shimx/features/codex_session/domain/models/codex_project.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shimx/features/codex_session/domain/repositories/codex_session_query_repository.dart';

class CodexSessionQueryRepositoryImpl implements CodexSessionQueryRepository {
  final CodexSessionQueryDatasource dataSource;

  CodexSessionQueryRepositoryImpl({required this.dataSource});

  @override
  Future<List<CodexThread>> listThreads({int limit = 100}) async {
    final dtos = await dataSource.listThreads(limit: limit);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<CodexProject>> listProjects() async {
    final dtos = await dataSource.listProjects();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> listThreadsByCwd({required String cwd}) {
    return dataSource.listThreadsByCwd(cwd: cwd);
  }

  @override
  Future<CodexThreadDetail> loadThreadDetail({required String id}) async {
    final dto = await dataSource.loadDetail(id: id);
    return dto.toEntity();
  }

  @override
  Future<List<CodexBucket>> listBuckets() async {
    final dtos = await dataSource.listBuckets();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<CodexThread>> listThreadsByBucket({
    required String bucket,
    int limit = 30,
    int offset = 0,
  }) async {
    final dtos = await dataSource.listThreadsByBucket(
      bucket: bucket,
      limit: limit,
      offset: offset,
    );
    return dtos.map((d) => d.toEntity()).toList();
  }
}

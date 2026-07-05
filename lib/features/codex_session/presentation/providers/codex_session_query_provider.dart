import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/features/codex_session/data/datasources/codex_session_query_datasource.dart';
import 'package:shim/features/codex_session/data/repositories/codex_session_query_repository_impl.dart';
import 'package:shim/features/codex_session/domain/models/codex_bucket.dart';
import 'package:shim/features/codex_session/domain/models/codex_project.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';
import 'package:shim/features/codex_session/domain/repositories/codex_session_query_repository.dart';

part 'codex_session_query_provider.g.dart';

@riverpod
CodexSessionQueryRepository codexSessionQueryRepository(Ref ref) {
  return CodexSessionQueryRepositoryImpl(
    dataSource: CodexSessionQueryDatasource(),
  );
}

@riverpod
Future<List<CodexThread>> listCodexThreads(Ref ref, {int limit = 100}) async {
  return ref
      .read(codexSessionQueryRepositoryProvider)
      .listThreads(limit: limit);
}

/// 按 cwd 分组的项目左栏列表。
@riverpod
Future<List<CodexProject>> listCodexProjects(Ref ref) async {
  return ref.read(codexSessionQueryRepositoryProvider).listProjects();
}

/// 完整加载 thread:sqlite 元数据 + rollout JSONL。详情视图与导出共用。
@riverpod
Future<CodexThreadDetail> codexThreadDetail(
  Ref ref, {
  required String id,
}) {
  return ref.read(codexSessionQueryRepositoryProvider).loadThreadDetail(id: id);
}

/// 首页顶部按桶分组的桶列表。
@riverpod
Future<List<CodexBucket>> codexBuckets(Ref ref) async {
  return ref.read(codexSessionQueryRepositoryProvider).listBuckets();
}

/// 首页单桶的会话列表(family: bucket key + 分页)。
@riverpod
Future<List<CodexThread>> codexBucketThreads(
  Ref ref, {
  required String bucket,
  int limit = 30,
  int offset = 0,
}) {
  return ref
      .read(codexSessionQueryRepositoryProvider)
      .listThreadsByBucket(bucket: bucket, limit: limit, offset: offset);
}

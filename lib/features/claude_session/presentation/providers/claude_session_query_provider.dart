import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/features/claude_session/data/datasources/claude_session_query_datasource.dart';
import 'package:shim/features/claude_session/data/repositories/claude_session_query_repository_impl.dart';
import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';
import 'package:shim/features/claude_session/domain/repositories/claude_session_query_repository.dart';

part 'claude_session_query_provider.g.dart';

@riverpod
ClaudeSessionQueryRepository claudeSessionQueryRepository(Ref ref) {
  return ClaudeSessionQueryRepositoryImpl(
    dataSource: ClaudeSessionQueryDatasource(),
  );
}

@riverpod
Future<List<ClaudeProject>> listClaudeProjects(Ref ref) async {
  return ref.read(claudeSessionQueryRepositoryProvider).listProjects();
}

@riverpod
Future<List<ClaudeThread>> listClaudeThreads(
  Ref ref, {
  required String encodedDir,
  int limit = 200,
}) async {
  return ref
      .read(claudeSessionQueryRepositoryProvider)
      .listThreads(encodedDir: encodedDir, limit: limit);
}

import 'package:shimx/features/claude_session/data/datasources/claude_session_action_datasource.dart';
import 'package:shimx/features/claude_session/domain/models/claude_thread_detail.dart';
import 'package:shimx/features/claude_session/domain/repositories/claude_session_action_repository.dart';

class ClaudeSessionActionRepositoryImpl
    implements ClaudeSessionActionRepository {
  final ClaudeSessionActionDatasource dataSource;

  ClaudeSessionActionRepositoryImpl({required this.dataSource});

  @override
  Future<void> exportToFile({
    required ClaudeThreadDetail detail,
    required String format,
    required String outputPath,
  }) {
    return dataSource.exportToFile(
      detail: detail,
      format: format,
      outputPath: outputPath,
    );
  }
}

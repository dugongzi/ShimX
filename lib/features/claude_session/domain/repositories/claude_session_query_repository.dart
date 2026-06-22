import 'package:shim/features/claude_session/domain/models/claude_project.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread.dart';

abstract class ClaudeSessionQueryRepository {
  /// 列出 ~/.claude/projects/ 下所有项目目录,按 lastActiveMs 倒序。
  /// 目录不存在返回空列表(不抛)。
  Future<List<ClaudeProject>> listProjects();

  /// 列出指定项目下的所有会话,按 updatedAtMs 倒序。
  /// 每个会话只解析头部(取 title/preview/cwd/gitBranch),不加载消息。
  Future<List<ClaudeThread>> listThreads({
    required String encodedDir,
    int limit = 200,
  });
}

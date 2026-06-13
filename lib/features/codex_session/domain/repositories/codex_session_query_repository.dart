import 'package:shim/features/codex_session/domain/models/codex_thread.dart';

abstract class CodexSessionQueryRepository {
  /// 列出未归档会话
  Future<List<CodexThread>> listThreads({int limit = 100});
}

import 'package:shim/features/codex_session/domain/models/codex_bucket.dart';
import 'package:shim/features/codex_session/domain/models/codex_project.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';

abstract class CodexSessionQueryRepository {
  /// 列出未归档会话。
  Future<List<CodexThread>> listThreads({int limit = 100});

  /// 按 cwd 分组的项目左栏列表。
  Future<List<CodexProject>> listProjects();

  /// 列指定 cwd 下所有 thread 元数据(id + title + updated_at_ms),按 updated 倒序。
  /// 用于"按项目导出"。
  Future<List<Map<String, dynamic>>> listThreadsByCwd({required String cwd});

  /// 完整解析 thread:读 sqlite 元数据 + 流式解析 rollout JSONL。详情视图与导出共用。
  Future<CodexThreadDetail> loadThreadDetail({required String id});

  /// 按 `model_provider` 分组的桶列表。首页使用。
  Future<List<CodexBucket>> listBuckets();

  /// 单桶下会话列表(分页)。
  Future<List<CodexThread>> listThreadsByBucket({
    required String bucket,
    int limit = 30,
    int offset = 0,
  });
}

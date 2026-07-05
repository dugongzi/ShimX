import 'package:shim/features/codex_session/domain/models/codex_import_result.dart';
import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';

/// codex 会话的写操作:删除 / 导出(单条+打 zip)/ 导入(单条+解 zip)。
abstract class CodexSessionActionRepository {
  // delete

  /// 删除会话,返回备份文件路径。
  Future<String> deleteThread({required String id});

  // export

  /// 弹保存对话框 → 写单条 detail。用户取消返回 null。
  Future<String?> pickAndExport({
    required CodexThreadDetail detail,
    required String format,
    String? dialogTitle,
  });

  /// 弹保存对话框 → 多条打 zip 写。用户取消返回 (path: null, ok: 0, failed: 0)。
  Future<({String? path, int ok, int failed})> pickAndExportBundle({
    required Iterable<CodexThreadDetail> details,
    required String format,
    required String defaultBundleFileName,
    String? dialogTitle,
  });

  /// 已知 outputPath 时直接写文件。format ∈ {markdown, raws, html}。
  Future<void> exportToFile({
    required CodexThreadDetail detail,
    required String format,
    required String outputPath,
  });

  /// 已知 outputPath 时多条打 zip。zip 内为空时不写文件并返回 (0, failed)。
  Future<({int ok, int failed})> exportBundleToZip({
    required Iterable<CodexThreadDetail> details,
    required String format,
    required String outputPath,
  });

  // import

  /// 弹文件选择器(单个 .jsonl)→ 写 codex sqlite + rollout 文件。用户取消返回 null。
  Future<CodexImportResult?> importSingle({String? targetCwd});

  /// 弹文件选择器(一个 .zip)→ 解压内部所有 .jsonl 批量导入。
  /// 用户取消返回 null;zip 内无 jsonl 时返回 (ok: 0, failed: 0, imported: const []).
  Future<CodexImportBundleResult?> importBundle({String? targetCwd});

  // bucket move

  /// 把 [threadIds] 里的会话都移动到 [targetBucket]。返回实际 UPDATE 的行数。
  Future<int> moveThreadsToBucket({
    required List<String> threadIds,
    required String targetBucket,
  });
}

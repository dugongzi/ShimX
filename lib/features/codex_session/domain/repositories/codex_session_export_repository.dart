import 'package:shim/features/codex_session/domain/models/codex_thread_detail.dart';

abstract class CodexSessionExportRepository {
  /// 读 sqlite 里的 thread 元数据 + rollout JSONL 文件,解析成结构化明细。
  Future<CodexThreadDetail> loadThreadDetail({required String id});

  /// 把 detail 按 format 写到 outputPath。format ∈ {markdown, raws}.
  /// raws = 直接拷贝 rollout JSONL 原文件,不重新拼。
  Future<void> exportToFile({
    required CodexThreadDetail detail,
    required String format,
    required String outputPath,
  });
}

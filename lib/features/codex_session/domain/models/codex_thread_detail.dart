import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/codex_session/domain/models/codex_thread_message.dart';

part 'codex_thread_detail.freezed.dart';

/// 一个 thread 的完整明细:sqlite 的 thread 元数据 + rollout JSONL 解析出的消息流。
/// 用于导出。
@freezed
abstract class CodexThreadDetail with _$CodexThreadDetail {
  const CodexThreadDetail._();

  const factory CodexThreadDetail({
    required String id,
    required String title,
    required String cwd,
    required int createdAtMs,
    required int updatedAtMs,
    required String modelProvider,
    required String model,
    required String cliVersion,
    /// 原始 rollout 文件路径
    required String rolloutPath,
    /// 按 rollout 顺序的消息流
    required List<CodexThreadMessage> messages,
  }) = _CodexThreadDetail;
}

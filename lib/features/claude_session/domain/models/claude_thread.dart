import 'package:freezed_annotation/freezed_annotation.dart';

part 'claude_thread.freezed.dart';

/// Claude Code 会话列表项。一个 .jsonl 文件 = 一个 thread。
/// title/preview 来自首条真实 user 文本(命令注入剥除);时间来自文件 mtime/ctime。
@freezed
abstract class ClaudeThread with _$ClaudeThread {
  const ClaudeThread._();

  const factory ClaudeThread({
    /// 文件名里的 uuid(去 .jsonl 后缀)
    required String sessionId,
    /// 完整 jsonl 路径,做 detail 加载用
    required String jsonlPath,
    /// 显示标题(首条 user 文本截断到 60 字符)
    required String title,
    /// 列表预览(同 title,可能更长一些用于副标题)
    required String preview,
    /// 会话 cwd(jsonl 头部里的 cwd 字段)
    required String cwd,
    /// git 分支(可能为空)
    required String gitBranch,
    /// 文件 mtime
    required int updatedAtMs,
    /// 文件 ctime
    required int createdAtMs,
    /// 文件大小(字节),做粗略判断是否大文件
    required int sizeBytes,
  }) = _ClaudeThread;
}

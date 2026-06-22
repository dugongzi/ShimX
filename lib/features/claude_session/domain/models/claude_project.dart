import 'package:freezed_annotation/freezed_annotation.dart';

part 'claude_project.freezed.dart';

/// `~/.claude/projects/` 下的一个项目目录;一个项目下挂若干会话(jsonl 文件)。
@freezed
abstract class ClaudeProject with _$ClaudeProject {
  const ClaudeProject._();

  const factory ClaudeProject({
    /// 目录名(原始,作为 ID 用),例如 `f--Programming-projects-FlutterProject-shim`
    required String encodedDir,
    /// 解码后的 cwd(优先取 jsonl 内的 cwd 字段,fallback 用 encodedDir 推算)
    required String cwd,
    /// 会话数(jsonl 文件数)
    required int sessionCount,
    /// 该项目最近活跃时间 = max(jsonl mtime)
    required int lastActiveMs,
  }) = _ClaudeProject;
}

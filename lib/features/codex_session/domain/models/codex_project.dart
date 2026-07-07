import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_project.freezed.dart';

/// 一个 codex "项目" = 一组 cwd 相同的 codex thread。
/// codex 自身没有项目的概念,这是 shimx 层按 cwd 聚合做出来的左栏分组。
@freezed
abstract class CodexProject with _$CodexProject {
  const CodexProject._();

  const factory CodexProject({
    /// 工作目录,空串归一为 `(unknown)` 字面量
    required String cwd,
    /// 会话数(同 cwd 的 thread 条数)
    required int sessionCount,
    /// 最近活跃时间 = max(thread.updatedAtMs)
    required int lastActiveMs,
  }) = _CodexProject;
}

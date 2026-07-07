import 'package:flutter/material.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

/// shimx 暴露的 MCP server 运行态。
/// 三态都是稳定字符串,与 ~/.codex/config.toml / bridge payload 协议保持一致(改名会破跨进程协议)。
enum McpServerStatus {
  /// 进程内 HTTP server 已起,可被 codex 调用
  running('running'),

  /// 未启动
  stopped('stopped'),

  /// 启动失败(看 statusDetail)
  error('error');

  const McpServerStatus(this.wire);

  /// 对外/对存储的字符串形式
  final String wire;

  /// 从字符串解析。未知值兜底 [stopped]。
  static McpServerStatus fromWire(String value) {
    for (final s in values) {
      if (s.wire == value) return s;
    }
    return McpServerStatus.stopped;
  }

  /// 状态显示色 + l10n 文案。Colors.green 集中在这里,widget 不直接用。
  (Color color, String label) visual(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    switch (this) {
      case McpServerStatus.running:
        return (Colors.green, l10n.mcpStatusRunning);
      case McpServerStatus.error:
        return (colorScheme.error, l10n.mcpStatusError);
      case McpServerStatus.stopped:
        return (colorScheme.onSurfaceVariant, l10n.mcpStatusStopped);
    }
  }
}

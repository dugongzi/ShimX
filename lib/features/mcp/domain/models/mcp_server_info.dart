import 'package:freezed_annotation/freezed_annotation.dart';

part 'mcp_server_info.freezed.dart';

/// shim 自己暴露的一个 MCP server 在 UI 列表里的展示信息。
///
/// status:
///   running    — 进程内 HTTP server 已起,可被 codex 调用
///   stopped    — 未启动
///   error      — 启动失败(看 statusDetail)
@freezed
abstract class McpServerInfo with _$McpServerInfo {
  const McpServerInfo._();

  const factory McpServerInfo({
    /// 唯一 key,例如 'shim_claude'(也是 ~/.codex/config.toml 里 [mcp_servers.<id>] 的 id)
    required String id,
    /// 人类可读名称,UI 显示用
    required String name,
    /// 一句话描述这个 server 干什么
    required String description,
    /// 本地 HTTP MCP 地址,例如 http://127.0.0.1:18787/mcp
    required String url,
    /// running / stopped / error
    required String status,
    /// status 为 error 时的额外说明,其它情况空
    @Default('') String statusDetail,
    /// 暴露的工具数(用于一眼看出 server 是否健康)
    @Default(0) int toolCount,
    /// 是否已写到 ~/.codex/config.toml 里
    @Default(false) bool registeredInCodex,
  }) = _McpServerInfo;
}

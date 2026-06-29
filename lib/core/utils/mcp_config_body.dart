/// 新建 codex mcp 配置时填进编辑框的默认 TOML 内容。
/// 与 codex `[mcp_servers.<id>]` 的最小可用字段对齐(command + args)。
const String defaultMcpConfigBody = 'command = ""\nargs = []';

/// 取文本第一行非空内容,用作 config 卡片副标题预览。
String firstNonEmptyLine(String text) {
  return text
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');
}

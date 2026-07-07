import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/app_storage.dart';

/// shimx 内置 MCP server 的写端:
///   - saveEnabled:持久化开关到本地存储
///   - registerInCodex / unregisterFromCodex:在 ~/.codex/config.toml 增删
///     `[mcp_servers.<id>]` 段。纯文本拼接,不全量重写 —— 避免误改用户已有
///     配置(model_providers / projects / 其它 mcp_servers 等)。
class McpServerActionDatasource {
  McpServerActionDatasource({required this.appStorage});

  final AppStorage appStorage;

  static const String _enabledKey = 'mcp_server_enabled';

  Future<void> saveEnabled(bool enabled) {
    return appStorage.setBool(_enabledKey, enabled);
  }

  /// 在 ~/.codex/config.toml 末尾追加 `[mcp_servers.<id>] url = "..."` 段。
  /// 若已存在同名段,不动(交由 unregister 先清再加)。
  ///
  /// 返回 true 表示文件被改;false 表示已存在或文件缺失。
  Future<bool> registerInCodex({
    required String id,
    required String url,
  }) async {
    final file = _codexConfigFile();
    if (file == null) return false;
    final section = '[mcp_servers.$id]';
    String text = '';
    if (await file.exists()) {
      text = await file.readAsString();
      if (text.contains(section)) {
        AppLogService.instance.info(
          'McpServer',
          'config.toml 已存在 $section,跳过追加',
        );
        return false;
      }
    } else {
      // 父目录不存在时也建,Codex 第一次跑前 shimx 也可能先一步建好这个文件
      await file.parent.create(recursive: true);
    }

    final separator = text.isEmpty || text.endsWith('\n') ? '' : '\n';
    final block = '$separator\n$section\nurl = "$url"\n';
    await file.writeAsString(text + block);
    AppLogService.instance.info(
      'McpServer',
      'config.toml 已写入 $section',
      details: 'url=$url',
    );
    return true;
  }

  /// 从 ~/.codex/config.toml 移除 `[mcp_servers.<id>]` 段(到下一个 `[...]`
  /// 或文件末尾为止)。其它段保留原样。
  ///
  /// 返回 true 表示文件被改;false 表示未命中。
  Future<bool> unregisterFromCodex({required String id}) async {
    final file = _codexConfigFile();
    if (file == null || !await file.exists()) return false;
    final section = '[mcp_servers.$id]';
    final text = await file.readAsString();
    final start = text.indexOf(section);
    if (start < 0) return false;

    // 找到下一个 `\n[` 作为段末(忽略 mcp_servers.<id>.env 这种子段也跟着一起删,
    // 因为它们绑定到这个 server,本来就要一起清)
    int searchFrom = start + section.length;
    int end = text.length;
    while (true) {
      final next = text.indexOf('\n[', searchFrom);
      if (next < 0) break;
      // 子段 `[mcp_servers.<id>.xxx]` 也属于本块,继续找下一个
      final nextTagEnd = text.indexOf(']', next);
      if (nextTagEnd < 0) break;
      final nextTag = text.substring(next + 1, nextTagEnd + 1);
      if (nextTag.startsWith('[mcp_servers.$id.')) {
        searchFrom = nextTagEnd + 1;
        continue;
      }
      end = next + 1; // 保留下一段前的换行
      break;
    }

    // 把当前段前面残留的空行也吃掉,避免段间出现连续 \n\n\n
    int realStart = start;
    while (realStart > 0 && text[realStart - 1] == '\n') {
      realStart--;
    }
    final newText =
        '${text.substring(0, realStart)}\n${text.substring(end)}'.trimRight();
    await file.writeAsString('$newText\n');
    AppLogService.instance.info(
      'McpServer',
      'config.toml 已移除 $section',
    );
    return true;
  }

  File? _codexConfigFile() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;
    return File(p.join(home, '.codex', 'config.toml'));
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

import 'package:shimx/core/services/codex_paths.dart';

/// 供 plugin_query_datasource / plugin_action_datasource 共用的路径 + config 工具。
/// 不做 IO 以外的业务判断,纯 helper。
class PluginMarketplacePaths {
  const PluginMarketplacePaths._();

  static const curatedName = 'openai-curated';
  static const apiCuratedName = 'openai-api-curated';
  static const curatedRemoteName = 'openai-curated-remote';

  /// 三个 marketplace 都指向同一个本地目录。
  static List<String> get allNames =>
      const [curatedName, apiCuratedName, curatedRemoteName];

  static Directory curatedRoot() => Directory(CodexPaths.pluginsCuratedRoot());

  static File marketplaceJson(Directory root) =>
      File(p.join(root.path, '.agents', 'plugins', 'marketplace.json'));

  static Directory pluginsSubdir(Directory root) =>
      Directory(p.join(root.path, 'plugins'));

  /// 读 `<codex_home>/config.toml`。文件不存在返回空 map,BOM 处理干净。
  static Map<String, dynamic> readConfigDoc() {
    final file = File(CodexPaths.configToml());
    if (!file.existsSync()) return <String, dynamic>{};
    final raw = _stripBom(file.readAsStringSync());
    if (raw.trim().isEmpty) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(TomlDocument.parse(raw).toMap());
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// 覆盖写 `<codex_home>/config.toml`,末尾保证换行。
  static void writeConfigDoc(Map<String, dynamic> doc) {
    final rendered = TomlDocument.fromMap(doc).toString();
    final normalized = rendered.endsWith('\n') ? rendered : '$rendered\n';
    final file = File(CodexPaths.configToml());
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(normalized);
  }

  static String _stripBom(String s) =>
      s.startsWith('﻿') ? s.substring(1) : s;
}

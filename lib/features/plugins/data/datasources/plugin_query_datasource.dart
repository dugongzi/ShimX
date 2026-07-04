import 'dart:io';

import 'package:shim/core/services/codex_paths.dart';
import 'package:shim/features/plugins/data/datasources/plugin_marketplace_paths.dart';
import 'package:shim/features/plugins/data/models/plugin_marketplace_status_dto.dart';

/// 只读:汇总 curated marketplace 磁盘 + config 状态,产出 DTO。
/// 严禁在这里做写操作(那些去 PluginActionDatasource)。
class PluginQueryDatasource {
  const PluginQueryDatasource();

  PluginMarketplaceStatusDto readMarketplaceStatus() {
    final home = CodexPaths.home();
    final root = PluginMarketplacePaths.curatedRoot();
    final marketplaceJson = PluginMarketplacePaths.marketplaceJson(root);
    final installed = root.existsSync() && marketplaceJson.existsSync();

    var pluginCount = 0;
    if (installed) {
      final pluginsDir = PluginMarketplacePaths.pluginsSubdir(root);
      if (pluginsDir.existsSync()) {
        pluginCount = pluginsDir
            .listSync()
            .whereType<Directory>()
            .where((d) => File(
                    '${d.path}${Platform.pathSeparator}.codex-plugin${Platform.pathSeparator}plugin.json')
                .existsSync())
            .length;
      }
    }

    final configured = _configPointsToLocalRoot(root.path);
    return PluginMarketplaceStatusDto(
      installed: installed,
      configured: configured,
      pluginCount: pluginCount,
      codexHome: home,
    );
  }

  bool _configPointsToLocalRoot(String expectedRoot) {
    final doc = PluginMarketplacePaths.readConfigDoc();
    final marketplaces = doc['marketplaces'];
    if (marketplaces is! Map) return false;
    for (final name in PluginMarketplacePaths.allNames) {
      final section = marketplaces[name];
      if (section is! Map) return false;
      if (section['source_type'] != 'local') return false;
      if (section['source'] != expectedRoot) return false;
    }
    return true;
  }
}

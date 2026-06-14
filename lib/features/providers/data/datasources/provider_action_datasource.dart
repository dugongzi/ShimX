import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/providers/data/models/api_provider_dto.dart';

class ProviderActionDatasource {
  ProviderActionDatasource({required this.appStorage});

  final AppStorage appStorage;

  static const _listKey = 'api_provider_list';
  static const _selectedKey = 'api_provider_selected';
  static const _proxyEnabledKey = 'codex_proxy_enabled';
  static const _proxyPortKey = 'codex_proxy_port';

  /// 备份原始 base_url 的存储 key
  static const _backupKey = 'codex_base_url_backup';

  /// 匹配 `base_url = "xxx"`（允许等号两侧空格、单双引号）
  static final _baseUrlPattern = RegExp(r'''(base_url\s*=\s*)(['"])(.*?)\2''');

  Future<void> saveProviders(List<ApiProviderDto> providers) async {
    final encoded = jsonEncode(providers.map((p) => p.toJson()).toList());
    await appStorage.setString(_listKey, encoded);
  }

  Future<void> saveSelectedId(String? id) async {
    if (id == null) {
      await appStorage.remove(_selectedKey);
    } else {
      await appStorage.setString(_selectedKey, id);
    }
  }

  Future<void> saveProxyEnabled(bool enabled) {
    return appStorage.setBool(_proxyEnabledKey, enabled);
  }

  Future<void> saveProxyPort(int port) {
    return appStorage.setInt(_proxyPortKey, port);
  }

  /// 开启接管：把 base_url 改成本地代理地址，原值备份。
  /// 只对 base_url 这一行做文本替换，不解析整份 TOML。
  Future<bool> enableTakeover({required String localProxyUrl}) async {
    final file = File(_codexConfigPath());
    if (!await file.exists()) return false;

    final text = await file.readAsString();
    final match = _baseUrlPattern.firstMatch(text);
    if (match == null) return false;

    final originalUrl = match.group(3)!;
    // 已经是本地代理地址则不重复备份（避免把代理地址当原值存下来）
    if (!_isLocalProxy(originalUrl)) {
      await appStorage.setString(_backupKey, originalUrl);
    }

    final replaced = text.replaceFirst(
      _baseUrlPattern,
      'base_url = "$localProxyUrl"',
    );
    await file.writeAsString(replaced);
    return true;
  }

  /// 关闭接管：把 base_url 还原成备份的原值。
  Future<bool> disableTakeover() async {
    final original = await appStorage.getString(_backupKey);
    if (original == null || original.isEmpty) return false;

    final file = File(_codexConfigPath());
    if (!await file.exists()) return false;

    final text = await file.readAsString();
    if (!_baseUrlPattern.hasMatch(text)) return false;

    final replaced = text.replaceFirst(
      _baseUrlPattern,
      'base_url = "$original"',
    );
    await file.writeAsString(replaced);
    await appStorage.remove(_backupKey);
    return true;
  }

  bool _isLocalProxy(String url) {
    return url.contains('127.0.0.1') || url.contains('localhost');
  }

  String _codexConfigPath() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('Cannot resolve user home directory');
    }
    return p.join(home, '.codex', 'config.toml');
  }
}

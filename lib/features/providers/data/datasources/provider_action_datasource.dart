import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/features/providers/data/models/api_provider_dto.dart';
import 'package:toml/toml.dart';

class ProviderActionDatasource {
  ProviderActionDatasource({required this.appStorage});

  final AppStorage appStorage;

  static const _listKey = 'api_provider_list';
  static const _selectedKey = 'api_provider_selected';
  static const _proxyEnabledKey = 'codex_proxy_enabled';
  static const _proxyPortKey = 'codex_proxy_port';

  /// 备份原始 base_url 的存储 key(旧版字符串备份,仍保留以便 disableTakeover 兼容)
  static const _backupKey = 'codex_base_url_backup';

  /// 接管前的整份 config.toml + auth.json 快照目录。
  /// 切换到 ChatGPT 官方登录时 Codex 会把 config.toml 几乎擦光、auth.json 改成 {},
  /// 用户原本写在里面的 [projects.*] / [mcp_servers] / model / sandbox_mode 等也会一起丢。
  /// 单存 base_url 字符串不够 —— 必须把"接管前的完整状态"整份留底。
  static const _backupDirName = '.shim_takeover_backup';
  static const _backupConfigName = 'config.toml.bak';
  static const _backupAuthName = 'auth.json.bak';
  static const _backupMetaName = 'meta.json';

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

  /// 开启接管：把当前生效的 base_url 改成本地代理地址，原值备份。
  ///
  /// 流程：
  /// 1. config.toml 不存在 → 写默认模板(base_url 直接是本地代理)
  /// 2. 解析 base_url:
  ///    - 已是 127.0.0.1 → 不动
  ///    - 是别的有效 URL → 拍快照(整份 config + auth,已有则跳过)+ 原文精确替换
  ///    - 拿不到:
  ///        a. 有快照 → 还原快照后重新走 (2)
  ///        b. 无快照 → 首次安装/全新 Codex,写默认模板进去
  Future<bool> enableTakeover({required String localProxyUrl}) async {
    final path = _codexConfigPath();
    AppLogService.instance.info(
      'Takeover',
      'enableTakeover',
      details: 'localProxyUrl=$localProxyUrl\npath=$path',
    );
    final file = File(path);
    if (!await file.exists()) {
      AppLogService.instance.warning(
        'Takeover',
        'config.toml 不存在,写入默认模板',
        details: path,
      );
      await _writeDefaultTemplate(localProxyUrl: localProxyUrl);
      return true;
    }

    var text = await file.readAsString();
    var currentUrl = _resolveActiveBaseUrl(text);
    AppLogService.instance.info('Takeover', '定位到当前 base_url', details: '$currentUrl');

    // 已经是本地代理 → 不动
    if (currentUrl != null && _isLocalProxy(currentUrl)) {
      AppLogService.instance.warning('Takeover', '当前已是本地代理地址，跳过', details: currentUrl);
      return true;
    }

    // 拿不到 base_url:被 Codex 擦写过(切官方) 或 首次安装从未配过 provider
    if (currentUrl == null || currentUrl.isEmpty) {
      // 先试快照
      final hasSnapshot = await File(_backupConfigPath()).exists();
      if (hasSnapshot) {
        AppLogService.instance.warning(
          'Takeover',
          '当前 config.toml 无法定位 base_url,尝试从快照还原',
        );
        final restored = await _restoreSnapshot();
        if (!restored) {
          AppLogService.instance.error('Takeover', '快照还原失败');
          return false;
        }
        text = await file.readAsString();
        currentUrl = _resolveActiveBaseUrl(text);
        if (currentUrl == null || currentUrl.isEmpty) {
          AppLogService.instance.error('Takeover', '快照还原后仍无法定位 base_url');
          return false;
        }
        if (_isLocalProxy(currentUrl)) {
          AppLogService.instance.info(
            'Takeover',
            '快照还原后已是本地代理,无需改写',
            details: currentUrl,
          );
          return true;
        }
        // fall-through: 走下面的"拍快照(已跳过)+ 替换"
      } else {
        // 无快照 → 首次安装,写默认模板覆盖现有(可能只剩 [mcp_servers])的 config
        AppLogService.instance.warning(
          'Takeover',
          'config.toml 无 base_url 且无快照,视为首次安装,写入默认模板',
        );
        await _writeDefaultTemplate(
          localProxyUrl: localProxyUrl,
          preserveText: text,
        );
        return true;
      }
    }

    // 走到这里 currentUrl 一定是非本地的有效 URL —— 拍快照(若已有则跳过)
    await _captureSnapshotIfMissing(configText: text, originalBaseUrl: currentUrl);

    final replaced = _replaceBaseUrlValue(text, currentUrl, localProxyUrl);
    if (replaced == null) {
      AppLogService.instance.error('Takeover', '替换失败（原文找不到精确值）');
      return false;
    }

    await appStorage.setString(_backupKey, currentUrl);
    await file.writeAsString(replaced);
    AppLogService.instance.info(
      'Takeover',
      '已改写 base_url',
      details: '$currentUrl -> $localProxyUrl',
    );
    return true;
  }

  /// 写入默认 provider 模板。
  /// - [preserveText] 不为空时,会把现有内容里的 [mcp_servers] / [projects.*] 等保留段
  ///   原样拼到模板下方,避免擦掉用户/Codex 自己的配置。
  /// - provider id 优先沿用:快照里的 model_provider → preserveText 里的 model_provider →
  ///   "shim"。这样已有 thread 元数据里指名的 provider 不会变。
  Future<void> _writeDefaultTemplate({
    required String localProxyUrl,
    String? preserveText,
  }) async {
    final providerId = await _resolveProviderIdForTemplate(preserveText);

    final template = StringBuffer()
      ..writeln('model_provider = "$providerId"')
      ..writeln('model = "gpt-5.5"')
      ..writeln('model_reasoning_effort = "high"')
      ..writeln('disable_response_storage = true')
      ..writeln()
      ..writeln('[model_providers.$providerId]')
      ..writeln('name = "$providerId"')
      ..writeln('wire_api = "responses"')
      ..writeln('requires_openai_auth = true')
      ..writeln('base_url = "$localProxyUrl"')
      ..writeln();

    if (preserveText != null && preserveText.trim().isNotEmpty) {
      // 把"非 model 相关"的段原样追加 —— [mcp_servers] / [projects.*] / [windows] 等
      final kept = _stripProviderSectionsFromText(preserveText);
      if (kept.isNotEmpty) {
        template.writeln(kept);
      }
    }

    await File(_codexConfigPath()).writeAsString(template.toString());
    AppLogService.instance.info(
      'Takeover',
      '已写入默认 provider 模板',
      details: 'providerId=$providerId localProxyUrl=$localProxyUrl preserved=${preserveText != null}',
    );
  }

  /// 决定写模板时用哪个 provider id。
  /// 优先级:快照里的 model_provider → 当前文本里的 model_provider → "shim"。
  /// 这样能继承用户原本的命名(比如旧 thread 里依赖的 "custom"),不破坏已有 thread 元数据。
  Future<String> _resolveProviderIdForTemplate(String? currentText) async {
    final fromSnapshot = await _readSnapshotProviderId();
    if (fromSnapshot != null && fromSnapshot.isNotEmpty) return fromSnapshot;
    if (currentText != null && currentText.isNotEmpty) {
      final fromCurrent = _extractModelProviderId(currentText);
      if (fromCurrent != null && fromCurrent.isNotEmpty) return fromCurrent;
    }
    return 'shim';
  }

  Future<String?> _readSnapshotProviderId() async {
    try {
      final bak = File(_backupConfigPath());
      if (!await bak.exists()) return null;
      return _extractModelProviderId(await bak.readAsString());
    } catch (_) {
      return null;
    }
  }

  String? _extractModelProviderId(String text) {
    try {
      final doc = TomlDocument.parse(text).toMap();
      final id = doc['model_provider'];
      return id is String && id.isNotEmpty ? id : null;
    } catch (_) {
      // 正则兜底,toml 解析坏了也能抓
      final m = RegExp(r'''^\s*model_provider\s*=\s*["']([^"']+)["']''', multiLine: true).firstMatch(text);
      return m?.group(1);
    }
  }

  /// 从原文里剥掉跟 provider 相关的段(顶层 model_*、[model_providers.*]),
  /// 其它段原样返回。用于"首次安装"场景下保留 [mcp_servers] / [projects.*]。
  String _stripProviderSectionsFromText(String text) {
    final lines = text.split('\n');
    final keep = <String>[];
    bool inProviderSection = false;
    final providerSectionHeader = RegExp(r'^\s*\[\s*model_providers(\.|\s*\])');
    final anySectionHeader = RegExp(r'^\s*\[');
    final topLevelProviderKey = RegExp(
      r'^\s*(model_provider|model|model_reasoning_effort|disable_response_storage)\s*=',
    );

    for (final line in lines) {
      if (providerSectionHeader.hasMatch(line)) {
        inProviderSection = true;
        continue;
      }
      if (inProviderSection && anySectionHeader.hasMatch(line)) {
        inProviderSection = false;
      }
      if (inProviderSection) continue;
      // 顶层 provider 相关 key 也跳过(它们在第一个 [section] 出现前)
      if (keep.where((l) => anySectionHeader.hasMatch(l)).isEmpty &&
          topLevelProviderKey.hasMatch(line)) {
        continue;
      }
      keep.add(line);
    }
    return keep.join('\n').trim();
  }

  /// 关闭接管：把当前的本地代理 base_url 精确还原成备份的原值。
  Future<bool> disableTakeover() async {
    final original = await appStorage.getString(_backupKey);
    if (original == null || original.isEmpty) return false;

    final file = File(_codexConfigPath());
    if (!await file.exists()) return false;

    final text = await file.readAsString();
    final currentUrl = _resolveActiveBaseUrl(text);
    if (currentUrl == null) return false;

    final replaced = _replaceBaseUrlValue(text, currentUrl, original);
    if (replaced == null) return false;

    await file.writeAsString(replaced);
    await appStorage.remove(_backupKey);
    AppLogService.instance.info('Takeover', '已还原 base_url', details: '$currentUrl -> $original');
    return true;
  }

  /// 用 toml 库解析定位当前生效的 base_url：
  /// 优先 `[model_providers.<model_provider>].base_url`，回退顶层 `base_url`。
  /// 解析失败返回 null（调用方放弃改写，保证不会乱动文件）。
  String? _resolveActiveBaseUrl(String text) {
    try {
      final doc = TomlDocument.parse(text).toMap();
      final modelProvider = doc['model_provider'];
      final providers = doc['model_providers'];
      if (modelProvider is String && providers is Map) {
        final active = providers[modelProvider];
        if (active is Map && active['base_url'] is String) {
          return active['base_url'] as String;
        }
      }
      final topLevel = doc['base_url'];
      return topLevel is String ? topLevel : null;
    } catch (_) {
      return null;
    }
  }

  /// 在原文里把 `base_url = "<oldValue>"` 精确替换成 `base_url = "<newValue>"`，
  /// 只动这一处的值、保留原引号风格，其它字节不变。oldValue 找不到则返回 null。
  String? _replaceBaseUrlValue(String text, String oldValue, String newValue) {
    final escaped = RegExp.escape(oldValue);
    final pattern = RegExp('''(base_url\\s*=\\s*)(['"])$escaped\\2''');
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    final quote = match.group(2);
    return text.replaceRange(
      match.start,
      match.end,
      '${match.group(1)}$quote$newValue$quote',
    );
  }

  bool _isLocalProxy(String url) {
    return url.contains('127.0.0.1') || url.contains('localhost');
  }

  String _codexHomeDir() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('Cannot resolve user home directory');
    }
    return p.join(home, '.codex');
  }

  String _codexConfigPath() => p.join(_codexHomeDir(), 'config.toml');
  String _codexAuthPath() => p.join(_codexHomeDir(), 'auth.json');

  String _backupDir() => p.join(_codexHomeDir(), _backupDirName);
  String _backupConfigPath() => p.join(_backupDir(), _backupConfigName);
  String _backupAuthPath() => p.join(_backupDir(), _backupAuthName);
  String _backupMetaPath() => p.join(_backupDir(), _backupMetaName);

  /// 拍一份"接管前的完整状态"快照:config.toml + auth.json + 元信息。
  /// 已存在则不覆盖 —— 避免 Codex 已经擦写过、此时再"备份"等于把空文件存进去。
  Future<void> _captureSnapshotIfMissing({
    required String configText,
    String? originalBaseUrl,
  }) async {
    final dir = Directory(_backupDir());
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final configBak = File(_backupConfigPath());
    if (await configBak.exists()) {
      AppLogService.instance.info(
        'Takeover',
        '快照已存在,跳过备份',
        details: configBak.path,
      );
      return;
    }
    await configBak.writeAsString(configText);

    final authSrc = File(_codexAuthPath());
    final authBak = File(_backupAuthPath());
    if (await authSrc.exists()) {
      await authBak.writeAsString(await authSrc.readAsString());
    }

    final meta = {
      'createdAt': DateTime.now().toIso8601String(),
      'originalBaseUrl': originalBaseUrl,
    };
    await File(_backupMetaPath()).writeAsString(jsonEncode(meta));

    AppLogService.instance.info(
      'Takeover',
      '已快照接管前状态',
      details: 'dir=${dir.path}\noriginalBaseUrl=$originalBaseUrl',
    );
  }

  /// 用快照还原 config.toml + auth.json。
  /// 返回 true 表示真的写回去了。
  Future<bool> _restoreSnapshot() async {
    final configBak = File(_backupConfigPath());
    if (!await configBak.exists()) {
      AppLogService.instance.warning('Takeover', '没有快照可还原');
      return false;
    }
    await File(_codexConfigPath()).writeAsString(await configBak.readAsString());

    final authBak = File(_backupAuthPath());
    if (await authBak.exists()) {
      await File(_codexAuthPath()).writeAsString(await authBak.readAsString());
    }

    AppLogService.instance.info('Takeover', '已从快照还原 config.toml + auth.json');
    return true;
  }
}

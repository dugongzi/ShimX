import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/utils/codex_mcp_config_toml_codec.dart';
import 'package:shim/features/mcp/data/models/codex_mcp_config_dto.dart';

class CodexMcpConfigActionDatasource {
  CodexMcpConfigActionDatasource({File? configFile}) : _configFile = configFile;

  final File? _configFile;

  Future<void> saveConfig(CodexMcpConfigDto config) async {
    final file = _codexConfigFile();
    if (file == null) throw StateError('Cannot resolve user home directory');
    final current = await _read(file);
    final next = upsertShimManagedCodexMcpConfigBlock(
      current,
      kind: config.kind,
      id: config.id,
      bodyText: setEnabledInCodexMcpConfigBody(config.bodyText, config.enabled),
    );
    await _write(file, next);
    AppLogService.instance.info(
      'CodexMcpConfig',
      'MCP 配置已保存',
      details: _details(
        file: file,
        kind: config.kind,
        id: config.id,
        extra: 'enabled=${config.enabled}, changed=${current != next}',
      ),
    );
  }

  Future<void> deleteConfig({required String kind, required String id}) async {
    final file = _codexConfigFile();
    if (file == null) throw StateError('Cannot resolve user home directory');
    if (!await file.exists()) {
      throw StateError('Codex config.toml 不存在: ${file.path}');
    }
    final current = await _read(file);
    final next = deleteShimManagedCodexMcpConfigBlock(
      current,
      kind: kind,
      id: id,
    );
    await _write(file, next);
    AppLogService.instance.info(
      'CodexMcpConfig',
      'MCP 配置已删除',
      details: _details(
        file: file,
        kind: kind,
        id: id,
        extra: 'changed=${current != next}',
      ),
    );
  }

  Future<void> setEnabled({
    required String kind,
    required String id,
    required bool enabled,
  }) async {
    final file = _codexConfigFile();
    if (file == null) throw StateError('Cannot resolve user home directory');
    if (!await file.exists()) {
      throw StateError('Codex config.toml 不存在: ${file.path}');
    }

    final current = await _read(file);
    final before = _findConfig(current, kind: kind, id: id);
    if (before == null) {
      throw StateError('未找到 Codex MCP 配置: $id');
    }
    AppLogService.instance.info(
      'CodexMcpConfig',
      '开始切换 MCP 配置',
      details: _details(
        file: file,
        kind: kind,
        id: id,
        extra: 'before=${before.enabled}, target=$enabled',
      ),
    );

    final next = setShimManagedCodexMcpConfigEnabled(
      current,
      kind: kind,
      id: id,
      enabled: enabled,
    );
    if (next == current && before.enabled != enabled) {
      throw StateError('MCP 配置开关写入没有产生文本变化: $id');
    }
    await _write(file, next);

    final writtenText = await _read(file);
    final after = _findConfig(writtenText, kind: kind, id: id);
    if (after == null) {
      throw StateError('MCP 配置写入后丢失: $id');
    }
    if (after.enabled != enabled) {
      throw StateError(
        'MCP 配置写入后状态不一致: $id, expected=$enabled, actual=${after.enabled}',
      );
    }

    AppLogService.instance.info(
      'CodexMcpConfig',
      'MCP 配置开关已写入',
      details: _details(
        file: file,
        kind: kind,
        id: id,
        extra:
            'before=${before.enabled}, after=${after.enabled}, changed=${current != next}',
      ),
    );
  }

  Future<String> _read(File file) async {
    if (!await file.exists()) return '';
    return file.readAsString(encoding: utf8);
  }

  Future<void> _write(File file, String text) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(text, encoding: utf8, flush: true);
  }

  File? _codexConfigFile() {
    if (_configFile != null) return _configFile;
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;
    return File(p.join(home, '.codex', 'config.toml'));
  }

  CodexMcpConfigTomlFragment? _findConfig(
    String text, {
    required String kind,
    required String id,
  }) {
    for (final config in parseCodexMcpConfigs(text)) {
      if (config.kind == kind && config.id == id) return config;
    }
    return null;
  }

  String _details({
    required File file,
    required String kind,
    required String id,
    required String extra,
  }) {
    return 'path=${file.path}\nkind=$kind\nid=$id\n$extra';
  }
}

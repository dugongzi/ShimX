import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/utils/codex_tool_toml_codec.dart';
import 'package:shim/features/mcp/data/models/codex_tool_dto.dart';

class CodexToolActionDatasource {
  CodexToolActionDatasource({File? configFile}) : _configFile = configFile;

  final File? _configFile;

  Future<void> saveTool(CodexToolDto tool) async {
    final file = _codexConfigFile();
    if (file == null) throw StateError('Cannot resolve user home directory');
    final current = await _read(file);
    final next = upsertShimManagedCodexToolBlock(
      current,
      kind: tool.kind,
      id: tool.id,
      bodyText: setEnabledInCodexToolBody(tool.bodyText, tool.enabled),
    );
    await _write(file, next);
    AppLogService.instance.info(
      'CodexTool',
      '配置片段已保存',
      details: _details(
        file: file,
        kind: tool.kind,
        id: tool.id,
        extra: 'enabled=${tool.enabled}, changed=${current != next}',
      ),
    );
  }

  Future<void> deleteTool({required String kind, required String id}) async {
    final file = _codexConfigFile();
    if (file == null) throw StateError('Cannot resolve user home directory');
    if (!await file.exists()) {
      throw StateError('Codex config.toml 不存在: ${file.path}');
    }
    final current = await _read(file);
    final next = deleteShimManagedCodexToolBlock(current, kind: kind, id: id);
    await _write(file, next);
    AppLogService.instance.info(
      'CodexTool',
      '配置片段已删除',
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
    final before = _findTool(current, kind: kind, id: id);
    if (before == null) {
      throw StateError('未找到配置片段: $id');
    }
    AppLogService.instance.info(
      'CodexTool',
      '开始切换配置片段',
      details: _details(
        file: file,
        kind: kind,
        id: id,
        extra: 'before=${before.enabled}, target=$enabled',
      ),
    );

    final next = setShimManagedCodexToolEnabled(
      current,
      kind: kind,
      id: id,
      enabled: enabled,
    );
    if (next == current && before.enabled != enabled) {
      throw StateError('配置片段开关写入没有产生文本变化: $id');
    }
    await _write(file, next);

    final writtenText = await _read(file);
    final after = _findTool(writtenText, kind: kind, id: id);
    if (after == null) {
      throw StateError('配置片段写入后丢失: $id');
    }
    if (after.enabled != enabled) {
      throw StateError(
        '配置片段写入后状态不一致: $id, expected=$enabled, actual=${after.enabled}',
      );
    }

    AppLogService.instance.info(
      'CodexTool',
      '配置片段开关已写入',
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

  CodexToolTomlFragment? _findTool(
    String text, {
    required String kind,
    required String id,
  }) {
    for (final tool in parseCodexTools(text)) {
      if (tool.kind == kind && tool.id == id) return tool;
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

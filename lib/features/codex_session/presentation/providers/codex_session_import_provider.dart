import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/app_log_service.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/features/codex_session/data/datasources/codex_session_import_datasource.dart';

part 'codex_session_import_provider.g.dart';

/// 注册导入路由。
///
/// /session/import         — 弹文件选择器 (.jsonl), 把单条 rollout 导入到 codex。
///   payload.targetCwd     可选, 把导入的 thread 强制归到该 cwd; 不传则保留 rollout 自带 cwd。
///
/// /session/import-bundle  — 弹文件选择器 (.zip), 解压后批量导入。zip 里所有 .jsonl 都试着当 rollout 解析。
///   payload.targetCwd     同上, 应用到 zip 内所有条目。
@Riverpod(keepAlive: true)
bool codexSessionImportRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final datasource = CodexSessionImportDatasource();

  bridge.register('/session/import', (payload) async {
    final targetCwd = (payload['targetCwd'] as String?)?.trim();
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import conversation',
      type: FileType.custom,
      allowedExtensions: ['jsonl'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return {'ok': false, 'cancelled': true};
    }
    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) {
      return {'ok': false, 'reason': 'empty-file'};
    }
    try {
      final result = await datasource.importRolloutBytes(
        bytes: bytes,
        overrideCwd: targetCwd != null && targetCwd.isNotEmpty ? targetCwd : null,
        displayName: _fileStem(file.name),
      );
      AppLogService.instance.info(
        'CodexImport',
        '已导入会话',
        details:
            'newId=${result.id} originalId=${result.originalId} cwd=${result.cwd} path=${result.rolloutPath}',
      );
      return {
        'ok': true,
        'id': result.id,
        'rolloutPath': result.rolloutPath,
        'cwd': result.cwd,
        'title': result.title,
      };
    } catch (err, st) {
      AppLogService.instance.error(
        'CodexImport',
        '导入失败',
        details: '$err\n$st',
      );
      return {'ok': false, 'reason': 'parse-or-write-failed', 'message': '$err'};
    }
  });

  bridge.register('/session/import-bundle', (payload) async {
    final targetCwd = (payload['targetCwd'] as String?)?.trim();
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import project bundle',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return {'ok': false, 'cancelled': true};
    }
    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) {
      return {'ok': false, 'reason': 'empty-file'};
    }

    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (err) {
      return {'ok': false, 'reason': 'bad-zip', 'message': '$err'};
    }

    // 找出 zip 内所有 .jsonl 文件
    final jsonlFiles = archive.files
        .where((f) => f.isFile && f.name.toLowerCase().endsWith('.jsonl'))
        .toList();
    if (jsonlFiles.isEmpty) {
      return {'ok': false, 'reason': 'no-jsonl-in-zip', 'count': 0};
    }

    var ok = 0;
    var failed = 0;
    final imported = <Map<String, dynamic>>[];
    for (final entry in jsonlFiles) {
      try {
        final fileBytes = entry.content as List<int>;
        if (fileBytes.isEmpty) {
          failed += 1;
          continue;
        }
        final result = await datasource.importRolloutBytes(
          bytes: fileBytes,
          overrideCwd:
              targetCwd != null && targetCwd.isNotEmpty ? targetCwd : null,
          displayName: _fileStem(entry.name),
        );
        imported.add({
          'id': result.id,
          'title': result.title,
          'originalEntry': entry.name,
        });
        ok += 1;
      } catch (err) {
        failed += 1;
        AppLogService.instance.warning(
          'CodexImport',
          '批量导入: 单条失败',
          details: 'entry=${entry.name} err=$err',
        );
      }
    }

    AppLogService.instance.info(
      'CodexImport',
      '已导入项目',
      details: 'count=$ok failed=$failed targetCwd=$targetCwd',
    );
    return {
      'ok': ok > 0,
      'count': ok,
      'failed': failed,
      'imported': imported,
    };
  });

  return true;
}

/// 取一个路径或文件名的 "stem" (去掉目录 + 去掉最后一个扩展名), 作为 thread title。
/// 例如:
///   "rollout-2026-03-05T14-27-01-019cbcad.jsonl" → "rollout-2026-03-05T14-27-01-019cbcad"
///   "exports/2026-03-05/hi.jsonl"               → "hi"
///   "hi"                                         → "hi"
String _fileStem(String name) {
  if (name.isEmpty) return '';
  // 兼容 zip 内带斜杠的路径
  final lastSep = name.lastIndexOf(RegExp(r'[/\\]'));
  final base = lastSep >= 0 ? name.substring(lastSep + 1) : name;
  final dot = base.lastIndexOf('.');
  if (dot <= 0) return base;
  return base.substring(0, dot);
}

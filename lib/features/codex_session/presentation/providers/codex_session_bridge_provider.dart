import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/bridge_service.dart';
import 'package:shimx/core/utils/codex_session_export_formatter.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_action_provider.dart';
import 'package:shimx/features/codex_session/presentation/providers/codex_session_query_provider.dart';

part 'codex_session_bridge_provider.g.dart';

/// 把 codex 会话相关全部路由注册到 bridge,供 codex_enhance.js 调用。
///
/// 查询:
///   /session/list                   列出未归档会话
///
/// 写:
///   /session/delete                 删除某 thread
///   /session/export                 弹保存对话框 → 单条导出
///   /session/export-bundle          按 cwd 项目批量导出 zip
///   /session/import                 弹文件选择器 → 单条 jsonl 导入
///   /session/import-bundle          弹文件选择器 → zip 内多个 jsonl 批量导入
@Riverpod(keepAlive: true)
bool codexSessionRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);
  final queryRepo = ref.read(codexSessionQueryRepositoryProvider);
  final actionRepo = ref.read(codexSessionActionRepositoryProvider);

  bridge.register('/session/list', (payload) async {
    final limit = (payload['limit'] as int?) ?? 100;
    final threads = await queryRepo.listThreads(limit: limit);
    return {
      'threads': threads
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'preview': t.preview,
                'firstUserMessage': t.firstUserMessage,
                'cwd': t.cwd,
                'archived': t.archived,
                'updatedAtMs': t.updatedAtMs,
                'createdAtMs': t.createdAtMs,
                'tokensUsed': t.tokensUsed,
              })
          .toList(),
    };
  });

  bridge.register('/session/delete', (payload) async {
    final id = (payload['id'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw ArgumentError('missing id');
    }
    final backupPath = await actionRepo.deleteThread(id: id);
    return {'backupPath': backupPath};
  });

  bridge.register('/session/export', (payload) async {
    final id = (payload['id'] as String?)?.trim();
    final format = (payload['format'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw ArgumentError('missing id');
    }
    if (format == null || format.isEmpty) {
      throw ArgumentError('missing format');
    }

    final detail = await queryRepo.loadThreadDetail(id: id);
    final outputPath = await actionRepo.pickAndExport(
      detail: detail,
      format: format,
      dialogTitle: 'Export conversation',
    );
    if (outputPath == null) {
      return {'ok': false, 'cancelled': true};
    }
    AppLogService.instance.info(
      'CodexExport',
      '已导出会话',
      details: 'id=$id format=$format path=$outputPath',
    );
    return {'ok': true, 'path': outputPath, 'format': format};
  });

  bridge.register('/session/export-bundle', (payload) async {
    final cwd = (payload['cwd'] as String?)?.trim();
    final format = (payload['format'] as String?)?.trim();
    if (cwd == null || cwd.isEmpty) {
      throw ArgumentError('missing cwd');
    }
    if (format == null || format.isEmpty) {
      throw ArgumentError('missing format');
    }

    final threads = await queryRepo.listThreadsByCwd(cwd: cwd);
    if (threads.isEmpty) {
      return {'ok': false, 'reason': 'empty', 'count': 0};
    }

    // 先全部 loadDetail,再交给 repo 弹框 + 打包。loadDetail 失败的单条跳过。
    final details = [];
    var preFailed = 0;
    for (final t in threads) {
      final id = (t['id'] as String?) ?? '';
      if (id.isEmpty) continue;
      try {
        details.add(await queryRepo.loadThreadDetail(id: id));
      } catch (err) {
        preFailed += 1;
        AppLogService.instance.warning(
          'CodexExport',
          '批量导出: 单条加载失败',
          details: 'id=$id err=$err',
        );
      }
    }

    final result = await actionRepo.pickAndExportBundle(
      details: details.cast(),
      format: format,
      defaultBundleFileName: defaultBundleName(cwd, format),
      dialogTitle: 'Export project conversations',
    );
    if (result.path == null) {
      return {'ok': false, 'cancelled': true};
    }
    final failed = result.failed + preFailed;
    if (result.ok == 0) {
      return {'ok': false, 'reason': 'all-failed', 'count': 0, 'failed': failed};
    }

    AppLogService.instance.info(
      'CodexExport',
      '已导出项目',
      details:
          'cwd=$cwd format=$format count=${result.ok} failed=$failed path=${result.path}',
    );
    return {
      'ok': true,
      'path': result.path,
      'format': format,
      'count': result.ok,
      'failed': failed,
    };
  });

  bridge.register('/session/import', (payload) async {
    final targetCwd = (payload['targetCwd'] as String?)?.trim();
    try {
      final result = await actionRepo.importSingle(targetCwd: targetCwd);
      if (result == null) {
        return {'ok': false, 'cancelled': true};
      }
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
    try {
      final result = await actionRepo.importBundle(targetCwd: targetCwd);
      if (result == null) {
        return {'ok': false, 'cancelled': true};
      }
      if (result.ok == 0 && result.imported.isEmpty && result.failed == 0) {
        return {'ok': false, 'reason': 'no-jsonl-in-zip', 'count': 0};
      }
      AppLogService.instance.info(
        'CodexImport',
        '已导入项目',
        details:
            'count=${result.ok} failed=${result.failed} targetCwd=$targetCwd',
      );
      return {
        'ok': result.ok > 0,
        'count': result.ok,
        'failed': result.failed,
        'imported': result.imported,
      };
    } catch (err, st) {
      AppLogService.instance.error(
        'CodexImport',
        '批量导入失败',
        details: '$err\n$st',
      );
      return {'ok': false, 'reason': 'bad-zip-or-other', 'message': '$err'};
    }
  });

  return true;
}

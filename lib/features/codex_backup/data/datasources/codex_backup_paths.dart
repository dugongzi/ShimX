import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// codex 会话备份的目录布局:
///
///   `<AppSupport>/codex_session_backups/`
///   └── `<backupId 时间戳>/`
///       ├── manifest.json     元信息
///       ├── sqliteRows.json   threads 原始行(sqlite 那条被删也能兜底)
///       └── sessions/         每条会话的 rollout jsonl 拷贝
///
/// backupId 用 `yyyyMMddTHHmmssSSS` 便于按时间排序,且文件系统安全。
class CodexBackupPaths {
  const CodexBackupPaths._();

  static Future<Directory> rootDir() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'codex_session_backups'));
  }

  static Future<Directory> ensureRoot() async {
    final dir = await rootDir();
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static String manifestFilename() => 'manifest.json';

  static String sqliteRowsFilename() => 'sqliteRows.json';

  static String sessionsSubdir() => 'sessions';

  /// 生成一个新的 backupId(基于当前时间)。返回值只保证格式合法,不保证唯一,
  /// datasource 层如果撞名会自增后缀。
  static String newBackupId(DateTime now) {
    final ts = now.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return '${ts.year}${two(ts.month)}${two(ts.day)}'
        'T${two(ts.hour)}${two(ts.minute)}${two(ts.second)}'
        '${three(ts.millisecond)}';
  }
}

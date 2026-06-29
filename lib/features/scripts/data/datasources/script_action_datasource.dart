import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shim/core/services/app_storage.dart';

/// 脚本写操作 IO:
///   - 文件选择器拾取 .js → 拷贝到 `<appSupport>/scripts/`
///   - 删除单文件 + 清持久化键
///   - 批量切换启用持久化键
///
/// 启用键格式 `script_enabled:<filename.js>`,与 [ScriptQueryDatasource] 共享。
class ScriptActionDatasource {
  ScriptActionDatasource({required AppStorage appStorage})
      : _appStorage = appStorage;

  final AppStorage _appStorage;

  static String _enabledKey(String id) => 'script_enabled:$id';

  /// 弹文件选择器(单文件 .js)→ 拷贝到脚本目录。用户取消返回 null。
  /// 目标已存在同名时附 `-2/-3/...` 后缀避免覆盖。返回最终落盘文件名(id)。
  Future<String?> importScript() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['js'],
    );
    if (picked == null || picked.files.isEmpty) return null;
    final source = picked.files.single.path;
    if (source == null) return null;
    final dir = await _scriptsDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final originalName = p.basename(source);
    final targetName = await _uniqueTargetName(dir, originalName);
    await File(source).copy(p.join(dir.path, targetName));
    return targetName;
  }

  Future<String> _uniqueTargetName(Directory dir, String originalName) async {
    final ext = p.extension(originalName); // 含点
    final stem = p.basenameWithoutExtension(originalName);
    var candidate = originalName;
    var i = 2;
    while (await File(p.join(dir.path, candidate)).exists()) {
      candidate = '$stem-$i$ext';
      i += 1;
    }
    return candidate;
  }

  Future<void> deleteScript({required String id}) async {
    final dir = await _scriptsDir();
    final file = File(p.join(dir.path, id));
    if (await file.exists()) {
      await file.delete();
    }
    await _appStorage.remove(_enabledKey(id));
  }

  Future<void> setEnabled({
    required Iterable<String> ids,
    required bool enabled,
  }) async {
    for (final id in ids) {
      await _appStorage.setBool(_enabledKey(id), enabled);
    }
  }

  Future<Directory> _scriptsDir() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'scripts'));
  }
}

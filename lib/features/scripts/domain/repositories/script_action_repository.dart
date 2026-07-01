/// 脚本写操作:导入 .js 到本地脚本目录、删除单条、批量启停。
abstract class ScriptActionRepository {
  /// 弹文件选择器选 .js 文件,拷贝到脚本目录。
  /// 用户取消返回 null;成功返回写入后的文件名(id)。同名时自动加 `-2/-3` 后缀。
  Future<String?> importScript();

  /// 删除某条脚本文件 + 清掉它的 enabled 持久化键。
  Future<void> deleteScript({required String id});

  /// 批量设置启用状态。仅写持久化,不触发 codex 注入。
  Future<void> setEnabled({
    required Iterable<String> ids,
    required bool enabled,
  });

  /// 覆盖写入脚本代码。文件不存在返回 false。下次注入时生效。
  Future<bool> saveScript({required String id, required String code});

  /// 创建新脚本文件,写入初始代码。返回最终文件名(id)。
  Future<String> createScript({required String name, required String code});

  /// 编辑器 Run 时是否同时刷新 Codex 页面。
  Future<void> setReloadOnRun({required bool value});

  /// 手动保存后是否自动 Run。
  Future<void> setHotRun({required bool value});
}

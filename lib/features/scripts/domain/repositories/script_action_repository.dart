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
}

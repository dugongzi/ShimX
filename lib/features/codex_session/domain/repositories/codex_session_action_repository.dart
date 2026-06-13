abstract class CodexSessionActionRepository {
  /// 删除会话，返回备份文件路径
  Future<String> deleteThread({required String id});
}

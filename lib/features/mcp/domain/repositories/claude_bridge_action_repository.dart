/// Claude 跨进程桥的写端:bind / unbind 单条 codex thread → Claude 会话的绑定。
abstract class ClaudeBridgeActionRepository {
  /// 绑定一条 Claude 会话作为该 codex thread 的接续上下文,会同步落盘。
  /// 返回新的状态 payload(与 query 的 [statePayload] 同形)。
  Future<Map<String, dynamic>> bind({
    required String codexThreadId,
    required String sessionId,
    required String jsonlPath,
    String? title,
  });

  /// 解除绑定,会同步落盘。返回 bound:false 状态 payload。
  Future<Map<String, dynamic>> unbind({required String codexThreadId});
}

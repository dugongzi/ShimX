/// Claude 跨进程桥的读端:codex thread → Claude 会话绑定状态。
abstract class ClaudeBridgeQueryRepository {
  /// 第一次使用前从持久化拉一次,后续走内存。多次调用幂等(只跑一次)。
  /// 注入流程必须先 await 这个再启动 codex,否则首条 thread 拿到的是空状态。
  Future<void> ensureHydrated();

  /// 读某个 codex thread 的当前绑定。
  /// 返回 bridge payload:`{bound: bool, codexThreadId?, sessionId?, jsonlPath?, title?}`。
  Map<String, dynamic> statePayload(String codexThreadId);

  /// 读全部绑定快照。返回 `{bindings: [{codexThreadId, sessionId, jsonlPath, title?}, ...]}`。
  Map<String, dynamic> bindingsPayload();
}

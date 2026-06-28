abstract class InjectQueryRepository {
  /// 端口是否已有 CDP 服务监听
  Future<bool> isDebugPortAlive({required int debugPort});

  /// 在 page target 上找出 devtools 前端 URL
  Future<String?> findDevtoolsUrl({required int debugPort});

  /// 轮询直到端口出现可注入 page
  Future<void> waitForDebugPort({required int debugPort});

  /// 加载注入脚本(debug 模式优先读外部文件,否则读 asset)
  Future<String> loadInjectScript();
}

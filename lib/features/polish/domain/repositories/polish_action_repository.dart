abstract class PolishActionRepository {
  /// 走 shim 本地代理拿到润色文本。
  Future<String> polish({
    required String text,
    required String instruction,
  });
}

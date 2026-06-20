/// 按模型 id 推断模型家族，给 AutoSwitchSettings.scope=same-type 的候选过滤用。
///
/// 返回值字符串集合（同 upstreamProtocol 用字符串而非 enum 的风格）：
///   openai    ── gpt / o1 / o3 / codex 系
///   claude    ── claude 系
///   gemini    ── gemini 系
///   image     ── dall-e / image / gpt-image 系
///   unknown   ── 没传 / 空字符串
///   other     ── 不在上述里
String modelFamily(String? model) {
  if (model == null || model.isEmpty) return 'unknown';
  final lower = model.toLowerCase();
  if (lower.contains('image') || lower.contains('dall-e') || lower.contains('dalle')) {
    return 'image';
  }
  if (lower.startsWith('claude')) return 'claude';
  if (lower.startsWith('gemini')) return 'gemini';
  if (lower.contains('gpt') ||
      lower.startsWith('o1') ||
      lower.startsWith('o3') ||
      lower.startsWith('codex')) {
    return 'openai';
  }
  return 'other';
}

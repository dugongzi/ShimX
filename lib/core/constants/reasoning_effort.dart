/// codex thinking depth 的允许取值,与 codex 自己接受的字符串保持一致。
const List<String> reasoningEffortValues = ['low', 'medium', 'high', 'xhigh'];

/// 默认值。/provider/list 返回时如果 storage 里没存,就用这个。
const String defaultReasoningEffort = 'high';

bool isSupportedReasoningEffort(String? effort) {
  return effort != null && reasoningEffortValues.contains(effort);
}

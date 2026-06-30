import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 紧凑搜索框:左侧搜索图标 + 右侧清除按钮(有内容时显示)。
/// 高度 36,适合放在列表面板顶部。
/// 每次输入立即触发 onChanged(1 字符即激活过滤)。
class SearchField extends HookWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initial,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initial ?? '');
    final hasText = useState(controller.text.isNotEmpty);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (value) {
          hasText.value = value.isNotEmpty;
          onChanged(value);
        },
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.42),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: Icon(
              Icons.search_rounded,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          suffixIcon: hasText.value
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    hasText.value = false;
                    onChanged('');
                  },
                  iconSize: 14,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

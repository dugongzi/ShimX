import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:shim/features/scripts/presentation/widgets/script_list_item.dart';

/// 脚本列表主体:加载态 / 空态 / 列表三态切换。
/// 由 [ScriptList] 外壳传入当前页数据 + 选中集合。
class ScriptListBody extends StatelessWidget {
  const ScriptListBody({
    super.key,
    required this.scriptsAsync,
    required this.pageItems,
    required this.selected,
  });

  final AsyncValue<List<InjectScript>> scriptsAsync;
  final List<InjectScript> pageItems;
  final ValueNotifier<Set<String>> selected;

  @override
  Widget build(BuildContext context) {
    if (scriptsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (scriptsAsync.hasError) {
      return Center(child: Text(scriptsAsync.error.toString()));
    }
    if (pageItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSizes.itemGap),
            Text(
              context.l10n.noScripts,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: pageItems.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.itemGap),
      itemBuilder: (context, index) {
        final script = pageItems[index];
        final isSelected = selected.value.contains(script.id);
        return ScriptListItem(
          script: script,
          selected: isSelected,
          onSelectedChanged: (checked) {
            final next = {...selected.value};
            if (checked) {
              next.add(script.id);
            } else {
              next.remove(script.id);
            }
            selected.value = next;
          },
        );
      },
    );
  }
}

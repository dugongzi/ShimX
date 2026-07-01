import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/scripts/presentation/providers/script_query_provider.dart';
import 'package:shim/features/scripts/presentation/widgets/script_editor_shell.dart';

/// 脚本编辑器页面(VSCode 布局):
///   左侧 = 脚本列表(点击切换) + 新建入口(先弹名字对话框)
///   中央 = re_editor
///   顶部 = 运行按钮 / 保存按钮 / 关闭
///
/// 路由参数 [scriptId]:
///   - null → 打开后进入"没选中任何脚本"的空状态
///   - 非空 → 打开时选中该脚本
class ScriptEditorPage extends HookConsumerWidget {
  const ScriptEditorPage({super.key, this.scriptId});

  final String? scriptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scriptsAsync = ref.watch(scriptsProvider);
    return Scaffold(
      backgroundColor: context.isDark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFFFFFFF),
      body: scriptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(e.toString()),
          ),
        ),
        data: (scripts) => ScriptEditorShell(
          scripts: scripts,
          initialScriptId: scriptId,
        ),
      ),
    );
  }
}

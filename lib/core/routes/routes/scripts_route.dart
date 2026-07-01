import 'package:go_router/go_router.dart';
import 'package:shim/features/scripts/presentation/pages/script_editor_page.dart';

class ScriptsRoute {
  ScriptsRoute._();

  /// 新建脚本编辑器
  static const editorNew = '/scripts/editor/new';

  /// 编辑现有脚本(尾部 id 通过路径参数传入)
  static const editor = '/scripts/editor/:id';

  static String toEditor(String id) => '/scripts/editor/${Uri.encodeComponent(id)}';

  static String toEditorNew() => editorNew;
}

final scriptsRoutes = <GoRoute>[
  GoRoute(
    path: ScriptsRoute.editorNew,
    builder: (context, state) => const ScriptEditorPage(),
  ),
  GoRoute(
    path: ScriptsRoute.editor,
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return ScriptEditorPage(scriptId: id);
    },
  ),
];

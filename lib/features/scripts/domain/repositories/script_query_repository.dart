import 'package:shimx/features/scripts/domain/models/inject_script.dart';

abstract class ScriptQueryRepository {
  /// 列出用户脚本目录下所有脚本
  Future<List<InjectScript>> listScripts();

  /// 单个脚本启用状态（默认 false）
  Future<bool> isScriptEnabled({required String id});

  /// 编辑器 Run 时是否同时刷新 Codex(默认 true)
  Future<bool> isReloadOnRun();

  /// 手动保存后是否自动 Run(默认 false)
  Future<bool> isHotRun();
}

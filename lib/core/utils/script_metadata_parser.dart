import 'package:shimx/features/scripts/domain/models/script_metadata.dart';

/// 解析 userscript 风格注释头：
///
/// ```
/// // ==ShimX==
/// // @name        xxx
/// // @description xxx
/// // @version     1.0.0
/// // @author      xxx
/// // ==/ShimX==
/// ```
///
/// 没有头部则返回 null，由调用方用文件名 fallback。
ScriptMetadata? parseScriptMetadata(String code) {
  final lines = code.split('\n');
  var inBlock = false;
  final fields = <String, String>{};

  for (final raw in lines) {
    final line = raw.trim();
    if (!inBlock) {
      if (line == '// ==ShimX==') inBlock = true;
      continue;
    }
    if (line == '// ==/ShimX==') break;
    final match = _fieldPattern.firstMatch(line);
    if (match == null) continue;
    fields[match.group(1)!.toLowerCase()] = match.group(2)!.trim();
  }

  if (!inBlock || fields.isEmpty) return null;
  final name = fields['name'];
  if (name == null || name.isEmpty) return null;

  return ScriptMetadata(
    name: name,
    description: fields['description'] ?? '',
    version: fields['version'] ?? '',
    author: fields['author'] ?? '',
  );
}

final _fieldPattern = RegExp(r'^//\s*@(\w+)\s+(.+)$');

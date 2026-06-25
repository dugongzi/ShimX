import 'package:toml/toml.dart';

const shimManagedStartPrefix = '# shim-managed:start';
const shimManagedEnd = '# shim-managed:end';
const codexToolTableNames = ['mcp_servers', 'skills'];
const codexToolKindMcpServer = 'mcpServer';
const codexToolKindSkill = 'skill';

final _managedStartPattern = RegExp(
  r'^\s*#\s*shim-managed:start\s+kind=(mcp_servers|skills)\s+id=([A-Za-z0-9_-]+)\s*$',
);
final _tableHeaderPattern = RegExp(r'^\s*\[([^\]]+)\]\s*$');

class CodexToolTomlFragment {
  const CodexToolTomlFragment({
    required this.id,
    required this.kind,
    required this.bodyText,
    required this.enabled,
    required this.managedByShim,
    required this.readOnly,
    required this.name,
    required this.description,
  });

  final String id;
  final String kind;
  final String bodyText;
  final bool enabled;
  final bool managedByShim;
  final bool readOnly;
  final String name;
  final String description;
}

List<CodexToolTomlFragment> parseCodexTools(
  String text, {
  String excludedMcpId = '',
}) {
  final lines = text.split('\n');
  final managedRanges = <_LineRange>[];
  final tools = <CodexToolTomlFragment>[];

  for (var i = 0; i < lines.length; i++) {
    final startMatch = _managedStartPattern.firstMatch(lines[i]);
    if (startMatch == null) continue;
    final end = _findManagedEnd(lines, i + 1);
    if (end == null) continue;

    final tableName = startMatch.group(1)!;
    final id = startMatch.group(2)!;
    if (!_isExcluded(tableName, id, excludedMcpId)) {
      final bodyText = _bodyTextFromManagedBlock(
        lines.sublist(i + 1, end),
        tableName: tableName,
        id: id,
      );
      tools.add(
        _fragmentFromBody(
          id: id,
          kind: _kindFromTableName(tableName),
          bodyText: bodyText,
          managedByShim: true,
        ),
      );
    }
    managedRanges.add(_LineRange(i, end));
    i = end;
  }

  for (var i = 0; i < lines.length; i++) {
    if (_lineInAnyRange(i, managedRanges)) continue;
    final path = tablePathFromLine(lines[i]);
    if (path == null || path.length < 2) continue;
    final tableName = path[0];
    if (!codexToolTableNames.contains(tableName)) continue;
    final id = path[1];
    if (_isExcluded(tableName, id, excludedMcpId)) continue;
    final end = _findTableEnd(lines, i + 1, tableName: tableName, id: id);
    final bodyText = lines.sublist(i + 1, end).join('\n').trimRight();
    tools.add(
      _fragmentFromBody(
        id: id,
        kind: _kindFromTableName(tableName),
        bodyText: bodyText,
        managedByShim: false,
      ),
    );
    i = end - 1;
  }

  final byKey = <String, CodexToolTomlFragment>{};
  for (final tool in tools) {
    byKey['${tool.kind}:${tool.id}'] = tool;
  }
  final result = byKey.values.toList();
  result.sort((a, b) {
    final kindCompare = a.kind.compareTo(b.kind);
    if (kindCompare != 0) return kindCompare;
    return a.id.compareTo(b.id);
  });
  return result;
}

String upsertShimManagedCodexToolBlock(
  String text, {
  required String kind,
  required String id,
  required String bodyText,
}) {
  validateCodexToolId(id);
  validateCodexToolBody(bodyText);
  final tableName = _tableNameFromKind(kind);
  final existingManaged = _findManagedBlock(text, tableName: tableName, id: id);
  final managedBlock = _renderManagedBlock(
    tableName: tableName,
    id: id,
    bodyText: bodyText,
  );
  if (existingManaged != null) {
    return _replaceManagedBlock(
      text,
      existingManaged.startOffset,
      existingManaged.endOffset,
      managedBlock,
    );
  }

  final existingPlain = _findPlainBlock(text, tableName: tableName, id: id);
  if (existingPlain != null) {
    return _replaceManagedBlock(
      text,
      existingPlain.startOffset,
      existingPlain.endOffset,
      _renderPlainBlock(tableName: tableName, id: id, bodyText: bodyText),
    );
  }
  return _appendManagedBlock(text, managedBlock);
}

String deleteShimManagedCodexToolBlock(
  String text, {
  required String kind,
  required String id,
}) {
  validateCodexToolId(id);
  final tableName = _tableNameFromKind(kind);
  final existing =
      _findManagedBlock(text, tableName: tableName, id: id) ??
      _findPlainBlock(text, tableName: tableName, id: id);
  if (existing == null) {
    throw StateError('未找到配置片段: $id');
  }
  final next = _removeManagedBlock(
    text,
    existing.startOffset,
    existing.endOffset,
  );
  return next.trim().isEmpty ? '' : next;
}

String setShimManagedCodexToolEnabled(
  String text, {
  required String kind,
  required String id,
  required bool enabled,
}) {
  final tableName = _tableNameFromKind(kind);
  final existingManaged = _findManagedBlock(text, tableName: tableName, id: id);
  if (existingManaged != null) {
    final bodyText = setEnabledInCodexToolBody(
      existingManaged.bodyText,
      enabled,
    );
    return upsertShimManagedCodexToolBlock(
      text,
      kind: kind,
      id: id,
      bodyText: bodyText,
    );
  }

  final existingPlain = _findPlainBlock(text, tableName: tableName, id: id);
  final existing = existingPlain;
  if (existing == null) {
    throw StateError('未找到配置片段: $id');
  }
  final bodyText = setEnabledInCodexToolBody(existing.bodyText, enabled);
  return _replaceManagedBlock(
    text,
    existing.startOffset,
    existing.endOffset,
    _renderPlainBlock(tableName: tableName, id: id, bodyText: bodyText),
  );
}

void validateCodexToolId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('ID 不能为空');
  }
  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(trimmed)) {
    throw ArgumentError('ID 只能包含字母、数字、下划线和短横线');
  }
}

void validateCodexToolBody(String bodyText) {
  final trimmed = bodyText.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('配置片段不能为空');
  }
  final body = TomlDocument.parse(trimmed).toMap();
  for (final tableName in codexToolTableNames) {
    if (body.containsKey(tableName)) {
      throw ArgumentError('这里填写片段字段,不要写 [$tableName.<id>] 表头');
    }
  }
}

List<String>? tablePathFromLine(String line) {
  final match = _tableHeaderPattern.firstMatch(line);
  if (match == null) return null;
  return _parseDottedPath(match.group(1)!.trim());
}

String setEnabledInCodexToolBody(String bodyText, bool enabled) {
  final lines = bodyText.trimRight().split('\n');
  final nextValue = 'enabled = ${enabled ? 'true' : 'false'}';
  var replaced = false;
  final next = lines.map((line) {
    if (RegExp(r'^\s*enabled\s*=').hasMatch(line)) {
      replaced = true;
      return nextValue;
    }
    return line;
  }).toList();
  if (!replaced) next.insert(0, nextValue);
  return next.join('\n').trimRight();
}

CodexToolTomlFragment _fragmentFromBody({
  required String id,
  required String kind,
  required String bodyText,
  required bool managedByShim,
}) {
  return CodexToolTomlFragment(
    id: id,
    kind: kind,
    bodyText: bodyText,
    enabled: _bodyEnabled(bodyText),
    managedByShim: managedByShim,
    readOnly: false,
    name: _bodyName(id, bodyText),
    description: _bodyDescription(bodyText),
  );
}

String _tableNameFromKind(String kind) {
  return switch (kind) {
    codexToolKindMcpServer => 'mcp_servers',
    codexToolKindSkill => 'skills',
    _ => throw ArgumentError('Unsupported Codex tool kind: $kind'),
  };
}

String _kindFromTableName(String tableName) {
  return switch (tableName) {
    'mcp_servers' => codexToolKindMcpServer,
    'skills' => codexToolKindSkill,
    _ => throw ArgumentError('Unsupported Codex tool table: $tableName'),
  };
}

bool _bodyEnabled(String bodyText) {
  for (final line in bodyText.split('\n')) {
    if (RegExp(
      r'^\s*enabled\s*=\s*false\s*(#.*)?$',
      caseSensitive: false,
    ).hasMatch(line)) {
      return false;
    }
    if (RegExp(
      r'^\s*disabled\s*=\s*true\s*(#.*)?$',
      caseSensitive: false,
    ).hasMatch(line)) {
      return false;
    }
  }
  return true;
}

String _bodyName(String id, String bodyText) {
  final match = RegExp(
    r'^\s*name\s*=\s*"([^"]+)"\s*$',
    multiLine: true,
  ).firstMatch(bodyText);
  return match?.group(1)?.trim().isNotEmpty == true
      ? match!.group(1)!.trim()
      : id;
}

String _bodyDescription(String bodyText) {
  final description = RegExp(
    r'^\s*description\s*=\s*"([^"]+)"\s*$',
    multiLine: true,
  ).firstMatch(bodyText);
  if (description?.group(1)?.trim().isNotEmpty == true) {
    return description!.group(1)!.trim();
  }
  return bodyText
      .split('\n')
      .map((line) => line.trim())
      .firstWhere(
        (line) =>
            line.isNotEmpty &&
            !line.startsWith('#') &&
            !line.startsWith('enabled') &&
            !line.startsWith('disabled'),
        orElse: () => '',
      );
}

String _bodyTextFromManagedBlock(
  List<String> blockLines, {
  required String tableName,
  required String id,
}) {
  if (blockLines.isEmpty) return '';
  final firstPath = tablePathFromLine(blockLines.first);
  if (firstPath != null &&
      firstPath.length >= 2 &&
      firstPath[0] == tableName &&
      firstPath[1] == id) {
    return blockLines.sublist(1).join('\n').trimRight();
  }
  return blockLines.join('\n').trimRight();
}

int? _findManagedEnd(List<String> lines, int start) {
  for (var i = start; i < lines.length; i++) {
    if (lines[i].trim() == shimManagedEnd) return i;
  }
  return null;
}

int _findTableEnd(
  List<String> lines,
  int start, {
  required String tableName,
  required String id,
}) {
  for (var i = start; i < lines.length; i++) {
    if (_managedStartPattern.hasMatch(lines[i])) return i;
    final path = tablePathFromLine(lines[i]);
    if (path == null) continue;
    final isChild = path.length > 2 && path[0] == tableName && path[1] == id;
    if (!isChild) return i;
  }
  return lines.length;
}

bool _isExcluded(String tableName, String id, String excludedMcpId) {
  return tableName == 'mcp_servers' &&
      excludedMcpId.isNotEmpty &&
      id == excludedMcpId;
}

bool _lineInAnyRange(int line, List<_LineRange> ranges) {
  return ranges.any((range) => line >= range.start && line <= range.end);
}

String _renderManagedBlock({
  required String tableName,
  required String id,
  required String bodyText,
}) {
  final body = bodyText.trimRight();
  return [
    '$shimManagedStartPrefix kind=$tableName id=$id',
    '[$tableName.${_tomlKey(id)}]',
    body,
    shimManagedEnd,
  ].join('\n');
}

String _renderPlainBlock({
  required String tableName,
  required String id,
  required String bodyText,
}) {
  final body = bodyText.trimRight();
  return ['[$tableName.${_tomlKey(id)}]', body].join('\n');
}

_ManagedBlock? _findManagedBlock(
  String text, {
  required String tableName,
  required String id,
}) {
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final match = _managedStartPattern.firstMatch(line);
    if (match == null || match.group(1) != tableName || match.group(2) != id) {
      continue;
    }
    final endLine = _findManagedEnd(lines, i + 1);
    if (endLine == null) return null;
    final startOffset = _lineStartOffset(lines, i);
    final endOffset = _lineEndOffset(lines, endLine, text.length);
    final bodyText = _bodyTextFromManagedBlock(
      lines.sublist(i + 1, endLine),
      tableName: tableName,
      id: id,
    );
    return _ManagedBlock(startOffset, endOffset, bodyText);
  }
  return null;
}

_ManagedBlock? _findPlainBlock(
  String text, {
  required String tableName,
  required String id,
}) {
  final lines = text.split('\n');
  final managedRanges = <_LineRange>[];
  for (var i = 0; i < lines.length; i++) {
    final match = _managedStartPattern.firstMatch(lines[i]);
    if (match == null) continue;
    final end = _findManagedEnd(lines, i + 1);
    if (end == null) continue;
    managedRanges.add(_LineRange(i, end));
    i = end;
  }

  for (var i = 0; i < lines.length; i++) {
    if (_lineInAnyRange(i, managedRanges)) continue;
    final path = tablePathFromLine(lines[i]);
    if (path == null || path.length < 2) continue;
    if (path[0] != tableName || path[1] != id) continue;
    final end = _findTableEnd(lines, i + 1, tableName: tableName, id: id);
    final startOffset = _lineStartOffset(lines, i);
    final endOffset = end >= lines.length
        ? text.length
        : _lineStartOffset(lines, end);
    final bodyText = lines.sublist(i + 1, end).join('\n').trimRight();
    return _ManagedBlock(startOffset, endOffset, bodyText);
  }
  return null;
}

int _lineStartOffset(List<String> lines, int lineIndex) {
  var offset = 0;
  for (var i = 0; i < lineIndex; i++) {
    offset += lines[i].length + 1;
  }
  return offset;
}

int _lineEndOffset(List<String> lines, int lineIndex, int textLength) {
  var offset = _lineStartOffset(lines, lineIndex) + lines[lineIndex].length;
  if (offset < textLength) offset += 1;
  return offset;
}

String _appendManagedBlock(String text, String block) {
  if (text.isEmpty) return '$block\n';
  if (text.endsWith('\n\n')) return '$text$block\n';
  if (text.endsWith('\n')) return '$text\n$block\n';
  return '$text\n\n$block\n';
}

String _replaceManagedBlock(String text, int start, int end, String block) {
  return text.replaceRange(start, end, '$block\n');
}

String _removeManagedBlock(String text, int start, int end) {
  return text.replaceRange(start, end, '');
}

String _tomlKey(String key) {
  return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(key)
      ? key
      : '"${key.replaceAll('\\', r'\\').replaceAll('"', r'\"')}"';
}

List<String>? _parseDottedPath(String path) {
  final parts = <String>[];
  final buffer = StringBuffer();
  String? quote;
  var escaping = false;

  for (final codeUnit in path.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    if (quote != null) {
      if (quote == '"' && escaping) {
        buffer.write(char);
        escaping = false;
      } else if (quote == '"' && char == '\\') {
        escaping = true;
      } else if (char == quote) {
        quote = null;
      } else {
        buffer.write(char);
      }
      continue;
    }

    if (char == '"' || char == "'") {
      quote = char;
      continue;
    }
    if (char == '.') {
      final part = buffer.toString().trim();
      if (part.isEmpty) return null;
      parts.add(part);
      buffer.clear();
      continue;
    }
    buffer.write(char);
  }

  if (quote != null || escaping) return null;
  final part = buffer.toString().trim();
  if (part.isEmpty) return null;
  parts.add(part);
  return parts;
}

class _LineRange {
  const _LineRange(this.start, this.end);

  final int start;
  final int end;
}

class _ManagedBlock {
  const _ManagedBlock(this.startOffset, this.endOffset, this.bodyText);

  final int startOffset;
  final int endOffset;
  final String bodyText;
}

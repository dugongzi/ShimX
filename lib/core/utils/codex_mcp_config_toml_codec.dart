import 'package:toml/toml.dart';

const shimManagedStartPrefix = '# shim-managed:start';
const shimManagedEnd = '# shim-managed:end';
const codexMcpConfigKindMcpServer = 'mcpServer';

final _managedStartPattern = RegExp(
  r'^\s*#\s*shim-managed:start\s+kind=mcp_servers\s+id=([A-Za-z0-9_-]+)\s*$',
);
final _tableHeaderPattern = RegExp(r'^\s*\[([^\]]+)\]\s*$');

class CodexMcpConfigTomlFragment {
  const CodexMcpConfigTomlFragment({
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

List<CodexMcpConfigTomlFragment> parseCodexMcpConfigs(
  String text, {
  String excludedMcpId = '',
}) {
  final lines = text.split('\n');
  final managedRanges = <_LineRange>[];
  final configs = <CodexMcpConfigTomlFragment>[];

  for (var i = 0; i < lines.length; i++) {
    final startMatch = _managedStartPattern.firstMatch(lines[i]);
    if (startMatch == null) continue;
    final end = _findManagedEnd(lines, i + 1);
    if (end == null) continue;

    final id = startMatch.group(1)!;
    if (!_isExcluded(id, excludedMcpId)) {
      final bodyText = _bodyTextFromManagedBlock(
        lines.sublist(i + 1, end),
        id: id,
      );
      configs.add(
        _fragmentFromBody(id: id, bodyText: bodyText, managedByShim: true),
      );
    }
    managedRanges.add(_LineRange(i, end));
    i = end;
  }

  for (var i = 0; i < lines.length; i++) {
    if (_lineInAnyRange(i, managedRanges)) continue;
    final path = tablePathFromLine(lines[i]);
    if (path == null || path.length < 2) continue;
    if (path[0] != 'mcp_servers') continue;
    final id = path[1];
    if (_isExcluded(id, excludedMcpId)) continue;
    final end = _findTableEnd(lines, i + 1, id: id);
    final bodyText = lines.sublist(i + 1, end).join('\n').trimRight();
    configs.add(
      _fragmentFromBody(id: id, bodyText: bodyText, managedByShim: false),
    );
    i = end - 1;
  }

  final byKey = <String, CodexMcpConfigTomlFragment>{};
  for (final config in configs) {
    byKey[config.id] = config;
  }
  final result = byKey.values.toList();
  result.sort((a, b) => a.id.compareTo(b.id));
  return result;
}

String upsertShimManagedCodexMcpConfigBlock(
  String text, {
  required String kind,
  required String id,
  required String bodyText,
}) {
  _validateMcpKind(kind);
  validateCodexMcpConfigId(id);
  validateCodexMcpConfigBody(bodyText);
  final existingManaged = _findManagedBlock(text, id: id);
  final managedBlock = _renderManagedBlock(id: id, bodyText: bodyText);
  if (existingManaged != null) {
    return _replaceManagedBlock(
      text,
      existingManaged.startOffset,
      existingManaged.endOffset,
      managedBlock,
    );
  }

  final existingPlain = _findPlainBlock(text, id: id);
  if (existingPlain != null) {
    return _replaceManagedBlock(
      text,
      existingPlain.startOffset,
      existingPlain.endOffset,
      _renderPlainBlock(id: id, bodyText: bodyText),
    );
  }
  return _appendManagedBlock(text, managedBlock);
}

String deleteShimManagedCodexMcpConfigBlock(
  String text, {
  required String kind,
  required String id,
}) {
  _validateMcpKind(kind);
  validateCodexMcpConfigId(id);
  final existing =
      _findManagedBlock(text, id: id) ?? _findPlainBlock(text, id: id);
  if (existing == null) {
    throw StateError('未找到 MCP 配置: $id');
  }
  final next = _removeManagedBlock(
    text,
    existing.startOffset,
    existing.endOffset,
  );
  return next.trim().isEmpty ? '' : next;
}

String setShimManagedCodexMcpConfigEnabled(
  String text, {
  required String kind,
  required String id,
  required bool enabled,
}) {
  _validateMcpKind(kind);
  final existingManaged = _findManagedBlock(text, id: id);
  if (existingManaged != null) {
    final bodyText = setEnabledInCodexMcpConfigBody(
      existingManaged.bodyText,
      enabled,
    );
    return upsertShimManagedCodexMcpConfigBlock(
      text,
      kind: kind,
      id: id,
      bodyText: bodyText,
    );
  }

  final existing = _findPlainBlock(text, id: id);
  if (existing == null) {
    throw StateError('未找到 MCP 配置: $id');
  }
  final bodyText = setEnabledInCodexMcpConfigBody(existing.bodyText, enabled);
  return _replaceManagedBlock(
    text,
    existing.startOffset,
    existing.endOffset,
    _renderPlainBlock(id: id, bodyText: bodyText),
  );
}

void validateCodexMcpConfigId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('ID 不能为空');
  }
  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(trimmed)) {
    throw ArgumentError('ID 只能包含字母、数字、下划线和短横线');
  }
}

void validateCodexMcpConfigBody(String bodyText) {
  final trimmed = bodyText.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('MCP 配置不能为空');
  }
  final body = TomlDocument.parse(trimmed).toMap();
  if (body.containsKey('mcp_servers')) {
    throw ArgumentError('这里填写 MCP 字段,不要写 [mcp_servers.<id>] 表头');
  }
}

List<String>? tablePathFromLine(String line) {
  final match = _tableHeaderPattern.firstMatch(line);
  if (match == null) return null;
  return _parseDottedPath(match.group(1)!.trim());
}

String setEnabledInCodexMcpConfigBody(String bodyText, bool enabled) {
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

CodexMcpConfigTomlFragment _fragmentFromBody({
  required String id,
  required String bodyText,
  required bool managedByShim,
}) {
  return CodexMcpConfigTomlFragment(
    id: id,
    kind: codexMcpConfigKindMcpServer,
    bodyText: bodyText,
    enabled: _bodyEnabled(bodyText),
    managedByShim: managedByShim,
    readOnly: false,
    name: _bodyName(id, bodyText),
    description: _bodyDescription(bodyText),
  );
}

void _validateMcpKind(String kind) {
  if (kind != codexMcpConfigKindMcpServer) {
    throw ArgumentError('Unsupported Codex MCP kind: $kind');
  }
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
  required String id,
}) {
  if (blockLines.isEmpty) return '';
  final firstPath = tablePathFromLine(blockLines.first);
  if (firstPath != null &&
      firstPath.length >= 2 &&
      firstPath[0] == 'mcp_servers' &&
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

int _findTableEnd(List<String> lines, int start, {required String id}) {
  for (var i = start; i < lines.length; i++) {
    if (_managedStartPattern.hasMatch(lines[i])) return i;
    final path = tablePathFromLine(lines[i]);
    if (path == null) continue;
    final isChild =
        path.length > 2 && path[0] == 'mcp_servers' && path[1] == id;
    if (!isChild) return i;
  }
  return lines.length;
}

bool _isExcluded(String id, String excludedMcpId) {
  return excludedMcpId.isNotEmpty && id == excludedMcpId;
}

bool _lineInAnyRange(int line, List<_LineRange> ranges) {
  return ranges.any((range) => line >= range.start && line <= range.end);
}

String _renderManagedBlock({required String id, required String bodyText}) {
  final body = bodyText.trimRight();
  return [
    '$shimManagedStartPrefix kind=mcp_servers id=$id',
    '[mcp_servers.${_tomlKey(id)}]',
    body,
    shimManagedEnd,
  ].join('\n');
}

String _renderPlainBlock({required String id, required String bodyText}) {
  final body = bodyText.trimRight();
  return ['[mcp_servers.${_tomlKey(id)}]', body].join('\n');
}

_ManagedBlock? _findManagedBlock(String text, {required String id}) {
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final match = _managedStartPattern.firstMatch(lines[i]);
    if (match == null || match.group(1) != id) continue;
    final endLine = _findManagedEnd(lines, i + 1);
    if (endLine == null) return null;
    final startOffset = _lineStartOffset(lines, i);
    final endOffset = _lineEndOffset(lines, endLine, text.length);
    final bodyText = _bodyTextFromManagedBlock(
      lines.sublist(i + 1, endLine),
      id: id,
    );
    return _ManagedBlock(startOffset, endOffset, bodyText);
  }
  return null;
}

_ManagedBlock? _findPlainBlock(String text, {required String id}) {
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
    if (path[0] != 'mcp_servers' || path[1] != id) continue;
    final end = _findTableEnd(lines, i + 1, id: id);
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

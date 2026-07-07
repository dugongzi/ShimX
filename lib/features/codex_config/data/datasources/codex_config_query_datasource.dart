import 'dart:io';

import 'package:toml/toml.dart';

import 'package:shimx/core/services/codex_paths.dart';

/// 只读:从 codex config.toml 里拿会话分桶相关的字段。
class CodexConfigQueryDatasource {
  const CodexConfigQueryDatasource();

  /// 读顶层 `model_provider` 字段。文件不存在或字段缺失返回 null。
  Future<String?> readModelProvider() async {
    final file = File(CodexPaths.configToml());
    if (!await file.exists()) return null;
    final raw = _stripBom(await file.readAsString());
    if (raw.trim().isEmpty) return null;
    try {
      final doc = TomlDocument.parse(raw).toMap();
      final v = doc['model_provider'];
      if (v is String) return v.trim();
      return null;
    } catch (_) {
      return null;
    }
  }

  String _stripBom(String s) => s.startsWith('﻿') ? s.substring(1) : s;
}

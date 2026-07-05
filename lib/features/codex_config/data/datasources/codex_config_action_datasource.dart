import 'dart:io';

import 'package:toml/toml.dart';

import 'package:shim/core/services/codex_paths.dart';

/// 只写:改 codex config.toml 里跟会话分桶相关的字段。
///
/// 增量修改,保留用户其它段。
class CodexConfigActionDatasource {
  const CodexConfigActionDatasource();

  /// shim 塞的 provider 段身上打这个标记 —— 方便下次切桶时识别"这段是我塞的,
  /// 可以直接改键名",而不是留下垃圾多塞一段。
  static const _managedMarkerKey = 'managed_by';
  static const _managedMarkerValue = 'shim';

  /// 覆盖顶层 `model_provider`。文件不存在则新建。
  ///
  /// 若给出 [ensureBaseUrl],保证 `[model_providers.<value>]` 段存在:
  ///   - 已有同名段(不管是不是 shim 塞的): 不动
  ///   - shim 已经塞过别的段(带 managed_by 标记): 改键名成 value,内容不动
  ///   - 完全没有: 新塞一段并打上 managed_by 标记
  /// 目的是切多个桶时 config 里只留一段 shim 塞的 provider 定义。
  Future<void> writeModelProvider(
    String value, {
    String? ensureBaseUrl,
  }) async {
    final file = File(CodexPaths.configToml());
    Map<String, dynamic> doc;
    if (await file.exists()) {
      final raw = _stripBom(await file.readAsString());
      if (raw.trim().isEmpty) {
        doc = <String, dynamic>{};
      } else {
        try {
          doc = Map<String, dynamic>.from(TomlDocument.parse(raw).toMap());
        } catch (_) {
          doc = <String, dynamic>{};
        }
      }
    } else {
      doc = <String, dynamic>{};
    }
    doc['model_provider'] = value;

    if (ensureBaseUrl != null) {
      final providers = doc['model_providers'] is Map
          ? Map<String, dynamic>.from(doc['model_providers'] as Map)
          : <String, dynamic>{};

      if (providers[value] is Map) {
        // 目标段已存在(用户手工的或 shim 之前塞过同名的): 不动
      } else {
        // 找一段"shim 之前塞的、当前 config 里已经不是目标桶名"的段,
        // 把它改名成 value,内容保留。这样切桶时 shim 塞的段永远只有一个。
        String? renameFrom;
        for (final entry in providers.entries) {
          final v = entry.value;
          if (v is Map && v[_managedMarkerKey] == _managedMarkerValue) {
            renameFrom = entry.key;
            break;
          }
        }
        if (renameFrom != null) {
          final section = Map<String, dynamic>.from(providers[renameFrom] as Map);
          providers.remove(renameFrom);
          // name 字段跟段名同步更新, 其它字段原封不动
          section['name'] = value;
          providers[value] = section;
        } else {
          // shim 从没塞过段, 首次塞一段并打上 managed_by 标记
          providers[value] = <String, dynamic>{
            'name': value,
            'wire_api': 'responses',
            'base_url': ensureBaseUrl,
            _managedMarkerKey: _managedMarkerValue,
          };
        }
        doc['model_providers'] = providers;
      }
    }

    final rendered = TomlDocument.fromMap(doc).toString();
    final normalized = rendered.endsWith('\n') ? rendered : '$rendered\n';
    await file.parent.create(recursive: true);
    await file.writeAsString(normalized);
  }

  String _stripBom(String s) => s.startsWith('﻿') ? s.substring(1) : s;
}

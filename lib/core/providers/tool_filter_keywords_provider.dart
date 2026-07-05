import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/providers/locale_provider.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';

part 'tool_filter_keywords_provider.g.dart';

class ToolFilterKeyword {
  const ToolFilterKeyword({required this.keyword, required this.enabled});

  final String keyword;
  final bool enabled;

  ToolFilterKeyword copyWith({bool? enabled}) {
    return ToolFilterKeyword(
      keyword: keyword,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, Object?> toJson() => {'keyword': keyword, 'enabled': enabled};

  static ToolFilterKeyword? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final kw = raw['keyword'];
    if (kw is! String) return null;
    final trimmed = kw.trim();
    if (trimmed.isEmpty) return null;
    final enabled = raw['enabled'];
    return ToolFilterKeyword(
      keyword: trimmed,
      enabled: enabled is bool ? enabled : true,
    );
  }
}

/// 请求 body tools 数组过滤关键词。
///
/// 命中判定:tools 里每一项的 `type` 或 `name` 若等于列表中任何一个 **enabled** 关键词,
/// 就会在转发前被剔除。disabled 的关键词保留在列表里但不参与过滤。
///
/// 默认包含 enabled 的 `image_generation`,因为 codex app-server(VSCode 插件、桌面 App)
/// 识别到官方 ChatGPT 登录态时会无条件把它塞进 tools,让不支持图片生成的中转站
/// 直接 403 Forbidden。参考 openai/codex#21952。
@Riverpod(keepAlive: true)
class ToolFilterKeywordsNotifier extends _$ToolFilterKeywordsNotifier {
  static const _storageKey = 'toolFilterKeywords';
  static const _defaultKeywords = <ToolFilterKeyword>[
    ToolFilterKeyword(keyword: 'image_generation', enabled: true),
  ];

  @override
  List<ToolFilterKeyword> build() {
    Future.microtask(_load);
    return _defaultKeywords;
  }

  Future<void> _load() async {
    final storage = ref.read(appStorageProvider);
    final raw = await storage.getString(_storageKey);
    if (raw == null) {
      _pushToProxy(_defaultKeywords);
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final list = decoded
            .map(ToolFilterKeyword.fromJson)
            .whereType<ToolFilterKeyword>()
            .toList();
        state = list;
        _pushToProxy(list);
        return;
      }
    } catch (_) {
      // 落坏了当没读到,回默认。
    }
    _pushToProxy(_defaultKeywords);
  }

  Future<void> add(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    if (state.any((k) => k.keyword == trimmed)) return;
    final next = [
      ...state,
      ToolFilterKeyword(keyword: trimmed, enabled: true),
    ];
    state = next;
    await _persist(next);
    _pushToProxy(next);
  }

  Future<void> remove(String keyword) async {
    if (!state.any((k) => k.keyword == keyword)) return;
    final next = state.where((k) => k.keyword != keyword).toList();
    state = next;
    await _persist(next);
    _pushToProxy(next);
  }

  Future<void> setEnabled(String keyword, bool enabled) async {
    final idx = state.indexWhere((k) => k.keyword == keyword);
    if (idx < 0) return;
    if (state[idx].enabled == enabled) return;
    final next = [...state];
    next[idx] = next[idx].copyWith(enabled: enabled);
    state = next;
    await _persist(next);
    _pushToProxy(next);
  }

  Future<void> _persist(List<ToolFilterKeyword> list) async {
    final storage = ref.read(appStorageProvider);
    await storage.setString(
      _storageKey,
      jsonEncode(list.map((k) => k.toJson()).toList()),
    );
  }

  void _pushToProxy(List<ToolFilterKeyword> list) {
    final active = list.where((k) => k.enabled).map((k) => k.keyword).toList();
    ref.read(localProxyServiceProvider).setToolFilterKeywords(active);
  }
}

/// 把工具过滤关键词的 get/set 注册到 bridge,让注入 codex 页面里的 JS 也能读写。
///
/// /tool-filter/get — 读当前列表 + i18n labels
/// /tool-filter/add — { keyword: string }
/// /tool-filter/remove — { keyword: string }
/// /tool-filter/toggle — { keyword: string, enabled: bool }
@Riverpod(keepAlive: true)
bool toolFilterRouteRegistration(Ref ref) {
  final bridge = ref.read(bridgeServiceProvider);

  Map<String, dynamic> payload() {
    final isZh = ref.read(localeProvider).languageCode == 'zh';
    return {
      'keywords': ref
          .read(toolFilterKeywordsProvider)
          .map((k) => k.toJson())
          .toList(),
      'labels': _labels(isZh),
    };
  }

  bridge.register('/tool-filter/get', (_) async => payload());

  bridge.register('/tool-filter/add', (p) async {
    final kw = (p['keyword'] as String?)?.trim() ?? '';
    if (kw.isNotEmpty) {
      await ref.read(toolFilterKeywordsProvider.notifier).add(kw);
    }
    return payload();
  });

  bridge.register('/tool-filter/remove', (p) async {
    final kw = (p['keyword'] as String?)?.trim() ?? '';
    if (kw.isNotEmpty) {
      await ref.read(toolFilterKeywordsProvider.notifier).remove(kw);
    }
    return payload();
  });

  bridge.register('/tool-filter/toggle', (p) async {
    final kw = (p['keyword'] as String?)?.trim() ?? '';
    final enabled = p['enabled'];
    if (kw.isNotEmpty && enabled is bool) {
      await ref
          .read(toolFilterKeywordsProvider.notifier)
          .setEnabled(kw, enabled);
    }
    return payload();
  });

  return true;
}

Map<String, String> _labels(bool isZh) {
  if (isZh) {
    return const {
      'title': '工具过滤',
      'description': '按关键词剔除请求里的工具项',
      'placeholder': '如 image_generation',
      'add': '添加',
      'empty': '无关键词',
      'duplicate': '关键词已存在',
      'invalid': '关键词不能为空',
      'enabled': '启用',
      'disabled': '已禁用',
    };
  }
  return const {
    'title': 'Tool filter',
    'description': 'Strip request tools by keyword',
    'placeholder': 'e.g. image_generation',
    'add': 'Add',
    'empty': 'No keywords',
    'duplicate': 'Keyword already exists',
    'invalid': 'Keyword cannot be empty',
    'enabled': 'Enabled',
    'disabled': 'Disabled',
  };
}

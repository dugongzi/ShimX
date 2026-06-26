import 'dart:convert';

import 'package:shim/core/services/app_storage.dart';

const codexSkillRegistryKey = 'codex_skill_registry_v1';

class CodexSkillRegistry {
  CodexSkillRegistry({
    AppStorage? storage,
    Map<String, Map<String, Object?>>? memory,
  }) : _storage = storage,
       _memory = memory;

  final AppStorage? _storage;
  final Map<String, Map<String, Object?>>? _memory;

  Future<Map<String, Map<String, Object?>>> read() async {
    if (_memory != null) {
      return Map<String, Map<String, Object?>>.from(
        _memory.map(
          (key, value) => MapEntry(key, Map<String, Object?>.from(value)),
        ),
      );
    }
    final raw = await _storage?.getString(codexSkillRegistryKey);
    if (raw == null || raw.trim().isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(
        key.toString(),
        value is Map ? Map<String, Object?>.from(value) : <String, Object?>{},
      ),
    );
  }

  Future<void> write(Map<String, Map<String, Object?>> registry) async {
    if (_memory != null) {
      _memory
        ..clear()
        ..addAll(
          registry.map(
            (key, value) => MapEntry(key, Map<String, Object?>.from(value)),
          ),
        );
      return;
    }
    await _storage?.setString(codexSkillRegistryKey, jsonEncode(registry));
  }
}

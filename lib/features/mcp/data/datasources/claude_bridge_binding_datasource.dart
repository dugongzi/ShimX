import 'dart:convert';

import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/features/mcp/data/models/claude_bridge_binding_dto.dart';

const claudeBridgeBindingStoreKey = 'claude_bridge_bindings_v1';

class ClaudeBridgeBindingDatasource {
  ClaudeBridgeBindingDatasource({
    AppStorage? storage,
    Map<String, String>? memory,
  }) : _storage = storage,
       _memory = memory;

  final AppStorage? _storage;
  final Map<String, String>? _memory;

  Future<Map<String, ClaudeBridgeBindingDto>> read() async {
    final raw = _memory != null
        ? _memory[claudeBridgeBindingStoreKey]
        : await _storage?.getString(claudeBridgeBindingStoreKey);
    if (raw == null || raw.trim().isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};

    final result = <String, ClaudeBridgeBindingDto>{};
    for (final entry in decoded.entries) {
      final codexThreadId = entry.key.toString();
      final value = entry.value;
      if (value is! Map) continue;
      final dto = ClaudeBridgeBindingDto.fromStorageEntry(
        codexThreadId: codexThreadId,
        json: Map<String, Object?>.from(value),
      );
      if (dto.isValid) {
        result[codexThreadId] = dto;
      }
    }
    return result;
  }

  Future<void> write(Map<String, ClaudeBridgeBindingDto> bindings) async {
    final encoded = jsonEncode(
      bindings.map((key, value) => MapEntry(key, value.toStorageJson())),
    );
    if (_memory != null) {
      _memory[claudeBridgeBindingStoreKey] = encoded;
      return;
    }
    await _storage?.setString(claudeBridgeBindingStoreKey, encoded);
  }
}

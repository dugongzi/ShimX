import 'dart:convert';

import 'package:shimx/core/services/app_storage.dart';
import 'package:shimx/features/providers/data/models/auto_switch_settings_dto.dart';

class AutoSwitchDatasource {
  AutoSwitchDatasource({required this.appStorage});

  final AppStorage appStorage;

  static const _settingsKey = 'auto_switch_settings';

  Future<AutoSwitchSettingsDto?> read() async {
    final raw = await appStorage.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return null;
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return AutoSwitchSettingsDto.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<void> write({required AutoSwitchSettingsDto dto}) async {
    await appStorage.setString(_settingsKey, jsonEncode(dto.toJson()));
  }
}

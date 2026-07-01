import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shim/core/services/app_storage.dart';
import 'package:shim/core/utils/script_metadata_parser.dart';
import 'package:shim/features/scripts/data/models/script_metadata_dto.dart';
import 'package:shim/features/scripts/domain/models/inject_script.dart';
import 'package:shim/features/scripts/domain/models/script_metadata.dart';

class ScriptQueryDatasource {
  final AppStorage _appStorage;

  ScriptQueryDatasource({required AppStorage appStorage})
      : _appStorage = appStorage;

  Future<List<InjectScript>> listScripts() async {
    final dir = await _scriptsDir();
    if (!await dir.exists()) return [];
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.js'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final result = <InjectScript>[];
    for (final file in files) {
      final filename = p.basename(file.path);
      final code = await file.readAsString();
      final parsed = parseScriptMetadata(code);
      final metadata = parsed ?? _fallbackMetadata(filename);
      result.add(
        InjectScript(
          id: filename,
          filePath: file.path,
          metadata: metadata,
          code: code,
        ),
      );
    }
    return result;
  }

  Future<bool> isScriptEnabled({required String id}) async {
    final value = await _appStorage.getBool(_enabledKey(id));
    return value ?? false;
  }

  static String _enabledKey(String id) => 'script_enabled:$id';

  ScriptMetadata _fallbackMetadata(String filename) {
    return const ScriptMetadataDto().toEntity().copyWith(
          name: p.basenameWithoutExtension(filename),
        );
  }

  Future<Directory> _scriptsDir() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'scripts'));
  }
}

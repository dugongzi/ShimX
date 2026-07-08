import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shimx/core/networks/http_service.dart';
import 'package:shimx/features/scripts/domain/models/remote_script.dart';

class RemoteScriptActionDatasource {
  const RemoteScriptActionDatasource({required HttpService httpService})
      : _httpService = httpService;

  final HttpService _httpService;

  Future<String> install(RemoteScript script) async {
    final fileName = _safeFileName(script.fileName);
    final response = await _httpService.get<String>(
      script.downloadUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 400) {
      throw StateError('Remote script download failed: HTTP $statusCode.');
    }
    final code = response.data ?? '';
    if (code.isEmpty) {
      throw StateError('Remote script is empty.');
    }
    _verifySha256(code: code, expected: script.sha256);
    final dir = await _scriptsDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(code, encoding: utf8);
    return fileName;
  }

  String _safeFileName(String value) {
    final baseName = p.basename(value.trim());
    if (baseName.isEmpty || !baseName.toLowerCase().endsWith('.js')) {
      throw StateError('Remote script fileName must be a .js file.');
    }
    return baseName;
  }

  void _verifySha256({required String code, required String expected}) {
    final normalized = expected.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final actual = sha256.convert(utf8.encode(code)).toString();
    if (actual != normalized) {
      throw StateError('Remote script sha256 mismatch.');
    }
  }

  Future<Directory> _scriptsDir() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'scripts'));
  }
}

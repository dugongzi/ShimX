import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'package:shim/features/plugins/data/datasources/plugin_marketplace_paths.dart';
import 'package:shim/features/plugins/data/datasources/plugin_query_datasource.dart';
import 'package:shim/features/plugins/data/models/plugin_marketplace_status_dto.dart';

/// 只写:下载 zip / 解压 / 释放 / 改 config.toml。全部方法都在末尾复用
/// [PluginQueryDatasource.readMarketplaceStatus] 回传最新 DTO,避免与
/// query 逻辑重复。
class PluginActionDatasource {
  PluginActionDatasource({
    Dio? dio,
    PluginQueryDatasource? queryDatasource,
  })  : _dio = dio ?? _buildHttpDio(),
        _query = queryDatasource ?? const PluginQueryDatasource();

  final Dio _dio;
  final PluginQueryDatasource _query;

  static const _openaiPluginsZipUrl =
      'https://codeload.github.com/openai/plugins/zip/refs/heads/main';
  static const _downloadLimitBytes = 128 * 1024 * 1024;

  static Dio _buildHttpDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 3),
        responseType: ResponseType.bytes,
      ),
    );
  }

  /// [onProgress] 收到 (received, total)。total<=0 表示服务器没给
  /// content-length,只能显示已下载字节。dio 内部约 8KB 一次回调,
  /// 用调方自己节流即可(避免打断 UI 每帧几十次刷新)。
  Future<PluginMarketplaceStatusDto> installFromGithub({
    void Function(int received, int total)? onProgress,
  }) async {
    final bytes = await _downloadOpenaiPluginsZip(onProgress: onProgress);
    await _installZipBytes(bytes, stripFirstSegment: true);
    _writeMarketplaceConfig();
    return _query.readMarketplaceStatus();
  }

  Future<PluginMarketplaceStatusDto> installFromLocalZip(String zipPath) async {
    final file = File(zipPath);
    if (!file.existsSync()) {
      throw StateError('zip 文件不存在: $zipPath');
    }
    final bytes = await file.readAsBytes();
    try {
      await _installZipBytes(bytes, stripFirstSegment: false);
    } on _MarketplaceValidationException {
      await _installZipBytes(bytes, stripFirstSegment: true);
    }
    _writeMarketplaceConfig();
    return _query.readMarketplaceStatus();
  }

  Future<PluginMarketplaceStatusDto> installFromLocalDir(
      String dirPath) async {
    final source = Directory(dirPath);
    if (!source.existsSync()) {
      throw StateError('目录不存在: $dirPath');
    }
    if (!PluginMarketplacePaths.marketplaceJson(source).existsSync()) {
      throw StateError('目录里没有 .agents/plugins/marketplace.json');
    }
    final destination = PluginMarketplacePaths.curatedRoot();
    await _swapDirectory(source: source, destination: destination);
    _writeMarketplaceConfig();
    return _query.readMarketplaceStatus();
  }

  // ---------- 内部 ----------

  Future<List<int>> _downloadOpenaiPluginsZip({
    void Function(int received, int total)? onProgress,
  }) async {
    final response = await _dio.get<List<int>>(
      _openaiPluginsZipUrl,
      options: Options(
        headers: {'Accept': 'application/zip'},
        responseType: ResponseType.bytes,
      ),
      onReceiveProgress: onProgress == null
          ? null
          : (received, total) => onProgress(received, total),
    );
    final data = response.data ?? const <int>[];
    if (data.isEmpty) {
      throw StateError('openai/plugins zip 下载为空');
    }
    if (data.length > _downloadLimitBytes) {
      throw StateError('openai/plugins zip 超过大小上限');
    }
    return data;
  }

  Future<void> _installZipBytes(
    List<int> bytes, {
    required bool stripFirstSegment,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final destination = PluginMarketplacePaths.curatedRoot();
    final stagingParent = Directory(p.dirname(destination.path));
    if (!stagingParent.existsSync()) {
      stagingParent.createSync(recursive: true);
    }
    final staging = Directory(p.join(
      stagingParent.path,
      'plugins-download-${DateTime.now().millisecondsSinceEpoch}',
    ));
    if (staging.existsSync()) staging.deleteSync(recursive: true);
    staging.createSync(recursive: true);

    try {
      for (final entry in archive) {
        final relative = _relativeSafePath(
          entry.name,
          stripFirstSegment: stripFirstSegment,
        );
        if (relative == null) continue;
        final outPath = p.join(staging.path, relative);
        if (entry.isFile) {
          final outFile = File(outPath);
          outFile.parent.createSync(recursive: true);
          outFile.writeAsBytesSync(entry.content as List<int>);
        } else {
          Directory(outPath).createSync(recursive: true);
        }
      }
      _validateMarketplaceRoot(staging);
      await _swapDirectory(source: staging, destination: destination);
    } catch (_) {
      if (staging.existsSync()) {
        try {
          staging.deleteSync(recursive: true);
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// zip entry 名字归一化 + 越权防护。返回 null 表示应跳过。
  String? _relativeSafePath(
    String rawName, {
    required bool stripFirstSegment,
  }) {
    final normalized = rawName.replaceAll('\\', '/');
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;
    for (final seg in segments) {
      if (seg == '..' || seg == '.') return null;
      if (seg.contains(':')) return null; // 防 windows 盘符/ADS
    }
    final effective = stripFirstSegment && segments.length > 1
        ? segments.sublist(1)
        : segments;
    if (effective.isEmpty) return null;
    return effective.join(Platform.pathSeparator);
  }

  void _validateMarketplaceRoot(Directory root) {
    final marketplaceFile = PluginMarketplacePaths.marketplaceJson(root);
    if (!marketplaceFile.existsSync()) {
      throw const _MarketplaceValidationException(
          '缺少 .agents/plugins/marketplace.json');
    }
    dynamic parsed;
    try {
      parsed = jsonDecode(marketplaceFile.readAsStringSync());
    } catch (e) {
      throw _MarketplaceValidationException('marketplace.json 解析失败: $e');
    }
    if (parsed is! Map ||
        parsed['name'] != PluginMarketplacePaths.curatedName) {
      throw const _MarketplaceValidationException(
          'marketplace.json 里 name 不是 openai-curated');
    }
    final plugins = parsed['plugins'];
    if (plugins is! List || plugins.isEmpty) {
      throw const _MarketplaceValidationException(
          'marketplace.json 里 plugins 为空');
    }
    if (!PluginMarketplacePaths.pluginsSubdir(root).existsSync()) {
      throw const _MarketplaceValidationException('缺少 plugins/ 目录');
    }
  }

  Future<void> _swapDirectory({
    required Directory source,
    required Directory destination,
  }) async {
    final parent = Directory(p.dirname(destination.path));
    if (!parent.existsSync()) parent.createSync(recursive: true);
    final backup = Directory('${destination.path}.previous-shim');
    if (backup.existsSync()) {
      try {
        backup.deleteSync(recursive: true);
      } catch (_) {}
    }
    if (destination.existsSync()) {
      try {
        destination.renameSync(backup.path);
      } catch (_) {
        // Windows 上偶尔 rename 失败(权限/占用),兜底复制 + 递归删除
        _copyDirectory(destination, backup);
        destination.deleteSync(recursive: true);
      }
    }
    try {
      source.renameSync(destination.path);
    } catch (_) {
      _copyDirectory(source, destination);
      try {
        source.deleteSync(recursive: true);
      } catch (_) {}
    }
    if (backup.existsSync()) {
      try {
        backup.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  void _copyDirectory(Directory src, Directory dst) {
    if (!dst.existsSync()) dst.createSync(recursive: true);
    for (final entity in src.listSync(recursive: true, followLinks: false)) {
      final relative = p.relative(entity.path, from: src.path);
      final targetPath = p.join(dst.path, relative);
      if (entity is Directory) {
        Directory(targetPath).createSync(recursive: true);
      } else if (entity is File) {
        File(targetPath).parent.createSync(recursive: true);
        entity.copySync(targetPath);
      }
    }
  }

  void _writeMarketplaceConfig() {
    final root = PluginMarketplacePaths.curatedRoot().path;
    final doc = PluginMarketplacePaths.readConfigDoc();
    final marketplaces = doc['marketplaces'] is Map
        ? Map<String, dynamic>.from(doc['marketplaces'] as Map)
        : <String, dynamic>{};
    for (final name in PluginMarketplacePaths.allNames) {
      final section = marketplaces[name] is Map
          ? Map<String, dynamic>.from(marketplaces[name] as Map)
          : <String, dynamic>{};
      section['source_type'] = 'local';
      section['source'] = root;
      marketplaces[name] = section;
    }
    doc['marketplaces'] = marketplaces;
    PluginMarketplacePaths.writeConfigDoc(doc);
  }
}

class _MarketplaceValidationException implements Exception {
  const _MarketplaceValidationException(this.message);
  final String message;
  @override
  String toString() => 'MarketplaceValidationException: $message';
}

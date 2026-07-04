import 'package:shim/features/plugins/data/datasources/plugin_action_datasource.dart';
import 'package:shim/features/plugins/domain/models/plugin_marketplace_status.dart';
import 'package:shim/features/plugins/domain/repositories/plugin_action_repository.dart';

class PluginActionRepositoryImpl implements PluginActionRepository {
  PluginActionRepositoryImpl({required this.dataSource});

  final PluginActionDatasource dataSource;

  @override
  Future<PluginMarketplaceStatus> installFromGithub({
    void Function(int received, int total)? onProgress,
  }) async {
    return (await dataSource.installFromGithub(onProgress: onProgress))
        .toEntity();
  }

  @override
  Future<PluginMarketplaceStatus> installFromLocalZip({
    required String zipPath,
  }) async {
    return (await dataSource.installFromLocalZip(zipPath)).toEntity();
  }

  @override
  Future<PluginMarketplaceStatus> installFromLocalDir({
    required String dirPath,
  }) async {
    return (await dataSource.installFromLocalDir(dirPath)).toEntity();
  }
}

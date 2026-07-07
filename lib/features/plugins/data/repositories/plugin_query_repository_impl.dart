import 'package:shimx/features/plugins/data/datasources/plugin_query_datasource.dart';
import 'package:shimx/features/plugins/domain/models/plugin_marketplace_status.dart';
import 'package:shimx/features/plugins/domain/repositories/plugin_query_repository.dart';

class PluginQueryRepositoryImpl implements PluginQueryRepository {
  PluginQueryRepositoryImpl({required this.dataSource});

  final PluginQueryDatasource dataSource;

  @override
  Future<PluginMarketplaceStatus> readMarketplaceStatus() async {
    return dataSource.readMarketplaceStatus().toEntity();
  }
}

import 'package:shimx/features/settings/data/datasources/config_query_datasource.dart';
import 'package:shimx/features/settings/domain/repositories/config_query_repository.dart';

class ConfigQueryRepositoryImpl implements ConfigQueryRepository {
  final ConfigQueryDatasource dataSource;

  ConfigQueryRepositoryImpl({required this.dataSource});
}

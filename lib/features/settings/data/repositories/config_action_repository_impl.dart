import 'package:shimx/features/settings/data/datasources/config_action_datasource.dart';
import 'package:shimx/features/settings/domain/repositories/config_action_repository.dart';

class ConfigActionRepositoryImpl implements ConfigActionRepository {
  final ConfigActionDatasource dataSource;

  ConfigActionRepositoryImpl({required this.dataSource});
}

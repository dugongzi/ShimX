import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shim/features/plugins/data/datasources/plugin_action_datasource.dart';
import 'package:shim/features/plugins/data/repositories/plugin_action_repository_impl.dart';
import 'package:shim/features/plugins/domain/repositories/plugin_action_repository.dart';
import 'package:shim/features/plugins/presentation/providers/plugin_query_provider.dart';

part 'plugin_action_provider.g.dart';

@riverpod
PluginActionDatasource pluginActionDatasource(Ref ref) {
  final query = ref.watch(pluginQueryDatasourceProvider);
  return PluginActionDatasource(queryDatasource: query);
}

@riverpod
PluginActionRepository pluginActionRepository(Ref ref) {
  final dataSource = ref.watch(pluginActionDatasourceProvider);
  return PluginActionRepositoryImpl(dataSource: dataSource);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shimx/features/plugins/data/datasources/plugin_query_datasource.dart';
import 'package:shimx/features/plugins/data/repositories/plugin_query_repository_impl.dart';
import 'package:shimx/features/plugins/domain/repositories/plugin_query_repository.dart';

part 'plugin_query_provider.g.dart';

@riverpod
PluginQueryDatasource pluginQueryDatasource(Ref ref) {
  return const PluginQueryDatasource();
}

@riverpod
PluginQueryRepository pluginQueryRepository(Ref ref) {
  final dataSource = ref.watch(pluginQueryDatasourceProvider);
  return PluginQueryRepositoryImpl(dataSource: dataSource);
}

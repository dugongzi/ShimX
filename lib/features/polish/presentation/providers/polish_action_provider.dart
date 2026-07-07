import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:shimx/features/polish/data/datasources/polish_action_datasource.dart';
import 'package:shimx/features/polish/data/repositories/polish_action_repository_impl.dart';
import 'package:shimx/features/polish/domain/repositories/polish_action_repository.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';

part 'polish_action_provider.g.dart';

@riverpod
PolishActionDatasource polishActionDatasource(Ref ref) {
  return PolishActionDatasource();
}

@riverpod
PolishActionRepository polishActionRepository(Ref ref) {
  final ds = ref.watch(polishActionDatasourceProvider);
  return PolishActionRepositoryImpl(
    dataSource: ds,
    proxyBaseUrlProvider: () async {
      final proxy = await ref.read(proxyConfigProvider.future);
      return proxy.localProxyUrl;
    },
  );
}

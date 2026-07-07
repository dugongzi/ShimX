import 'package:shimx/features/polish/data/datasources/polish_action_datasource.dart';
import 'package:shimx/features/polish/domain/repositories/polish_action_repository.dart';

class PolishActionRepositoryImpl implements PolishActionRepository {
  PolishActionRepositoryImpl({
    required this.dataSource,
    required this.proxyBaseUrlProvider,
  });

  final PolishActionDatasource dataSource;

  /// 读取当前代理 base url(比如 http://127.0.0.1:8787/v1)。惰性调用,
  /// 保证每次润色都拿最新端口(用户改端口后不用重启)。
  final Future<String> Function() proxyBaseUrlProvider;

  @override
  Future<String> polish({
    required String text,
    required String instruction,
  }) async {
    final baseUrl = await proxyBaseUrlProvider();
    return dataSource.polish(
      text: text,
      instruction: instruction,
      proxyBaseUrl: baseUrl,
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/networks/http_service.dart';
import 'package:shimx/features/scripts/data/datasources/remote_script_action_datasource.dart';
import 'package:shimx/features/scripts/data/repositories/remote_script_action_repository_impl.dart';
import 'package:shimx/features/scripts/domain/models/remote_script.dart';
import 'package:shimx/features/scripts/domain/repositories/remote_script_action_repository.dart';

part 'remote_script_action_provider.g.dart';

@riverpod
RemoteScriptActionRepository remoteScriptActionRepository(Ref ref) {
  return RemoteScriptActionRepositoryImpl(
    dataSource: RemoteScriptActionDatasource(
      httpService: ref.watch(httpServiceProvider),
    ),
  );
}

@riverpod
Future<String> installRemoteScript(Ref ref, {required RemoteScript script}) async {
  return ref.read(remoteScriptActionRepositoryProvider).install(script);
}

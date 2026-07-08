import 'package:shimx/features/scripts/domain/models/remote_script.dart';

abstract class RemoteScriptActionRepository {
  Future<String> install(RemoteScript script);
}

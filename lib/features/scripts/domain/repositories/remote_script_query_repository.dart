import 'package:shimx/features/scripts/domain/models/remote_script_catalog.dart';

abstract class RemoteScriptQueryRepository {
  Future<RemoteScriptCatalog> fetchCatalog();
}

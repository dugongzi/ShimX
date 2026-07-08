import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/scripts/domain/models/remote_script.dart';

part 'remote_script_catalog.freezed.dart';

@freezed
abstract class RemoteScriptCatalog with _$RemoteScriptCatalog {
  const RemoteScriptCatalog._();

  const factory RemoteScriptCatalog({
    required int version,
    required String updatedAt,
    required List<RemoteScript> items,
  }) = _RemoteScriptCatalog;
}

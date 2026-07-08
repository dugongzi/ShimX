import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/scripts/data/models/remote_script_dto.dart';
import 'package:shimx/features/scripts/domain/models/remote_script_catalog.dart';

part 'remote_script_catalog_dto.freezed.dart';
part 'remote_script_catalog_dto.g.dart';

@freezed
abstract class RemoteScriptCatalogDto with _$RemoteScriptCatalogDto {
  const RemoteScriptCatalogDto._();

  const factory RemoteScriptCatalogDto({
    @Default(1) int version,
    @Default('') String updatedAt,
    @Default([]) List<RemoteScriptDto> items,
  }) = _RemoteScriptCatalogDto;

  factory RemoteScriptCatalogDto.fromJson(Map<String, Object?> json) =>
      _$RemoteScriptCatalogDtoFromJson(json);

  RemoteScriptCatalog toEntity() {
    return RemoteScriptCatalog(
      version: version,
      updatedAt: updatedAt,
      items: items.map((item) => item.toEntity()).toList(growable: false),
    );
  }
}

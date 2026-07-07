import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/scripts/domain/models/script_metadata.dart';

part 'script_metadata_dto.freezed.dart';
part 'script_metadata_dto.g.dart';

@freezed
abstract class ScriptMetadataDto with _$ScriptMetadataDto {
  const ScriptMetadataDto._();

  const factory ScriptMetadataDto({
    @Default('') String name,
    @Default('') String description,
    @Default('') String version,
    @Default('') String author,
  }) = _ScriptMetadataDto;

  factory ScriptMetadataDto.fromJson(Map<String, dynamic> json) =>
      _$ScriptMetadataDtoFromJson(json);

  ScriptMetadata toEntity() {
    return ScriptMetadata(
      name: name,
      description: description,
      version: version,
      author: author,
    );
  }
}

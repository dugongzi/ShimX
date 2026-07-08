import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/scripts/domain/models/remote_script.dart';

part 'remote_script_dto.freezed.dart';
part 'remote_script_dto.g.dart';

@freezed
abstract class RemoteScriptDto with _$RemoteScriptDto {
  const RemoteScriptDto._();

  const factory RemoteScriptDto({
    @Default('') String id,
    @Default('') String name,
    @Default('') String description,
    @Default('') String version,
    @Default('') String author,
    @Default('') String fileName,
    @Default('') String downloadUrl,
    @Default('') String sha256,
  }) = _RemoteScriptDto;

  factory RemoteScriptDto.fromJson(Map<String, Object?> json) =>
      _$RemoteScriptDtoFromJson(json);

  RemoteScript toEntity() {
    return RemoteScript(
      id: id,
      name: name,
      description: description,
      version: version,
      author: author,
      fileName: fileName,
      downloadUrl: downloadUrl,
      sha256: sha256,
    );
  }
}

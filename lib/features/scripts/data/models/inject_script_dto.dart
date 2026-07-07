import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/scripts/data/models/script_metadata_dto.dart';
import 'package:shimx/features/scripts/domain/models/inject_script.dart';

part 'inject_script_dto.freezed.dart';
part 'inject_script_dto.g.dart';

@freezed
abstract class InjectScriptDto with _$InjectScriptDto {
  const InjectScriptDto._();

  const factory InjectScriptDto({
    @Default('') String id,
    @Default('') String filePath,
    @Default(ScriptMetadataDto()) ScriptMetadataDto metadata,
    @Default('') String code,
  }) = _InjectScriptDto;

  factory InjectScriptDto.fromJson(Map<String, dynamic> json) =>
      _$InjectScriptDtoFromJson(json);

  InjectScript toEntity() {
    return InjectScript(
      id: id,
      filePath: filePath,
      metadata: metadata.toEntity(),
      code: code,
    );
  }
}

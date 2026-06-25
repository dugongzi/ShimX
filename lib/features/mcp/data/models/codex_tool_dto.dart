import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/features/mcp/domain/models/codex_tool.dart';

part 'codex_tool_dto.freezed.dart';
part 'codex_tool_dto.g.dart';

@freezed
abstract class CodexToolDto with _$CodexToolDto {
  const CodexToolDto._();

  const factory CodexToolDto({
    @Default('') String id,
    @Default(CodexToolKind.mcpServer) String kind,
    @Default('') String bodyText,
    @Default(true) bool enabled,
    @Default(false) bool managedByShim,
    @Default(true) bool readOnly,
    @Default('') String name,
    @Default('') String description,
  }) = _CodexToolDto;

  factory CodexToolDto.fromJson(Map<String, Object?> json) =>
      _$CodexToolDtoFromJson(json);

  factory CodexToolDto.fromEntity(CodexTool entity) {
    return CodexToolDto(
      id: entity.id,
      kind: entity.kind,
      bodyText: entity.bodyText,
      enabled: entity.enabled,
      managedByShim: entity.managedByShim,
      readOnly: entity.readOnly,
      name: entity.name,
      description: entity.description,
    );
  }

  CodexTool toEntity() {
    return CodexTool(
      id: id,
      kind: kind,
      bodyText: bodyText,
      enabled: enabled,
      managedByShim: managedByShim,
      readOnly: readOnly,
      name: name,
      description: description,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/mcp/domain/models/codex_mcp_config.dart';

part 'codex_mcp_config_dto.freezed.dart';
part 'codex_mcp_config_dto.g.dart';

@freezed
abstract class CodexMcpConfigDto with _$CodexMcpConfigDto {
  const CodexMcpConfigDto._();

  const factory CodexMcpConfigDto({
    @Default('') String id,
    @Default(CodexMcpConfigKind.mcpServer) String kind,
    @Default('') String bodyText,
    @Default(true) bool enabled,
    @Default(false) bool managedByShimX,
    @Default(true) bool readOnly,
    @Default('') String name,
    @Default('') String description,
  }) = _CodexMcpConfigDto;

  factory CodexMcpConfigDto.fromJson(Map<String, Object?> json) =>
      _$CodexMcpConfigDtoFromJson(json);

  factory CodexMcpConfigDto.fromEntity(CodexMcpConfig entity) {
    return CodexMcpConfigDto(
      id: entity.id,
      kind: entity.kind,
      bodyText: entity.bodyText,
      enabled: entity.enabled,
      managedByShimX: entity.managedByShimX,
      readOnly: entity.readOnly,
      name: entity.name,
      description: entity.description,
    );
  }

  CodexMcpConfig toEntity() {
    return CodexMcpConfig(
      id: id,
      kind: kind,
      bodyText: bodyText,
      enabled: enabled,
      managedByShimX: managedByShimX,
      readOnly: readOnly,
      name: name,
      description: description,
    );
  }
}

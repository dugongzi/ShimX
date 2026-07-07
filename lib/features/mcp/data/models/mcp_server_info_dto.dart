import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/mcp/domain/models/mcp_server_info.dart';

part 'mcp_server_info_dto.freezed.dart';
part 'mcp_server_info_dto.g.dart';

@freezed
abstract class McpServerInfoDto with _$McpServerInfoDto {
  const McpServerInfoDto._();

  const factory McpServerInfoDto({
    @Default('') String id,
    @Default('') String name,
    @Default('') String description,
    @Default('') String url,
    @Default('stopped') String status,
    @Default('') String statusDetail,
    @Default(0) int toolCount,
    @Default(false) bool registeredInCodex,
  }) = _McpServerInfoDto;

  factory McpServerInfoDto.fromJson(Map<String, dynamic> json) =>
      _$McpServerInfoDtoFromJson(json);

  McpServerInfo toEntity() {
    return McpServerInfo(
      id: id,
      name: name,
      description: description,
      url: url,
      status: status,
      statusDetail: statusDetail,
      toolCount: toolCount,
      registeredInCodex: registeredInCodex,
    );
  }
}

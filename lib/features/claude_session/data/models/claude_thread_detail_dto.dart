import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/features/claude_session/data/models/claude_thread_message_dto.dart';
import 'package:shim/features/claude_session/domain/models/claude_thread_detail.dart';

part 'claude_thread_detail_dto.freezed.dart';
part 'claude_thread_detail_dto.g.dart';

@freezed
abstract class ClaudeThreadDetailDto with _$ClaudeThreadDetailDto {
  const ClaudeThreadDetailDto._();

  const factory ClaudeThreadDetailDto({
    @Default('') String sessionId,
    @Default('') String title,
    @Default('') String cwd,
    @Default('') String gitBranch,
    @Default('') String cliVersion,
    @Default('') String jsonlPath,
    @Default(0) int createdAtMs,
    @Default(0) int updatedAtMs,
    @Default([]) List<ClaudeThreadMessageDto> messages,
  }) = _ClaudeThreadDetailDto;

  factory ClaudeThreadDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ClaudeThreadDetailDtoFromJson(json);

  ClaudeThreadDetail toEntity() {
    return ClaudeThreadDetail(
      sessionId: sessionId,
      title: title,
      cwd: cwd,
      gitBranch: gitBranch,
      cliVersion: cliVersion,
      jsonlPath: jsonlPath,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      messages: messages.map((m) => m.toEntity()).toList(),
    );
  }
}

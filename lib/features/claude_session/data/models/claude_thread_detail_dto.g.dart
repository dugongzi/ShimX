// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_thread_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClaudeThreadDetailDto _$ClaudeThreadDetailDtoFromJson(
  Map<String, dynamic> json,
) => _ClaudeThreadDetailDto(
  sessionId: json['sessionId'] as String? ?? '',
  title: json['title'] as String? ?? '',
  cwd: json['cwd'] as String? ?? '',
  gitBranch: json['gitBranch'] as String? ?? '',
  cliVersion: json['cliVersion'] as String? ?? '',
  jsonlPath: json['jsonlPath'] as String? ?? '',
  createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
  updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map(
            (e) => ClaudeThreadMessageDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$ClaudeThreadDetailDtoToJson(
  _ClaudeThreadDetailDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'title': instance.title,
  'cwd': instance.cwd,
  'gitBranch': instance.gitBranch,
  'cliVersion': instance.cliVersion,
  'jsonlPath': instance.jsonlPath,
  'createdAtMs': instance.createdAtMs,
  'updatedAtMs': instance.updatedAtMs,
  'messages': instance.messages,
};

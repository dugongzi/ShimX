// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_thread_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClaudeThreadDto _$ClaudeThreadDtoFromJson(Map<String, dynamic> json) =>
    _ClaudeThreadDto(
      sessionId: json['sessionId'] as String? ?? '',
      jsonlPath: json['jsonlPath'] as String? ?? '',
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      cwd: json['cwd'] as String? ?? '',
      gitBranch: json['gitBranch'] as String? ?? '',
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ClaudeThreadDtoToJson(_ClaudeThreadDto instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'jsonlPath': instance.jsonlPath,
      'title': instance.title,
      'preview': instance.preview,
      'cwd': instance.cwd,
      'gitBranch': instance.gitBranch,
      'updatedAtMs': instance.updatedAtMs,
      'createdAtMs': instance.createdAtMs,
      'sizeBytes': instance.sizeBytes,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClaudeProjectDto _$ClaudeProjectDtoFromJson(Map<String, dynamic> json) =>
    _ClaudeProjectDto(
      encodedDir: json['encodedDir'] as String? ?? '',
      cwd: json['cwd'] as String? ?? '',
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
      lastActiveMs: (json['lastActiveMs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ClaudeProjectDtoToJson(_ClaudeProjectDto instance) =>
    <String, dynamic>{
      'encodedDir': instance.encodedDir,
      'cwd': instance.cwd,
      'sessionCount': instance.sessionCount,
      'lastActiveMs': instance.lastActiveMs,
    };

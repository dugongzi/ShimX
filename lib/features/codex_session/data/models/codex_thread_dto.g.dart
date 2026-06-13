// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_thread_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexThreadDto _$CodexThreadDtoFromJson(Map<String, dynamic> json) =>
    _CodexThreadDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      firstUserMessage: json['firstUserMessage'] as String? ?? '',
      cwd: json['cwd'] as String? ?? '',
      archived: (json['archived'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      tokensUsed: (json['tokensUsed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CodexThreadDtoToJson(_CodexThreadDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'preview': instance.preview,
      'firstUserMessage': instance.firstUserMessage,
      'cwd': instance.cwd,
      'archived': instance.archived,
      'updatedAtMs': instance.updatedAtMs,
      'createdAtMs': instance.createdAtMs,
      'tokensUsed': instance.tokensUsed,
    };

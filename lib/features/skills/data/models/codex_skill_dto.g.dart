// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codex_skill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CodexSkillDto _$CodexSkillDtoFromJson(Map<String, dynamic> json) =>
    _CodexSkillDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      path: json['path'] as String? ?? '',
      managedByShimX: json['managedByShimX'] as bool? ?? false,
      readOnly: json['readOnly'] as bool? ?? true,
      hasSkillFile: json['hasSkillFile'] as bool? ?? false,
      installedAt: (json['installedAt'] as num?)?.toInt() ?? 0,
      contentHash: json['contentHash'] as String? ?? '',
    );

Map<String, dynamic> _$CodexSkillDtoToJson(_CodexSkillDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'path': instance.path,
      'managedByShimX': instance.managedByShimX,
      'readOnly': instance.readOnly,
      'hasSkillFile': instance.hasSkillFile,
      'installedAt': instance.installedAt,
      'contentHash': instance.contentHash,
    };

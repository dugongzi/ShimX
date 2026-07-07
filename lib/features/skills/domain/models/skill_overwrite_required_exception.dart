/// 安装 shimx 管理 Skill 时,同名条目已存在 → datasource 抛此异常让 UI 弹"是否覆盖"确认。
/// UI 确认后,以 `overwriteManaged: true` 重试调用。
class SkillOverwriteRequiredException implements Exception {
  const SkillOverwriteRequiredException(this.id);

  /// 冲突的 skill id。
  final String id;

  @override
  String toString() => 'SkillOverwriteRequiredException(id=$id)';
}

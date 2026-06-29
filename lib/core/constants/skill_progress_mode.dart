/// skills tab 顶部进度条文案映射的当前操作语义。
/// 复合多任务并行时由 widget 自行裁决展示哪个;[install]/[refresh] 全局,
/// [import]/[delete] 单条。
enum SkillProgressMode { install, refresh, import, delete }

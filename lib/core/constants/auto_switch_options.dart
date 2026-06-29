/// 自动切换策略:与 auto_switch_settings DTO / proxy/probe 逻辑里的判断保持一致。
const String autoSwitchStrategyManual = 'manual';
const String autoSwitchStrategyFailover = 'failover';
const String autoSwitchStrategyFastest = 'fastest';

/// 自动切换候选范围。
const String autoSwitchScopeSameType = 'same-type';
const String autoSwitchScopeSameProtocol = 'same-protocol';
const String autoSwitchScopeAny = 'any';

// ==ShimX==
// @name        ShimX codex_enhance — core/i18n
// @description S() 本地化 + provider 全局状态。S() 从 state.labels 里取, 所以两者绑死, 不能拆开。
//              暴露 state 给 features/provider_picker、features/auto_switch 直接读写 (语义跟原来一致)。
// @layer       core
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;

  const state = {
    selectedId: null,
    reasoningEffort: 'high',
    providers: [],
    labels: {},
  };
  let currentProviderLabel = null;
  let refreshInFlight = null;

  function S(key, fallback) {
    const v = state.labels && state.labels[key];
    return v || fallback || '';
  }

  function refreshCurrentProvider() {
    if (typeof window.shimx !== 'function') return;
    window.shimx('/provider/current', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        i18n.currentProviderLabel = res.data.label ?? null;
        const ensureBadge = window.__shimxCodex.features.providerPicker?.ensureBadge;
        if (typeof ensureBadge === 'function') ensureBadge();
      }
    }).catch(() => {});
  }

  // rebuildPopover=false: picker 已打开时只刷数据不重建按钮 / popover (避免破坏当前点击)
  function refreshProviderPickerState(opts) {
    if (typeof window.shimx !== 'function') return;
    const rebuildPopover = !opts || opts.rebuildPopover !== false;
    if (refreshInFlight) return refreshInFlight;
    refreshInFlight = window.shimx('/provider/list', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        state.selectedId = res.data.selectedId ?? null;
        state.reasoningEffort = res.data.reasoningEffort || 'high';
        state.providers = Array.isArray(res.data.providers) ? res.data.providers : [];
        state.labels = res.data.labels || {};
        const picker = window.__shimxCodex.features.providerPicker;
        picker?.updateButton?.();
        if (rebuildPopover) picker?.updatePopover?.();
        picker?.updateCodexModelSelectorVisibility?.();
      }
    }).catch(() => {}).finally(() => {
      refreshInFlight = null;
    });
    return refreshInFlight;
  }

  function scheduleProviderPickerRefresh() {
    const run = () => refreshProviderPickerState();
    if (typeof window.requestIdleCallback === 'function') {
      window.requestIdleCallback(run, { timeout: 600 });
      return;
    }
    setTimeout(run, 80);
  }

  function currentProvider() {
    return state.providers.find((p) => p.id === state.selectedId) || null;
  }

  function providerNameFromId(id) {
    if (!id) return null;
    const p = (state.providers || []).find((x) => x.id === id);
    return p?.name || null;
  }

  const i18n = {
    S,
    state,
    get currentProviderLabel() { return currentProviderLabel; },
    set currentProviderLabel(v) { currentProviderLabel = v; },
    refreshCurrentProvider,
    refreshProviderPickerState,
    scheduleProviderPickerRefresh,
    currentProvider,
    providerNameFromId,
  };
  window.__shimxCodex.i18n = i18n;
})();

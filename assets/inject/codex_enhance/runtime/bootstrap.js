// ==ShimX==
// @name        ShimX codex_enhance — runtime/bootstrap
// @description 启动序列。装好 UI scheduler、项目级菜单 hook, 等 shimx bridge 就绪后
//              拉一次当前供应商 / provider 列表, 注册定时刷新 + auto-switch push 订阅。
//              这是整个拼接脚本最后一个分片, 所有 features/runtime 都得在它之前 init 完。
// @layer       runtime
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;
  const ns = window.__shimxCodex;
  const __i18n = ns.i18n;
  const S = __i18n.S;
  const showToast = (msg, kind) => ns.ui.toast.show(msg, kind);

  ns.runtime.scheduler.install();
  ns.features.projectMenuHook.install();
  if (document.readyState === 'loading') {
    document.addEventListener(
      'DOMContentLoaded',
      () => ns.runtime.scheduler.ensureAll(),
      { once: true },
    );
  }

  // bridge 就绪后拉一次当前供应商, 并定时刷新 (供应商切换后标签随之更新)
  (function initProviderBadge() {
    if (typeof window.shimx !== 'function') {
      setTimeout(initProviderBadge, 500);
      return;
    }
    __i18n.refreshCurrentProvider();
    __i18n.refreshProviderPickerState();
    if (!window.__shimxProviderPollInstalled) {
      window.__shimxProviderPollInstalled = true;
      setInterval(() => {
        __i18n.refreshCurrentProvider();
        // 总是刷新数据 (按钮跟着变), popover 只有关着才重建
        const popoverOpen = !!document.getElementById(ns.ids.providerPickerPopover);
        __i18n.refreshProviderPickerState({ rebuildPopover: !popoverOpen });
      }, 15000);
    }

    // 订阅 dart 推送的自动切换事件。注意: picker 打开时不要触发 list 重建,
    // 否则用户正点的按钮会被销毁重建, 表现为"菜单卡死无法点击"。
    let lastPushAt = 0;
    if (typeof window.__shimxOn === 'function' && !window.__shimxAutoSwitchSub) {
      window.__shimxAutoSwitchSub = window.__shimxOn('/provider/auto-switched', (payload) => {
        if (!payload) return;
        const now = Date.now();
        // 节流: 同一秒内多次 push 只处理一次
        if (now - lastPushAt < 1000) return;
        lastPushAt = now;
        if (payload.event === 'switched') {
          const fromName = __i18n.providerNameFromId(payload.from) || payload.from || '';
          const toName = __i18n.providerNameFromId(payload.to) || payload.to || '';
          showToast(`${S('autoSwitchedToast', 'Provider auto-switched')}: ${fromName} → ${toName}`, 'success');
          // 总是刷新数据 (按钮跟着变), popover 只有关着才重建
          const popoverOpen = !!document.getElementById(ns.ids.providerPickerPopover);
          __i18n.refreshProviderPickerState({ rebuildPopover: !popoverOpen });
          __i18n.refreshCurrentProvider();
        } else if (payload.event === 'maintenance') {
          showToast(`${S('autoSwitchMaintenanceToast', 'Auto-switch paused')}: ${payload.reason || ''}`, 'error');
        } else if (payload.event === 'no-eligible') {
          showToast(S('autoSwitchNoEligibleToast', 'Current provider unhealthy, but no eligible candidate to switch — please check manually'), 'error');
        }
      });
    }
  })();
})();

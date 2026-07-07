// ==ShimX==
// @name        ShimX codex_enhance — core/guard
// @description 所有分片的入口。once guard + 初始化 window.__shimxCodex 命名空间根。
//              一旦 guard 通过, 后续分片才会执行;否则全部 early-return。
// @layer       core
// ==/ShimX==

(() => {
  // 全脚本 once guard。
  //
  // 重复执行的后果(每片都套, 此处只挡第一次):
  //   - 每个 ensureXxx 里的 addEventListener / MutationObserver 叠 N 份
  //   - window.fetch / XMLHttpRequest hook 链叠 N 层
  //   - 用户点一次按钮触发 N 次 handler → codex 自己看着像"狂发请求"
  //
  // 触发场景: 用户点 shimx 的"刷新 codex"或"注入"按钮, cdp_service 走
  // Page.addScriptToEvaluateOnNewDocument(累积式注册, reload 时全部执行) +
  // Runtime.evaluate(当前页立刻再来一次)。
  //
  // cdp_service 侧也做了去重(remove + add), 这里再加一层 IIFE 级别的 once
  // 是兜底, 任何路径走来都只装一次。
  if (window.__shimxCodexEnhanceLoaded) {
    if (typeof console !== 'undefined') {
      console.log('[ShimX] codex_enhance 已加载过, 跳过重复执行');
    }
    return;
  }
  window.__shimxCodexEnhanceLoaded = true;

  // 命名空间根。各分片往下挂自己的子命名空间, 不要替换整个 __shimxCodex 引用。
  // 子命名空间在各自分片里 init, 此处只保证根存在。
  window.__shimxCodex = window.__shimxCodex || {
    ids: {},
    bridge: null,
    i18n: null,
    ui: { toast: null, busy: null, confirm: null, panel: null },
    features: {
      badge: null,
      shimxMenu: null,
      pluginMenu: null,
      pluginPanel: null,
      polishButton: null,
      controlPanel: null,
      providerPicker: null,
      autoSwitch: null,
      threadRow: null,
      claudeBridge: null,
      projectMenuHook: null,
    },
    runtime: { plugins: null, scheduler: null, trace: null },
  };
})();

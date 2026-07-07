// ==ShimX==
// @name        ShimX codex_enhance — ui/panel_utils
// @description ShimX 控制面板 / Provider picker / Logs 等 UI 共享的小工具:
//              - statusTone* : 把 'success' | 'warning' | 'error' | 'info' | 'muted' 映射成
//                              前景色 / 浅背景 / 边框色 / 本地化标签
//              - currentCodexThreadLabel / codexThreadLabelById : 从 codex 侧栏取 thread 标题
//              - shortThreadId : 把超长 thread id 截成 "前 6 位 … 后 4 位"
// @layer       ui
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;
  const S = (k, f) => window.__shimxCodex.i18n.S(k, f);

  // 前景色: 亮/暗色模式都要有足够对比度的语义色。
  // 蓝/黄/红/灰选深一档的值,浅色模式白底也读得清。
  // default 走 codex token, 跟随主题的次级文字色。
  function statusToneColor(tone) {
    if (tone === 'success') return '#2563eb';
    if (tone === 'warning') return '#b45309';
    if (tone === 'error') return '#dc2626';
    if (tone === 'info') return '#475569';
    return 'var(--text-token-secondary, currentColor)';
  }

  // 背景/边框: 半透明中灰 `rgba(127,127,127,...)` 亮暗通用,
  // 语义色也统一改为半透明变体,亮色模式不刺眼、暗色模式也不至于消失。
  function statusToneSoftBackground(tone) {
    if (tone === 'success') return 'rgba(59,130,246,0.12)';
    if (tone === 'warning') return 'rgba(245,158,11,0.13)';
    if (tone === 'error') return 'rgba(239,68,68,0.13)';
    if (tone === 'info') return 'rgba(127,127,127,0.10)';
    return 'rgba(127,127,127,0.08)';
  }

  function statusToneBorder(tone) {
    if (tone === 'success') return 'rgba(59,130,246,0.28)';
    if (tone === 'warning') return 'rgba(245,158,11,0.34)';
    if (tone === 'error') return 'rgba(239,68,68,0.34)';
    if (tone === 'info') return 'rgba(127,127,127,0.22)';
    return 'rgba(127,127,127,0.18)';
  }

  function statusToneLabel(tone) {
    if (tone === 'success') return S('shimxControlStatusOk', 'OK');
    if (tone === 'warning') return S('shimxControlStatusWarn', 'Warn');
    if (tone === 'error') return S('shimxControlStatusError', 'Error');
    if (tone === 'info') return S('shimxControlStatusInfo', 'Info');
    return S('shimxControlStatusIdle', 'Idle');
  }

  function currentCodexThreadLabel() {
    const active = document.querySelector('[data-app-action-sidebar-thread-active="true"]');
    if (!active) return '';
    const title = active.getAttribute('data-app-action-sidebar-thread-title') ||
      active.querySelector('[data-thread-title]')?.textContent?.trim() ||
      active.textContent?.trim() ||
      '';
    return title.replace(/\s+/g, ' ').trim();
  }

  function codexThreadLabelById(threadId) {
    if (!threadId) return '';
    const rows = document.querySelectorAll('[data-app-action-sidebar-thread-id]');
    for (const row of rows) {
      const raw = row.getAttribute('data-app-action-sidebar-thread-id') || '';
      const id = raw.includes(':') ? raw.split(':').slice(1).join(':') : raw;
      if (id !== threadId) continue;
      const title = row.getAttribute('data-app-action-sidebar-thread-title') ||
        row.querySelector('[data-thread-title]')?.textContent?.trim() ||
        row.textContent?.trim() ||
        '';
      return title.replace(/\s+/g, ' ').trim();
    }
    return '';
  }

  function shortThreadId(id) {
    const text = String(id || '');
    if (text.length <= 10) return text;
    return `${text.slice(0, 6)}…${text.slice(-4)}`;
  }

  window.__shimxCodex.ui.panel = {
    statusToneColor,
    statusToneSoftBackground,
    statusToneBorder,
    statusToneLabel,
    currentCodexThreadLabel,
    codexThreadLabelById,
    shortThreadId,
  };
})();

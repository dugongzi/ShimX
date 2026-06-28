// ==Shim==
// @name        Shim codex_enhance — ui/panel_utils
// @description Shim 控制面板 / Provider picker / Logs 等 UI 共享的小工具:
//              - statusTone* : 把 'success' | 'warning' | 'error' | 'info' | 'muted' 映射成
//                              前景色 / 浅背景 / 边框色 / 本地化标签
//              - currentCodexThreadLabel / codexThreadLabelById : 从 codex 侧栏取 thread 标题
//              - shortThreadId : 把超长 thread id 截成 "前 6 位 … 后 4 位"
// @layer       ui
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const S = (k, f) => window.__shimCodex.i18n.S(k, f);

  function statusToneColor(tone) {
    if (tone === 'success') return '#93c5fd';
    if (tone === 'warning') return '#f59e0b';
    if (tone === 'error') return '#ef4444';
    if (tone === 'info') return '#cbd5e1';
    return 'var(--token-text-secondary, rgba(255,255,255,0.68))';
  }

  function statusToneSoftBackground(tone) {
    if (tone === 'success') return 'rgba(59,130,246,0.12)';
    if (tone === 'warning') return 'rgba(245,158,11,0.13)';
    if (tone === 'error') return 'rgba(239,68,68,0.13)';
    if (tone === 'info') return 'rgba(148,163,184,0.12)';
    return 'rgba(255,255,255,0.06)';
  }

  function statusToneBorder(tone) {
    if (tone === 'success') return 'rgba(59,130,246,0.28)';
    if (tone === 'warning') return 'rgba(245,158,11,0.34)';
    if (tone === 'error') return 'rgba(239,68,68,0.34)';
    if (tone === 'info') return 'rgba(148,163,184,0.22)';
    return 'rgba(255,255,255,0.08)';
  }

  function statusToneLabel(tone) {
    if (tone === 'success') return S('shimControlStatusOk', 'OK');
    if (tone === 'warning') return S('shimControlStatusWarn', 'Warn');
    if (tone === 'error') return S('shimControlStatusError', 'Error');
    if (tone === 'info') return S('shimControlStatusInfo', 'Info');
    return S('shimControlStatusIdle', 'Idle');
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

  window.__shimCodex.ui.panel = {
    statusToneColor,
    statusToneSoftBackground,
    statusToneBorder,
    statusToneLabel,
    currentCodexThreadLabel,
    codexThreadLabelById,
    shortThreadId,
  };
})();

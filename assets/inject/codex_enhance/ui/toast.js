// ==ShimX==
// @name        ShimX codex_enhance — ui/toast
// @description Toast 提示 (用 Codex 主题), 跨 feature 复用。
//              暴露 __shimxCodex.ui.toast.show(message, kind) / .ensureContainer()。
//              kind: 'info' | 'success' | 'error' | 'warning'。
// @layer       ui
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;
  const ids = window.__shimxCodex.ids;

  function ensureContainer() {
    let container = document.getElementById(ids.toastContainer);
    if (container) return container;
    container = document.createElement('div');
    container.id = ids.toastContainer;
    Object.assign(container.style, {
      position: 'fixed',
      top: '20px',
      left: '50%',
      transform: 'translateX(-50%)',
      zIndex: '2147483647',
      display: 'flex',
      flexDirection: 'column',
      gap: '8px',
      pointerEvents: 'none',
    });
    document.body.appendChild(container);
    return container;
  }

  function show(message, kind = 'info') {
    const container = ensureContainer();
    const toast = document.createElement('div');
    toast.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(toast.style, {
      padding: '10px 16px',
      borderRadius: '12px',
      fontSize: '13px',
      fontWeight: '500',
      maxWidth: '420px',
      outline: '0.5px solid var(--token-border, rgba(127,127,127,0.18))',
      boxShadow: '0 8px 24px rgba(0, 0, 0, 0.25)',
      pointerEvents: 'auto',
      borderLeft: `3px solid ${
        kind === 'error' ? '#ef4444' : kind === 'success' ? '#60a5fa' : '#3b82f6'
      }`,
      opacity: '0',
      transform: 'translateY(-8px)',
      transition: 'opacity 0.2s, transform 0.2s',
    });
    toast.textContent = message;
    container.appendChild(toast);
    requestAnimationFrame(() => {
      toast.style.opacity = '1';
      toast.style.transform = 'translateY(0)';
    });
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(-8px)';
      setTimeout(() => toast.remove(), 200);
    }, 3000);
  }

  window.__shimxCodex.ui.toast = { show, ensureContainer };
})();

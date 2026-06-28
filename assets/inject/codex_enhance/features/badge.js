// ==Shim==
// @name        Shim codex_enhance — features/badge
// @description "Shim Injected" 徽章。锚定在 Codex 工具栏「请求批准」按钮右侧, 没锚点时
//              退化为右下角 fixed。runtime/scheduler 在 ensureAll 里每轮 remove + ensure 一次。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;

  function buildBadge(inline) {
    const badge = document.createElement('span');
    badge.id = ids.badge;
    Object.assign(badge.style, {
      display: 'inline-flex',
      alignItems: 'center',
      gap: '6px',
      padding: '4px 10px',
      background: 'rgba(0, 0, 0, 0.72)',
      color: '#fff',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '12px',
      fontWeight: '600',
      borderRadius: '999px',
      boxShadow: '0 2px 6px rgba(0, 0, 0, 0.15)',
      pointerEvents: 'none',
      userSelect: 'none',
      whiteSpace: 'nowrap',
    });
    if (!inline) {
      Object.assign(badge.style, {
        position: 'fixed',
        right: '16px',
        bottom: '16px',
        zIndex: '2147483647',
      });
    }

    const dot = document.createElement('span');
    Object.assign(dot.style, {
      width: '8px',
      height: '8px',
      borderRadius: '50%',
      background: '#60a5fa',
      boxShadow: '0 0 6px rgba(96, 165, 250, 0.62)',
    });

    const text = document.createElement('span');
    text.textContent = 'Shim Injected';

    badge.appendChild(dot);
    badge.appendChild(text);
    return badge;
  }

  function findAnchor() {
    const paths = document.querySelectorAll('svg path');
    for (const path of paths) {
      const d = path.getAttribute('d');
      if (d && d.startsWith(ids.badgeAnchorSvgD)) {
        const button = path.closest('button');
        if (!button) continue;
        return button.parentElement;
      }
    }
    return null;
  }

  function ensure() {
    const existing = document.getElementById(ids.badge);
    const anchor = findAnchor();
    const trace = ns.runtime?.trace?.t;
    if (anchor) {
      if (existing && existing.parentElement === anchor) return;
      if (typeof trace === 'function') trace('ensureBadge: REPLACE inline', { hadExisting: !!existing });
      existing?.remove();
      anchor.appendChild(buildBadge(true));
      return;
    }
    if (existing) return;
    if (typeof trace === 'function') trace('ensureBadge: INSERT fixed (no anchor)');
    (document.body || document.documentElement).appendChild(buildBadge(false));
  }

  function remove() {
    document.getElementById(ids.badge)?.remove();
  }

  ns.features.badge = { ensure, remove };
})();

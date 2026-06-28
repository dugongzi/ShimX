// ==Shim==
// @name        Shim codex_enhance — features/thread_preview
// @description 当前对话左侧消息 minimap。监听当前 thread 的所有 turn, 渲染一栏可点击/可悬浮预览
//              的缩略列表; 跟随滚动同步高亮当前可视 turn, 点击跳转到对应 turn。
//              对外: ensure() — 由 runtime/scheduler 在 ensureAll 里每轮调一次。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;
  const S = (k, f) => ns.i18n.S(k, f);

  const ITEM_ATTR = ids.threadPreviewItemAttr;
  const ACTIVE_ATTR = ids.threadPreviewActiveAttr;
  const HIGHLIGHT_ATTR = ids.threadPreviewHighlightAttr;
  const PANEL_ID = ids.threadPreview;
  const LENS_ID = ids.threadPreviewLens;
  const PROVIDER_BADGE_CLASS = ids.providerBadgeClass;

  const state = {
    signature: '',
    scrollTarget: null,
    scrollHandler: null,
    activeFrame: 0,
    resizeInstalled: false,
    jumpTimer: 0,
  };

  function normalizePreviewText(text) {
    return String(text || '').replace(/\s+/g, ' ').trim();
  }

  function cssEscapeValue(value) {
    if (window.CSS && typeof window.CSS.escape === 'function') {
      return window.CSS.escape(String(value));
    }
    return String(value).replace(/["\\]/g, '\\$&');
  }

  function isVisibleBox(rect) {
    return rect && rect.width > 8 && rect.height > 8 &&
      rect.bottom > 0 && rect.right > 0 &&
      rect.top < window.innerHeight && rect.left < window.innerWidth;
  }

  function visibleTurns() {
    return Array.from(document.querySelectorAll('[data-turn-key]')).filter((turn) => {
      if (!(turn instanceof HTMLElement)) return false;
      if (!turn.isConnected) return false;
      const rect = turn.getBoundingClientRect();
      if (rect.width <= 20 || rect.height <= 8) return false;
      return normalizePreviewText(turn.textContent).length > 0;
    });
  }

  function turnKey(turn, index) {
    const raw = turn.getAttribute('data-turn-key') || '';
    return raw || String(index);
  }

  function previewTextForTurn(turn) {
    const clone = turn.cloneNode(true);
    clone.querySelectorAll?.([
      '.' + PROVIDER_BADGE_CLASS,
      '[' + HIGHLIGHT_ATTR + ']',
      '[aria-hidden="true"]',
      'button',
      'svg',
      'script',
      'style',
    ].join(',')).forEach((node) => node.remove());
    let text = normalizePreviewText(clone.textContent);
    if (!text) text = S('threadPreviewEmptyMessage', 'Empty message');
    return text.length > 240 ? text.slice(0, 237) + '...' : text;
  }

  function turnRole(turn, index, text) {
    const roleNode = turn.matches?.('[data-message-author-role], [data-author-role], [data-role]')
      ? turn
      : turn.querySelector?.('[data-message-author-role], [data-author-role], [data-role]');
    const rawRole = normalizePreviewText(
      roleNode?.getAttribute('data-message-author-role') ||
      roleNode?.getAttribute('data-author-role') ||
      roleNode?.getAttribute('data-role') ||
      turn.getAttribute('data-turn-role') ||
      turn.getAttribute('data-role') ||
      '',
    ).toLowerCase();
    const key = normalizePreviewText(turn.getAttribute('data-turn-key') || '').toLowerCase();
    const sample = normalizePreviewText(text).toLowerCase();
    const structural = `${rawRole} ${key}`;
    if (/\b(tool|function|command|bash|shell|powershell|terminal|exec)\b/.test(structural) ||
      /^(tool|function|command|bash|shell|powershell|terminal|exec|exit code|wall time|output)\b/.test(sample)) {
      return 'tool';
    }
    if (/\b(user|human|you)\b/.test(structural)) return 'user';
    if (/\b(assistant|ai|codex|agent)\b/.test(structural)) return 'assistant';
    return index % 2 === 0 ? 'user' : 'assistant';
  }

  function rolePreviewMeta(role) {
    if (role === 'tool') {
      return {
        icon: 'T',
        label: S('threadPreviewToolRole', 'Tool'),
        color: '#f59e0b',
        background: 'rgba(245, 158, 11, 0.14)',
      };
    }
    if (role === 'user') {
      return {
        icon: 'U',
        label: S('threadPreviewUserRole', 'User'),
        color: '#38bdf8',
        background: 'rgba(56, 189, 248, 0.14)',
      };
    }
    return {
      icon: 'A',
      label: S('threadPreviewAssistantRole', 'Assistant'),
      color: '#93c5fd',
      background: 'rgba(59, 130, 246, 0.12)',
    };
  }

  function previewGlyphForItem(item) {
    const chars = Array.from(normalizePreviewText(item?.text || ''));
    const first = chars.find((ch) => ch.trim().length > 0);
    return first || '?';
  }

  function turnPreviewItems(turns) {
    return turns.map((turn, index) => {
      const text = previewTextForTurn(turn);
      const role = turnRole(turn, index, text);
      return {
        key: turnKey(turn, index),
        turn,
        index,
        role,
        text,
      };
    });
  }

  function findScrollTarget(node) {
    let cur = node?.parentElement || null;
    while (cur && cur !== document.body && cur !== document.documentElement) {
      const style = window.getComputedStyle(cur);
      const overflow = `${style.overflowY} ${style.overflow}`;
      if (/(auto|scroll|overlay)/.test(overflow) && cur.scrollHeight > cur.clientHeight + 12) {
        return cur;
      }
      cur = cur.parentElement;
    }
    return window;
  }

  function navRightEdge() {
    const nav = document.querySelector('nav[role="navigation"], aside');
    const rect = nav?.getBoundingClientRect?.();
    if (rect && rect.width > 20) return Math.max(0, rect.right);
    return 0;
  }

  function messageContentLeft(turns, minLeft) {
    const selectors = [
      '[data-message-author-role]',
      '.prose',
      'article',
      'p',
      'pre',
      'code',
      'li',
      'h1',
      'h2',
      'h3',
      '[role="article"]',
    ].join(',');
    const candidates = [];
    for (const turn of turns.slice(0, 20)) {
      const nodes = [turn, ...Array.from(turn.querySelectorAll?.(selectors) || [])];
      for (const node of nodes) {
        if (!(node instanceof HTMLElement)) continue;
        const text = normalizePreviewText(node.textContent);
        if (text.length < 2) continue;
        const rect = node.getBoundingClientRect();
        if (!isVisibleBox(rect)) continue;
        if (rect.left <= minLeft + 40) continue;
        if (rect.width < 40 || rect.width > window.innerWidth * 0.86) continue;
        candidates.push(rect.left);
      }
    }
    if (!candidates.length) {
      const rects = turns.map((turn) => turn.getBoundingClientRect()).filter(isVisibleBox);
      if (!rects.length) return 0;
      return Math.min(...rects.map((rect) => rect.left));
    }
    candidates.sort((a, b) => a - b);
    return candidates[Math.floor(candidates.length * 0.2)];
  }

  function previewVerticalBounds(turns, scrollTarget) {
    let top = 68;
    let bottom = window.innerHeight - 112;
    if (scrollTarget && scrollTarget !== window) {
      const rect = scrollTarget.getBoundingClientRect();
      if (isVisibleBox(rect)) {
        top = Math.max(top, rect.top + 8);
        bottom = Math.min(bottom, rect.bottom - 8);
      }
    }
    const composer = document.querySelector('.composer-footer, form textarea')?.closest?.('form, .composer-footer') ||
      document.querySelector('.composer-footer');
    const composerRect = composer?.getBoundingClientRect?.();
    if (composerRect && composerRect.top > top) {
      bottom = Math.min(bottom, composerRect.top - 14);
    }
    const firstRect = turns[0]?.getBoundingClientRect?.();
    if (firstRect && firstRect.top > 0 && firstRect.top < window.innerHeight * 0.45) {
      top = Math.max(top, firstRect.top);
    }
    return { top, bottom };
  }

  function positionThreadPreview(panel, turns, scrollTarget) {
    const navRight = navRightEdge();
    const contentLeft = messageContentLeft(turns, navRight);
    const available = contentLeft - navRight - 24;
    const bounds = previewVerticalBounds(turns, scrollTarget);
    const height = bounds.bottom - bounds.top;
    if (!contentLeft || available < 196 || height < 120 || window.innerWidth < 980) {
      panel.style.display = 'none';
      hideThreadPreviewLens();
      return false;
    }
    const width = Math.min(280, Math.max(204, available - 10));
    const left = Math.max(navRight + 10, contentLeft - width - 14);
    Object.assign(panel.style, {
      display: 'flex',
      position: 'fixed',
      left: `${Math.round(left)}px`,
      top: `${Math.round(bounds.top)}px`,
      width: `${Math.round(width)}px`,
      maxHeight: `${Math.round(height)}px`,
      zIndex: '80',
    });
    return true;
  }

  function itemStyle(item, active) {
    Object.assign(item.style, {
      display: 'grid',
      gridTemplateColumns: '30px minmax(0, 1fr)',
      alignItems: 'center',
      gap: '9px',
      width: '100%',
      minHeight: '62px',
      padding: '9px 10px',
      border: active
        ? '1px solid rgba(59, 130, 246, 0.34)'
        : '1px solid var(--token-border, rgba(127, 127, 127, 0.18))',
      borderRadius: '12px',
      background: active
        ? 'linear-gradient(135deg, rgba(59,130,246,0.13), rgba(148,163,184,0.06))'
        : 'rgba(255,255,255,0.035)',
      color: active
        ? 'var(--token-text-primary, currentColor)'
        : 'var(--token-text-secondary, var(--text-secondary, currentColor))',
      cursor: 'pointer',
      font: '500 12px/1.35 system-ui, -apple-system, sans-serif',
      textAlign: 'left',
      opacity: active ? '1' : '0.76',
      transition: 'opacity 100ms ease, background 100ms ease, border-color 100ms ease, transform 100ms ease',
    });
  }

  function hideThreadPreviewLens() {
    document.getElementById(LENS_ID)?.remove();
  }

  function showThreadPreviewLens(anchor, item) {
    hideThreadPreviewLens();
    const rect = anchor.getBoundingClientRect();
    const meta = rolePreviewMeta(item.role);
    const lens = document.createElement('div');
    lens.id = LENS_ID;
    lens.setAttribute('role', 'tooltip');
    Object.assign(lens.style, {
      position: 'fixed',
      zIndex: '2147483000',
      left: `${Math.round(rect.right + 10)}px`,
      top: `${Math.round(rect.top + rect.height / 2)}px`,
      transform: 'translateY(-50%)',
      width: 'min(360px, calc(100vw - 48px))',
      maxHeight: '156px',
      overflow: 'hidden',
      padding: '10px 12px',
      borderRadius: '10px',
      border: '1px solid var(--token-border, rgba(127,127,127,0.28))',
      background: 'var(--token-main-surface-primary, var(--token-sidebar-surface-primary, rgba(17, 24, 39, 0.96)))',
      color: 'var(--token-text-primary, currentColor)',
      boxShadow: 'var(--shadow-xl, 0 16px 44px rgba(0,0,0,0.28))',
      backdropFilter: 'blur(10px)',
      pointerEvents: 'none',
      fontFamily: 'system-ui, -apple-system, sans-serif',
    });
    const header = document.createElement('div');
    Object.assign(header.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '7px',
      marginBottom: '6px',
      fontSize: '11px',
      fontWeight: '800',
      color: 'var(--text-secondary, currentColor)',
    });
    const dot = document.createElement('span');
    dot.textContent = previewGlyphForItem(item);
    Object.assign(dot.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '18px',
      height: '18px',
      borderRadius: '6px',
      background: meta.background,
      color: meta.color,
      fontSize: '10px',
      lineHeight: '1',
    });
    const label = document.createElement('span');
    label.textContent = `${meta.label} #${item.index + 1}`;
    header.appendChild(dot);
    header.appendChild(label);

    const text = document.createElement('div');
    text.textContent = item.text;
    Object.assign(text.style, {
      display: '-webkit-box',
      WebkitBoxOrient: 'vertical',
      WebkitLineClamp: '5',
      overflow: 'hidden',
      whiteSpace: 'normal',
      overflowWrap: 'anywhere',
      fontSize: '13px',
      fontWeight: '500',
      lineHeight: '1.45',
    });
    lens.appendChild(header);
    lens.appendChild(text);
    document.body.appendChild(lens);

    const lensRect = lens.getBoundingClientRect();
    let left = rect.right + 10;
    if (left + lensRect.width > window.innerWidth - 10) {
      left = rect.left - lensRect.width - 10;
    }
    let top = rect.top + rect.height / 2 - lensRect.height / 2;
    top = Math.max(8, Math.min(window.innerHeight - lensRect.height - 8, top));
    lens.style.left = `${Math.round(Math.max(8, left))}px`;
    lens.style.top = `${Math.round(top)}px`;
    lens.style.transform = 'none';
  }

  function activePreviewLabelColor(role) {
    return rolePreviewMeta(role).color || 'var(--token-text-primary, currentColor)';
  }

  function buildThreadPreviewItem(item) {
    const button = document.createElement('button');
    button.type = 'button';
    button.setAttribute(ITEM_ATTR, item.key);
    button.setAttribute('aria-label', `${rolePreviewMeta(item.role).label}: ${item.text}`);
    button.className = 'no-drag cursor-interaction';
    itemStyle(button, false);

    const meta = rolePreviewMeta(item.role);
    const icon = document.createElement('span');
    icon.textContent = meta.icon;
    Object.assign(icon.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      flex: '0 0 auto',
      width: '30px',
      height: '30px',
      borderRadius: '10px',
      background: meta.background,
      color: meta.color,
      fontSize: '12px',
      fontWeight: '800',
      lineHeight: '1',
    });

    button.appendChild(icon);

    const content = document.createElement('span');
    Object.assign(content.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      gap: '3px',
    });

    const headline = document.createElement('span');
    headline.textContent = `${meta.label} #${item.index + 1}`;
    Object.assign(headline.style, {
      display: 'block',
      color: activePreviewLabelColor(item.role),
      fontSize: '11px',
      fontWeight: '800',
      lineHeight: '1.1',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
    });

    const summary = document.createElement('span');
    summary.textContent = item.text;
    Object.assign(summary.style, {
      display: '-webkit-box',
      WebkitBoxOrient: 'vertical',
      WebkitLineClamp: '2',
      overflow: 'hidden',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.66))',
      fontSize: '12px',
      lineHeight: '1.35',
      overflowWrap: 'anywhere',
    });
    content.appendChild(headline);
    content.appendChild(summary);
    button.appendChild(content);

    button.addEventListener('mouseenter', () => {
      if (button.getAttribute(ACTIVE_ATTR) !== '1') {
        button.style.background = 'rgba(255,255,255,0.075)';
        button.style.opacity = '1';
        button.style.transform = 'translateX(2px)';
      }
      showThreadPreviewLens(button, item);
    });
    button.addEventListener('mouseleave', () => {
      const active = button.getAttribute(ACTIVE_ATTR) === '1';
      itemStyle(button, active);
      hideThreadPreviewLens();
    });
    button.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      const target = document.querySelector(`[data-turn-key="${cssEscapeValue(item.key)}"]`);
      if (!target) return;
      target.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'auto' });
      flashThreadPreviewTarget(target);
      requestAnimationFrame(() => updateThreadPreviewActive());
    }, true);
    return button;
  }

  function buildThreadPreviewPanel(items) {
    const panel = document.createElement('div');
    panel.id = PANEL_ID;
    panel.setAttribute('role', 'navigation');
    panel.setAttribute('aria-label', S('threadPreviewAria', 'Conversation preview'));
    Object.assign(panel.style, {
      alignItems: 'stretch',
      flexDirection: 'column',
      gap: '8px',
      padding: '10px',
      overflowX: 'hidden',
      overflowY: 'auto',
      overscrollBehavior: 'contain',
      borderRadius: '18px',
      border: '1px solid var(--token-border, rgba(127,127,127,0.18))',
      background:
        'linear-gradient(180deg, rgba(255,255,255,0.085), rgba(255,255,255,0.038)), var(--token-sidebar-surface-primary, rgba(18,18,18,0.9))',
      boxShadow: '0 18px 46px rgba(0,0,0,0.28), inset 0 1px 0 rgba(255,255,255,0.08)',
      backdropFilter: 'blur(12px)',
      userSelect: 'none',
      scrollbarWidth: 'none',
    });
    panel.style.msOverflowStyle = 'none';
    panel.addEventListener('wheel', (event) => {
      const atTop = panel.scrollTop === 0 && event.deltaY < 0;
      const atBottom = panel.scrollTop + panel.clientHeight >= panel.scrollHeight - 1 && event.deltaY > 0;
      if (!atTop && !atBottom) event.stopPropagation();
    }, { passive: true });

    const fragment = document.createDocumentFragment();
    for (const item of items) {
      fragment.appendChild(buildThreadPreviewItem(item));
    }
    panel.appendChild(fragment);
    return panel;
  }

  function flashThreadPreviewTarget(target) {
    if (!(target instanceof HTMLElement)) return;
    target.setAttribute(HIGHLIGHT_ATTR, '1');
    const previousOutline = target.style.outline;
    const previousOutlineOffset = target.style.outlineOffset;
    target.style.outline = '2px solid var(--token-text-secondary, currentColor)';
    target.style.outlineOffset = '4px';
    clearTimeout(state.jumpTimer);
    state.jumpTimer = setTimeout(() => {
      target.style.outline = previousOutline;
      target.style.outlineOffset = previousOutlineOffset;
      target.removeAttribute(HIGHLIGHT_ATTR);
    }, 900);
  }

  function updateThreadPreviewActive() {
    const panel = document.getElementById(PANEL_ID);
    if (!panel || panel.style.display === 'none') return;
    const turns = visibleTurns();
    if (!turns.length) return;
    const scrollTarget = state.scrollTarget || findScrollTarget(turns[0]);
    let center = window.innerHeight / 2;
    let viewportTop = 0;
    let viewportBottom = window.innerHeight;
    if (scrollTarget && scrollTarget !== window) {
      const rect = scrollTarget.getBoundingClientRect();
      center = rect.top + rect.height / 2;
      viewportTop = rect.top;
      viewportBottom = rect.bottom;
    }

    let activeKey = '';
    let activeDistance = Number.POSITIVE_INFINITY;
    for (let i = 0; i < turns.length; i += 1) {
      const rect = turns[i].getBoundingClientRect();
      if (rect.bottom < viewportTop || rect.top > viewportBottom) continue;
      const distance = Math.abs((rect.top + rect.bottom) / 2 - center);
      if (distance < activeDistance) {
        activeDistance = distance;
        activeKey = turnKey(turns[i], i);
      }
    }
    if (!activeKey) return;

    const buttons = panel.querySelectorAll('[' + ITEM_ATTR + ']');
    for (const button of buttons) {
      const active = button.getAttribute(ITEM_ATTR) === activeKey;
      button.setAttribute(ACTIVE_ATTR, active ? '1' : '0');
      itemStyle(button, active);
      if (active) {
        const top = button.offsetTop;
        const bottom = top + button.offsetHeight;
        if (top < panel.scrollTop || bottom > panel.scrollTop + panel.clientHeight) {
          panel.scrollTop = Math.max(0, top - panel.clientHeight / 2 + button.offsetHeight / 2);
        }
      }
    }
  }

  function scheduleThreadPreviewActiveUpdate() {
    if (state.activeFrame) return;
    state.activeFrame = requestAnimationFrame(() => {
      state.activeFrame = 0;
      updateThreadPreviewActive();
    });
  }

  function attachThreadPreviewScrollSync(scrollTarget) {
    if (state.scrollTarget === scrollTarget && state.scrollHandler) {
      return;
    }
    if (state.scrollTarget && state.scrollHandler) {
      state.scrollTarget.removeEventListener?.('scroll', state.scrollHandler);
    }
    state.scrollTarget = scrollTarget;
    state.scrollHandler = scheduleThreadPreviewActiveUpdate;
    scrollTarget.addEventListener?.('scroll', state.scrollHandler, { passive: true });
    if (!state.resizeInstalled) {
      state.resizeInstalled = true;
      window.addEventListener('resize', () => {
        // runtime/scheduler 还可能没就绪 (例如剥离过程中); 防御性可选链。
        ns.runtime?.scheduler?.runEnsureAll?.('thread-preview-resize');
      }, { passive: true });
      window.addEventListener('scroll', scheduleThreadPreviewActiveUpdate, { passive: true });
    }
  }

  function removeThreadPreview() {
    document.getElementById(PANEL_ID)?.remove();
    hideThreadPreviewLens();
    state.signature = '';
    if (state.scrollTarget && state.scrollHandler) {
      state.scrollTarget.removeEventListener?.('scroll', state.scrollHandler);
    }
    state.scrollTarget = null;
    state.scrollHandler = null;
  }

  function ensure() {
    const turns = visibleTurns();
    if (turns.length < 2) {
      removeThreadPreview();
      return;
    }
    const items = turnPreviewItems(turns);
    const signature = items
      .map((item) => `${item.key}:${item.role}:${item.text.slice(0, 80)}`)
      .join('|');
    const scrollTarget = findScrollTarget(turns[0]);
    let panel = document.getElementById(PANEL_ID);
    if (!panel || state.signature !== signature) {
      panel?.remove();
      panel = buildThreadPreviewPanel(items);
      document.body.appendChild(panel);
      state.signature = signature;
    }
    const visible = positionThreadPreview(panel, turns, scrollTarget);
    attachThreadPreviewScrollSync(scrollTarget);
    if (visible) scheduleThreadPreviewActiveUpdate();
  }

  ns.features.threadPreview = { ensure };
})();

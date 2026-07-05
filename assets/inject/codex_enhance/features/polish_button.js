// ==Shim==
// @name        Shim codex_enhance — features/polish_button
// @description 在 shim provider picker 按钮右边挂一个润色按钮:
//              点击 → 弹风格 popover(更简洁 / 更正式 / 更口语 / 更详细) →
//              选后从 composer 拿原文 → bridge.call('/polish/text') →
//              弹预览 dialog(原文 vs 润色后)→ 用户确认才写回 composer。
//              对外: ensure() — 由 runtime/scheduler 每轮调一次。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;
  const S = (k, f) => ns.i18n.S(k, f);
  const BUTTON_ID = ids.polishButton;
  const POPOVER_ID = ids.polishPopover;
  const COMPOSER_SELECTOR = '[data-codex-composer="true"]';

  // 魔法棒 + 星星 svg, 用 currentColor 跟随 codex 主题 text 色
  const ICON_SVG =
    '<svg viewBox="0 0 1024 1024" width="18" height="18" fill="currentColor" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M768 972.8l-73.159111-131.640889L563.2 768l131.640889-73.159111L768 563.2l73.159111 131.640889L972.8 768l-131.640889 73.159111L768 972.8z m-51.2-204.8l29.240889 14.620444 14.677333 29.240889 14.620445-29.240889 29.240889-14.620444-29.240889-14.620444-14.620445-29.240889-14.677333 29.240889-29.240889 14.620444z m-373.020444 73.159111l-117.020445-212.138667L14.620444 512l212.138667-117.020444 117.020445-212.138667L460.8 394.979556 665.6 512l-212.081778 117.020444-109.738666 212.138667zM168.220444 512l109.738667 58.538667 58.481778 109.681777 58.538667-109.681777L512 512 402.318222 453.461333 343.779556 343.779556 285.240889 453.404444 168.220444 512z m555.918223-138.979556l-58.538667-102.4L563.2 212.195556 665.6 153.6 724.195556 51.2l58.481777 102.4 102.4 58.538667-102.4 58.481777-58.481777 102.4z"/>' +
    '<path d="M768 219.420444c0 21.959111-14.620444 36.579556-36.579556 36.579556s-36.579556-14.620444-36.579555-36.579556 14.620444-36.579556 36.579555-36.579555 36.579556 14.620444 36.579556 36.579555z m109.681778 570.481778c-36.522667 51.2-51.2 51.2-109.681778 51.2-58.538667 0-73.159111 0-109.738667-51.2 0-58.481778 51.2-109.681778 109.738667-109.681778 58.481778 0 109.681778 43.861333 109.681778 109.681778z"/>' +
    '</svg>';

  const STYLE_KEYS = [
    { key: 'polishStyleConcise', fallback: '更简洁' },
    { key: 'polishStyleFormal', fallback: '更正式' },
    { key: 'polishStyleCasual', fallback: '更口语' },
    { key: 'polishStyleDetailed', fallback: '更详细' },
  ];

  function findAnchor() {
    return document.getElementById(ids.providerPicker);
  }

  function findComposer() {
    return document.querySelector(COMPOSER_SELECTOR);
  }

  function readComposerText() {
    const composer = findComposer();
    if (!composer) return '';
    // ProseMirror 里 <br class="ProseMirror-trailingBreak"> 或 placeholder 类应视作空
    if (composer.querySelector('p.placeholder')) return '';
    return (composer.innerText || composer.textContent || '').trim();
  }

  function writeComposerText(text) {
    const composer = findComposer();
    if (!composer) return false;
    // ProseMirror 期望 <p> 包着的段落。用 DOM API 而不是 innerHTML,少踩 XSS/react 冲突
    composer.innerHTML = '';
    const paragraphs = text.split(/\r?\n/);
    for (const line of paragraphs) {
      const p = document.createElement('p');
      if (line.length === 0) {
        const br = document.createElement('br');
        br.className = 'ProseMirror-trailingBreak';
        p.appendChild(br);
      } else {
        p.textContent = line;
      }
      composer.appendChild(p);
    }
    // 触发 input / focus 让 codex 内部 state 感知
    composer.dispatchEvent(new Event('input', { bubbles: true }));
    composer.dispatchEvent(new Event('change', { bubbles: true }));
    return true;
  }

  // ---------- button ----------

  function buildButton() {
    const btn = document.createElement('button');
    btn.id = BUTTON_ID;
    btn.type = 'button';
    btn.setAttribute('aria-label', S('polishTooltip', 'Polish composer text'));
    btn.title = S('polishTooltip', 'Polish composer text');
    btn.className =
      'no-drag cursor-interaction flex items-center justify-center rounded-full text-token-foreground enabled:hover:bg-token-list-hover-background focus:outline-none';
    Object.assign(btn.style, {
      width: '32px',
      height: '32px',
      border: '1px solid var(--token-border, rgba(127,127,127,0.28))',
      background: 'transparent',
      marginLeft: '6px',
      padding: '0',
    });
    btn.innerHTML = ICON_SVG;
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      togglePopover(btn);
    });
    return btn;
  }

  function ensure() {
    const anchor = findAnchor();
    if (!anchor) return;
    const existing = document.getElementById(BUTTON_ID);
    if (existing && existing.previousElementSibling === anchor) return;
    if (existing) existing.remove();
    const btn = buildButton();
    anchor.insertAdjacentElement('afterend', btn);
  }

  // ---------- popover ----------

  function dismissPopover() {
    document.getElementById(POPOVER_ID)?.remove();
    document.removeEventListener('mousedown', onPopoverOutside, true);
    document.removeEventListener('keydown', onPopoverKey, true);
  }

  function onPopoverOutside(event) {
    const pop = document.getElementById(POPOVER_ID);
    const btn = document.getElementById(BUTTON_ID);
    if (!pop) return;
    if (pop.contains(event.target)) return;
    if (btn && btn.contains(event.target)) return;
    dismissPopover();
  }

  function onPopoverKey(event) {
    if (event.key === 'Escape') dismissPopover();
  }

  function buildPopover() {
    const pop = document.createElement('div');
    pop.id = POPOVER_ID;
    pop.className =
      'bg-token-dropdown-background text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(pop.style, {
      position: 'fixed',
      zIndex: '2147483647',
      minWidth: '140px',
      padding: '6px',
      borderRadius: '10px',
      outline: '0.5px solid var(--token-border, rgba(0,0,0,0.08))',
      boxShadow: '0 12px 32px rgba(0, 0, 0, 0.24)',
      fontSize: '13px',
      display: 'flex',
      flexDirection: 'column',
      gap: '2px',
    });
    for (const item of STYLE_KEYS) {
      const label = S(item.key, item.fallback);
      const row = document.createElement('button');
      row.type = 'button';
      row.textContent = label;
      // hover 走 codex 官方 token,亮暗自适应
      row.className =
        'no-drag cursor-interaction hover:bg-token-list-hover-background text-token-foreground focus:outline-none';
      Object.assign(row.style, {
        display: 'block',
        width: '100%',
        textAlign: 'left',
        padding: '8px 12px',
        borderRadius: '6px',
        border: '0',
        background: 'transparent',
        cursor: 'pointer',
        fontSize: '13px',
      });
      row.addEventListener('click', () => {
        dismissPopover();
        runPolish(label);
      });
      pop.appendChild(row);
    }
    return pop;
  }

  function positionPopover(pop, anchor) {
    const rect = anchor.getBoundingClientRect();
    const popRect = pop.getBoundingClientRect();
    let top = Math.round(rect.top - popRect.height - 6);
    if (top < 8) top = Math.round(rect.bottom + 6);
    let left = Math.round(rect.right - popRect.width);
    if (left < 8) left = 8;
    pop.style.left = left + 'px';
    pop.style.top = top + 'px';
  }

  function togglePopover(anchor) {
    if (document.getElementById(POPOVER_ID)) {
      dismissPopover();
      return;
    }
    const pop = buildPopover();
    document.body.appendChild(pop);
    positionPopover(pop, anchor);
    document.addEventListener('mousedown', onPopoverOutside, true);
    document.addEventListener('keydown', onPopoverKey, true);
  }

  // ---------- polish flow ----------

  async function runPolish(instruction) {
    const text = readComposerText();
    if (!text) {
      ns.ui?.toast?.show?.(
        S('polishEmptyInput', 'Type something in the composer first'),
        'warning',
      );
      return;
    }
    // 没在 shim 选桶时,代理走 passthrough,body.model 会原样透传给上游,
    // 而润色用的 'shim-polish' 是假名,上游必然 404。让用户先选一个。
    const shimModel = ns.i18n?.currentProvider?.()?.selectedModel || '';
    if (!shimModel) {
      ns.ui?.toast?.show?.(
        S('polishNoProvider', 'Pick a shim provider first to polish'),
        'warning',
      );
      return;
    }
    const busyToken = ns.ui?.busy?.show?.(S('polishBusy', 'Polishing…'));
    let res;
    try {
      res = await ns.bridge.call(
        '/polish/text',
        { text, instruction },
        60 * 1000,
      );
    } catch (e) {
      if (busyToken != null) ns.ui?.busy?.hide?.(busyToken);
      ns.ui?.toast?.show?.(
        `${S('polishFailed', 'Polish failed')}: ${(e && e.message) || String(e)}`,
        'error',
      );
      return;
    }
    if (busyToken != null) ns.ui?.busy?.hide?.(busyToken);
    if (!res || !res.ok) {
      ns.ui?.toast?.show?.(
        `${S('polishFailed', 'Polish failed')}: ${(res && res.message) || ''}`,
        'error',
      );
      return;
    }
    const polished = res.data && res.data.polished;
    if (typeof polished !== 'string' || polished.trim().length === 0) {
      ns.ui?.toast?.show?.(S('polishFailed', 'Polish failed'), 'error');
      return;
    }
    showPreviewDialog(text, polished.trim());
  }

  // ---------- preview dialog ----------

  function showPreviewDialog(original, polished) {
    const overlay = document.createElement('div');
    Object.assign(overlay.style, {
      position: 'fixed',
      inset: '0',
      zIndex: '2147483647',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'rgba(0, 0, 0, 0.32)',
      backdropFilter: 'blur(2px)',
    });

    const dialog = document.createElement('div');
    dialog.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(dialog.style, {
      width: 'min(720px, calc(100vw - 40px))',
      maxHeight: 'calc(100vh - 80px)',
      padding: '20px 22px',
      borderRadius: '16px',
      outline: '0.5px solid var(--token-border, rgba(127,127,127,0.08))',
      boxShadow: '0 24px 64px rgba(0, 0, 0, 0.35)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      display: 'flex',
      flexDirection: 'column',
      gap: '14px',
    });

    const heading = document.createElement('div');
    heading.textContent = S('polishPreviewTitle', 'Polish preview');
    heading.className = 'text-token-foreground';
    Object.assign(heading.style, {
      fontSize: '15px',
      fontWeight: '700',
    });
    dialog.appendChild(heading);

    dialog.appendChild(buildDiffSection(S('polishOriginal', 'Original'), original, false));
    dialog.appendChild(buildDiffSection(S('polishPolished', 'Polished'), polished, true));

    const actions = document.createElement('div');
    Object.assign(actions.style, {
      display: 'flex',
      justifyContent: 'flex-end',
      gap: '8px',
    });

    // 按钮不依赖 codex 的 tailwind token(暗色下 bg-token-foreground 变纯黑、
    // text-token-background 不生效会让按钮变没文字的黑椭圆),
    // 全部内联样式对齐 shim popover 里的控件风格。
    const cancelBtn = document.createElement('button');
    cancelBtn.type = 'button';
    cancelBtn.textContent = S('polishCancel', 'Cancel');
    cancelBtn.className = 'no-drag cursor-interaction';
    Object.assign(cancelBtn.style, {
      height: '30px',
      padding: '0 14px',
      border: '1px solid rgba(127, 127, 127, 0.30)',
      borderRadius: '999px',
      background: 'rgba(127, 127, 127, 0.10)',
      color: 'inherit',
      fontSize: '13px',
      fontWeight: '600',
      cursor: 'pointer',
    });

    const okBtn = document.createElement('button');
    okBtn.type = 'button';
    okBtn.textContent = S('polishReplace', 'Replace');
    okBtn.className = 'no-drag cursor-interaction';
    Object.assign(okBtn.style, {
      height: '30px',
      padding: '0 16px',
      border: '1px solid rgba(59, 130, 246, 0.55)',
      borderRadius: '999px',
      background: '#2563eb',
      color: '#ffffff',
      fontSize: '13px',
      fontWeight: '700',
      cursor: 'pointer',
    });

    actions.appendChild(cancelBtn);
    actions.appendChild(okBtn);
    dialog.appendChild(actions);
    overlay.appendChild(dialog);
    document.body.appendChild(overlay);

    const cleanup = () => {
      document.removeEventListener('keydown', onKey, true);
      overlay.remove();
    };
    const onKey = (e) => {
      if (e.key === 'Escape') cleanup();
      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        writeComposerText(polished);
        cleanup();
      }
    };
    overlay.addEventListener('mousedown', (e) => {
      if (e.target === overlay) cleanup();
    });
    cancelBtn.addEventListener('click', cleanup);
    okBtn.addEventListener('click', () => {
      writeComposerText(polished);
      cleanup();
    });
    document.addEventListener('keydown', onKey, true);
    setTimeout(() => okBtn.focus(), 0);
  }

  function buildDiffSection(title, text, highlight) {
    const wrap = document.createElement('div');
    const lbl = document.createElement('div');
    lbl.textContent = title;
    lbl.className = 'text-token-text-secondary';
    Object.assign(lbl.style, {
      fontSize: '11px',
      fontWeight: '700',
      letterSpacing: '0.4px',
      marginBottom: '4px',
      textTransform: 'uppercase',
    });
    // 原文用 codex 次级面板 token,润色后叠一层 5% 前景色高亮
    // 两种在亮暗色下都会自动反色,无硬编码
    const box = document.createElement('div');
    box.textContent = text;
    box.className = highlight
      ? 'bg-token-foreground/5 text-token-foreground'
      : 'bg-token-main-surface-secondary text-token-foreground';
    Object.assign(box.style, {
      padding: '12px 14px',
      borderRadius: '10px',
      border: '1px solid var(--token-border, rgba(127,127,127,0.14))',
      fontSize: '13px',
      lineHeight: '1.55',
      whiteSpace: 'pre-wrap',
      maxHeight: '28vh',
      overflow: 'auto',
    });
    wrap.appendChild(lbl);
    wrap.appendChild(box);
    return wrap;
  }

  ns.features.polishButton = { ensure };
})();

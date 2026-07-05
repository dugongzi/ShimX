// ==Shim==
// @name        Shim codex_enhance — features/claude_bridge
// @description Claude 桥功能合并:
//              1) 侧栏 nav 列表里加一个折叠按钮 (展开 ~/.claude/projects/ 下的项目分组 + 会话)
//              2) composer 旁挂一个"绑定状态 chip", 按 codex thread 维度记录绑定的 claude 会话
//              点会话 → /claude-bridge/bind 把当前 codex thread 绑到这个 claude 会话
//              点 chip × → /claude-bridge/unbind 解绑当前 codex thread
//
//              对外暴露 ensureNav / ensureChip / findNavList / currentCodexThreadId /
//              applyStateForThread, 给 ensureAll / shim_menu / control_panel 用。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;
  const S = (k, f) => ns.i18n.S(k, f);
  const showToast = (msg, kind) => ns.ui.toast.show(msg, kind);

  const NAV_BTN_ID = ids.navBtn;
  const NAV_PANEL_ID = ids.navPanel;
  const CLAUDE_BRIDGE_CHIP_ID = ids.claudeBridgeChip;

  // ---------- nav 按钮 + 折叠面板 ----------

  // 找到 codex 自带 nav 按钮所在的列表容器 (包含"新对话/搜索"按钮的 .flex.flex-col.gap-px)。
  // 我们把"Claude 桥"按钮追加到该容器末尾, 折叠面板紧跟其后。
  //
  // 历史: codex 之前给行用 .h-token-nav-row, 后来换成 Tailwind 任意值
  // .h-[var(--height-token-row)], 并去掉了外层 nav[role="navigation"]。
  // 这里两个签名都接受, 先用旧的找, 找不到再退到新的; 最后兜底用 gap-px 容器里
  // 的 h-* 行作为锚点。
  function findCodexNavList() {
    let sample = document.querySelector(
      'nav[role="navigation"] button.h-token-nav-row.w-full',
    );
    if (!sample) {
      sample = document.querySelector(
        'div.flex.flex-col.gap-px > button.w-full[class*="h-[var(--height-token-row)]"]',
      );
    }
    if (!sample) {
      sample = document.querySelector('div.flex.flex-col.gap-px > button.w-full');
    }
    if (!sample) return null;
    return sample.closest('div.flex.flex-col.gap-px') || sample.parentElement;
  }

  function ensureNav() {
    const navList = findCodexNavList();
    if (!navList) return;
    if (document.getElementById(NAV_BTN_ID)) return; // 已注入

    const btn = renderClaudeBridgeButton();
    navList.appendChild(btn);
  }

  function renderClaudeBridgeButton() {
    const btn = document.createElement('button');
    btn.id = NAV_BTN_ID;
    btn.type = 'button';
    btn.className =
      'focus-visible:outline-token-border relative h-token-nav-row px-row-x py-row-y cursor-interaction shrink-0 items-center overflow-hidden rounded-lg text-left text-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50 gap-2 flex w-full hover:bg-token-list-hover-background';
    btn.innerHTML = `
      <div class="flex min-w-0 items-center text-base gap-2 flex-1 text-token-foreground">
        <svg width="16" height="16" viewBox="0 0 1024 1024" class="icon-xs" xmlns="http://www.w3.org/2000/svg">
          <path d="M252.8 652.8l167.893333-94.293333 2.773334-8.106667-2.773334-4.48h-8.106666l-28.16-1.706667-96-2.56-83.2-3.413333-80.64-4.266667-20.266667-4.266666L85.333333 504.746667l1.92-12.586667 17.066667-11.52 24.32 2.133333 53.973333 3.626667 81.066667 5.546667 58.666667 3.413333 87.04 9.173333h13.866666l1.92-5.546666-4.693333-3.413334-3.626667-3.413333-83.84-56.746667-90.666666-60.16-47.573334-34.56-25.813333-17.493333-13.013333-16.426667-5.546667-35.84 23.253333-25.813333 31.36 2.133333 7.893334 2.133334 31.786666 24.32 67.84 52.48L401.066667 391.466667l13.013333 10.88 5.12-3.626667 0.64-2.56-5.76-9.813333-48.213333-87.04L314.453333 210.773333l-22.826666-36.693333-5.973334-21.973333a107.861333 107.861333 0 0 1-3.626666-26.026667l26.666666-36.053333L323.413333 85.333333l35.413334 4.693334 14.933333 13.013333 21.973333 50.346667 35.626667 79.36 55.253333 107.733333 16.213334 32 8.746666 29.653333 3.2 9.173334h5.546667v-5.12l4.48-60.8 8.32-74.453334 8.106667-96 2.773333-27.093333 13.44-32.426667 26.666667-17.493333 20.693333 10.026667 17.066667 24.32-2.346667 15.786666-10.24 65.92-19.84 103.253334-13.013333 69.12h7.466666l8.746667-8.746667 34.986667-46.506667 58.666666-73.386666 26.026667-29.226667 30.293333-32.213333 19.413334-15.36h36.693333l27.093333 40.106666-12.16 41.386667-37.76 48-31.36 40.533333-45.013333 60.586667-28.16 48.426667 2.56 3.84 6.613333-0.64 101.546667-21.546667 54.826667-10.026667 65.493333-11.306666 29.653333 13.866666 3.2 14.08-11.733333 28.8-69.973333 17.28-82.133334 16.426667-122.24 29.013333-1.493333 1.066667 1.706667 2.133333 55.04 5.12 23.466666 1.28h57.6l107.306667 7.893334 28.16 18.56 16.853333 22.613333-2.773333 17.28-43.306667 21.973333-58.24-13.866666-136.106666-32.426667-46.72-11.733333h-6.4v3.84l38.826666 37.973333 71.253334 64.426667 89.173333 82.986666 4.48 20.48-11.52 16.213334-12.16-1.706667-78.506667-58.88-30.293333-26.666667-68.48-57.6h-4.48v5.973334l15.786667 23.04 83.413333 125.226666 4.266667 38.4-5.973334 12.586667-21.546666 7.466667-23.68-4.266667-48.853334-68.48-50.346666-77.226667-40.533334-69.12-4.906666 2.773334-23.893334 258.133333-11.306666 13.226667-26.026667 10.026666-21.546667-16.426666-11.52-26.666667 11.52-52.48 13.866667-68.48 11.306667-54.4 10.24-67.626667 5.973333-22.4-0.426667-1.493333-4.906666 0.64-50.986667 69.973333-77.653333 104.746667-61.44 65.706667-14.72 5.76-25.386667-13.226667 2.346667-23.466667 14.293333-20.906666 84.906667-107.946667 51.2-66.986667 33.066666-38.613333v-5.546667h-2.133333l-225.493333 146.56-40.106667 5.12-17.28-16.213333 2.133333-26.666667 8.106667-8.746666 67.84-46.72h-0.213333l0.853333 0.853333z" fill="#D97757"/>
        </svg>
        <span class="truncate">${S('claudeBridgeNavLabel', 'Claude bridge')}</span>
        <span class="ml-auto opacity-60" data-claude-bridge-chevron>▸</span>
      </div>
    `;
    btn.addEventListener('click', () => toggleClaudeBridgePanel(btn));
    return btn;
  }

  function toggleClaudeBridgePanel(btn) {
    const existing = document.getElementById(NAV_PANEL_ID);
    const chevron = btn.querySelector('[data-claude-bridge-chevron]');
    if (existing) {
      existing.remove();
      if (chevron) chevron.textContent = '▸';
      return;
    }
    const panel = document.createElement('div');
    panel.id = NAV_PANEL_ID;
    panel.style.cssText =
      'margin: 4px 0 6px 12px; padding: 6px 0; border-left: 1px solid var(--token-border, rgba(127,127,127,0.22)); max-height: 50vh; overflow-y: auto; overscroll-behavior: contain;';
    // codex 的 sidebar 容器可能拦截 wheel 事件, 这里阻止冒泡, 保证内部能滚
    panel.addEventListener(
      'wheel',
      (e) => {
        const atTop = panel.scrollTop === 0 && e.deltaY < 0;
        const atBottom =
          panel.scrollTop + panel.clientHeight >= panel.scrollHeight - 1 &&
          e.deltaY > 0;
        if (!atTop && !atBottom) e.stopPropagation();
      },
      { passive: true },
    );
    panel.innerHTML = `<div style="padding: 6px 10px; opacity: 0.7; font-size: 12px;">${S('claudeBridgeLoading', 'Loading…')}</div>`;
    btn.insertAdjacentElement('afterend', panel);
    if (chevron) chevron.textContent = '▾';

    loadClaudeProjects()
      .then((projects) => renderClaudeProjects(panel, projects))
      .catch((error) => renderClaudeError(panel, error));
  }

  async function loadClaudeProjects() {
    if (typeof window.shim !== 'function') {
      throw new Error('shim bridge not ready');
    }
    const res = await window.shim('/claude-session/projects', {});
    if (!res || res.code !== 0) {
      throw new Error(res?.message || 'rpc error');
    }
    return (res.data && res.data.projects) || [];
  }

  async function loadClaudeThreads(encodedDir) {
    const res = await window.shim('/claude-session/threads', { encodedDir });
    if (!res || res.code !== 0) {
      throw new Error(res?.message || 'rpc error');
    }
    return (res.data && res.data.threads) || [];
  }

  function renderClaudeError(panel, error) {
    panel.innerHTML = '';
    const div = document.createElement('div');
    div.style.cssText =
      'padding: 6px 10px; font-size: 12px; color: var(--token-error, #ef4444);';
    div.textContent =
      S('claudeBridgeErrorPrefix', 'Load failed: ') + (error?.message || String(error));
    panel.appendChild(div);
  }

  function renderClaudeProjects(panel, projects) {
    panel.innerHTML = '';
    if (!projects.length) {
      const empty = document.createElement('div');
      empty.style.cssText = 'padding: 6px 10px; opacity: 0.7; font-size: 12px;';
      empty.textContent = S('claudeBridgeEmpty', 'No Claude Code sessions found');
      panel.appendChild(empty);
      return;
    }
    for (const p of projects) {
      panel.appendChild(renderClaudeProjectRow(p));
    }
  }

  function renderClaudeProjectRow(project) {
    const wrap = document.createElement('div');
    wrap.style.cssText = 'display: flex; flex-direction: column;';

    const row = document.createElement('button');
    row.type = 'button';
    row.className =
      'cursor-pointer hover:bg-token-list-hover-background rounded-md';
    row.style.cssText =
      'text-align: left; padding: 6px 10px; display: flex; align-items: center; gap: 6px; font-size: 13px; color: var(--token-foreground); width: 100%; border: 0; background: transparent;';
    const lastSeg = projectLastSegment(project.cwd) || project.encodedDir;
    row.innerHTML = `
      <span data-claude-project-chevron style="opacity: 0.6; font-size: 10px; width: 10px;">▸</span>
      <span style="flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${escapeHtml(lastSeg)}</span>
      <span style="opacity: 0.55; font-size: 11px;">${project.sessionCount}</span>
    `;
    wrap.appendChild(row);

    const threadsBox = document.createElement('div');
    threadsBox.style.cssText = 'display: none; padding: 2px 0 4px 18px;';
    wrap.appendChild(threadsBox);

    row.addEventListener('click', async () => {
      const chevron = row.querySelector('[data-claude-project-chevron]');
      const isOpen = threadsBox.style.display !== 'none';
      if (isOpen) {
        threadsBox.style.display = 'none';
        if (chevron) chevron.textContent = '▸';
        return;
      }
      threadsBox.style.display = 'block';
      if (chevron) chevron.textContent = '▾';
      if (threadsBox.dataset.loaded === '1') return;
      threadsBox.innerHTML = `<div style="padding: 4px 8px; font-size: 12px; opacity: 0.7;">${S('claudeBridgeLoading', 'Loading…')}</div>`;
      try {
        const threads = await loadClaudeThreads(project.encodedDir);
        threadsBox.innerHTML = '';
        if (!threads.length) {
          const empty = document.createElement('div');
          empty.style.cssText = 'padding: 4px 8px; font-size: 12px; opacity: 0.6;';
          empty.textContent = S('claudeBridgeEmpty', 'No sessions');
          threadsBox.appendChild(empty);
        } else {
          for (const t of threads) {
            threadsBox.appendChild(renderClaudeThreadRow(t));
          }
        }
        threadsBox.dataset.loaded = '1';
      } catch (error) {
        renderClaudeError(threadsBox, error);
      }
    });

    return wrap;
  }

  function renderClaudeThreadRow(thread) {
    const row = document.createElement('button');
    row.type = 'button';
    row.className =
      'cursor-pointer hover:bg-token-list-hover-background rounded-md';
    row.style.cssText =
      'text-align: left; padding: 5px 8px; display: block; font-size: 12px; color: var(--token-foreground); width: 100%; border: 0; background: transparent;';
    const title = (thread.title || thread.sessionId || '').trim();
    row.innerHTML = `
      <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${escapeHtml(title || thread.sessionId)}</div>
    `;
    row.addEventListener('click', async () => {
      const codexThreadId = currentCodexThreadId();
      if (!codexThreadId) {
        showToast(
          S('claudeBridgeNoActiveThread', 'Open or select a codex conversation first'),
          'error',
        );
        return;
      }
      try {
        const res = await window.shim('/claude-bridge/bind', {
          codexThreadId: codexThreadId,
          sessionId: thread.sessionId,
          jsonlPath: thread.jsonlPath,
          title: title,
        });
        if (!res || res.code !== 0) {
          showToast(`${S('claudeBridgeBindFailed', 'Bind failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
          return;
        }
        applyStateForThread(codexThreadId, res.data || { bound: false });
        ensureChip();
        showToast(
          S('claudeBridgeBoundToast', 'Bound as continuation context') +
            ' · ' + (title || thread.sessionId),
          'success',
        );
      } catch (err) {
        showToast(`${S('claudeBridgeBindFailed', 'Bind failed')}: ${err?.message || err}`, 'error');
      }
    });
    return row;
  }

  // ---------- composer 旁的 chip (按 codex thread 维度) ----------
  // 每个 codex 侧栏对话各自有自己的 Claude 桥状态。dart 侧按 thread id 存。
  // - 进 thread / 切 thread → 拉这个 thread 的状态, 刷新 chip
  // - 点会话 row → /claude-bridge/bind { codexThreadId } → 当前 thread 绑上
  // - 点 chip × → /claude-bridge/unbind { codexThreadId } → 只解绑当前 thread

  // 本地缓存:每个 thread 最近一次拉到的状态, 避免 ensure 频繁打 bridge。
  // key = codexThreadId, value = { bound, sessionId?, title?, jsonlPath? }
  const stateCache = new Map();
  // 正在拉取的 thread 集合, 去重并发
  const fetching = new Set();
  // 上次 chip 渲染基于的 thread, 变化就强制重建
  let lastRenderedThreadId = null;

  /// 找当前 codex 侧栏 active 那条 thread。
  /// 没 active (比如刚开新对话还没创建 thread) 时返回 null。
  function currentCodexThreadId() {
    const active = document.querySelector('[data-app-action-sidebar-thread-active="true"]');
    if (!active) return null;
    const raw = active.getAttribute('data-app-action-sidebar-thread-id') || '';
    // 形如 "local:019ef84a-..." → 取冒号后半段
    return raw.includes(':') ? raw.split(':').slice(1).join(':') : raw;
  }

  function applyStateForThread(threadId, state) {
    if (!threadId) return;
    stateCache.set(threadId, state || { bound: false });
  }

  function fetchStateForThread(threadId) {
    if (!threadId) return Promise.resolve();
    if (typeof window.shim !== 'function') return Promise.resolve();
    if (fetching.has(threadId)) return Promise.resolve();
    fetching.add(threadId);
    return window.shim('/claude-bridge/state', { codexThreadId: threadId }).then((res) => {
      if (res && res.code === 0 && res.data) {
        applyStateForThread(threadId, res.data);
        // 拉的就是当前显示的 thread → 刷 chip
        if (threadId === currentCodexThreadId()) {
          ensureChip();
        }
      }
    }).catch(() => {}).finally(() => {
      fetching.delete(threadId);
    });
  }

  function ensureChip() {
    const threadId = currentCodexThreadId();
    if (!threadId) {
      // 没活跃 thread → chip 不显示
      document.getElementById(CLAUDE_BRIDGE_CHIP_ID)?.remove();
      lastRenderedThreadId = null;
      return;
    }
    // 没缓存就先拉一次, 拉到回调里再 ensure
    if (!stateCache.has(threadId)) {
      fetchStateForThread(threadId);
      // 切到新 thread 时立刻移除老 chip, 避免显示前一个 thread 的标题
      if (lastRenderedThreadId !== threadId) {
        document.getElementById(CLAUDE_BRIDGE_CHIP_ID)?.remove();
        lastRenderedThreadId = threadId;
      }
      return;
    }
    const state = stateCache.get(threadId);
    const existing = document.getElementById(CLAUDE_BRIDGE_CHIP_ID);
    if (!state || !state.bound) {
      existing?.remove();
      lastRenderedThreadId = threadId;
      return;
    }
    const picker = ns.features.providerPicker;
    const anchor = picker?.findAnchor?.();
    if (!anchor) return;
    // 同 thread + 已挂 → 只更标题文字
    if (existing
        && existing.parentElement === anchor.group
        && lastRenderedThreadId === threadId) {
      const labelEl = existing.querySelector('[data-shim-bridge-label]');
      if (labelEl) {
        const title = state.title || state.sessionId || '';
        const expected = `${S('claudeBridgeChipPrefix', 'Claude:')} ${title}`;
        if (labelEl.textContent !== expected) labelEl.textContent = expected;
      }
      return;
    }
    existing?.remove();
    const chip = buildClaudeBridgeChip(threadId, state);
    const pickerBtn = picker?.pickerId ? document.getElementById(picker.pickerId) : null;
    if (pickerBtn && pickerBtn.parentElement === anchor.group) {
      anchor.group.insertBefore(chip, pickerBtn);
    } else {
      anchor.group.insertBefore(chip, anchor.button);
    }
    lastRenderedThreadId = threadId;
  }

  function buildClaudeBridgeChip(threadId, state) {
    const chip = document.createElement('span');
    chip.id = CLAUDE_BRIDGE_CHIP_ID;
    chip.setAttribute('data-shim-bridge-thread', threadId);
    Object.assign(chip.style, {
      display: 'inline-flex',
      alignItems: 'center',
      gap: '6px',
      height: '24px',
      padding: '0 8px',
      borderRadius: '999px',
      background: 'rgba(59, 130, 246, 0.13)',
      color: '#2563eb',
      border: '1px solid rgba(59, 130, 246, 0.28)',
      fontSize: '12px',
      fontWeight: '600',
      lineHeight: '1',
      maxWidth: '220px',
      whiteSpace: 'nowrap',
    });
    const title = state.title || state.sessionId || '';
    const label = document.createElement('span');
    label.setAttribute('data-shim-bridge-label', '1');
    label.textContent = `${S('claudeBridgeChipPrefix', 'Claude:')} ${title}`;
    Object.assign(label.style, {
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
      maxWidth: '180px',
    });
    chip.appendChild(label);

    const close = document.createElement('span');
    close.textContent = '×';
    close.setAttribute('role', 'button');
    close.setAttribute('aria-label', S('claudeBridgeChipUnbindAria', 'Unbind'));
    Object.assign(close.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '16px',
      height: '16px',
      borderRadius: '999px',
      cursor: 'pointer',
      fontSize: '14px',
      fontWeight: '700',
      opacity: '0.8',
    });
    const stopAll = (e) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
    };
    close.addEventListener('pointerdown', stopAll, true);
    close.addEventListener('mousedown', stopAll, true);
    close.addEventListener('click', async (event) => {
      stopAll(event);
      try {
        const res = await window.shim('/claude-bridge/unbind', {
          codexThreadId: threadId,
        });
        if (res && res.code === 0) {
          applyStateForThread(threadId, res.data || { bound: false });
        } else {
          applyStateForThread(threadId, { bound: false });
        }
      } catch (_) {
        applyStateForThread(threadId, { bound: false });
      }
      ensureChip();
    }, true);
    chip.appendChild(close);
    return chip;
  }

  function projectLastSegment(path) {
    if (!path) return '';
    const norm = String(path).replace(/\\/g, '/');
    const segs = norm.split('/').filter((s) => s.length > 0);
    return segs.length ? segs[segs.length - 1] : path;
  }

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  ns.features.claudeBridge = {
    ensureNav,
    ensureChip,
    findNavList: findCodexNavList,
    currentCodexThreadId,
    applyStateForThread,
    navBtnId: NAV_BTN_ID,
    navPanelId: NAV_PANEL_ID,
  };
})();

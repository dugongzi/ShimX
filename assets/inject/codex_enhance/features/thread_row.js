// ==ShimX==
// @name        ShimX codex_enhance — features/thread_row
// @description Codex 侧栏对话行的 "⋯" 三点菜单 (导出 / 删除)。
//              在每行原"归档"按钮旁追加一个三点按钮; 点开弹出我们自己的浮层菜单。
//              对外: ensure() — 由 runtime/scheduler 在 ensureAll 里每轮调一次。
// @layer       features
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;
  const ns = window.__shimxCodex;
  const ids = ns.ids;
  const S = (k, f) => ns.i18n.S(k, f);
  const toast = (msg, kind) => ns.ui.toast.show(msg, kind);
  const busy = {
    show: (label) => ns.ui.busy.show(label),
    hide: (token) => ns.ui.busy.hide(token),
  };
  const confirmDelete = (title) => ns.ui.confirm.showDelete(title);

  const DELETE_BUTTON_FLAG = ids.deleteButtonFlag;
  const THREAD_MENU_ID = ids.threadMenu;

  function dismissThreadMenu() {
    document.getElementById(THREAD_MENU_ID)?.remove();
    document.removeEventListener('mousedown', onThreadMenuOutside, true);
    document.removeEventListener('keydown', onThreadMenuKey, true);
  }
  function onThreadMenuOutside(event) {
    const menu = document.getElementById(THREAD_MENU_ID);
    if (!menu) return;
    if (menu.contains(event.target)) return;
    dismissThreadMenu();
  }
  function onThreadMenuKey(event) {
    if (event.key === 'Escape') dismissThreadMenu();
  }

  function exportBusyLabel(format) {
    if (format === 'markdown') return S('exportBusyMarkdown', 'Exporting Markdown…');
    if (format === 'raws') return S('exportBusyRaws', 'Exporting raw data…');
    if (format === 'html') return S('exportBusyHtml', 'Exporting HTML…');
    return S('exportBusyMarkdown', 'Exporting Markdown…');
  }

  function openThreadMenu(anchorBtn, row) {
    console.log('[ShimXMenu] openThreadMenu');
    dismissThreadMenu();
    const menu = document.createElement('div');
    menu.id = THREAD_MENU_ID;
    menu.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(menu.style, {
      position: 'fixed',
      zIndex: '2147483647',
      minWidth: '180px',
      padding: '6px',
      borderRadius: '12px',
      outline: '0.5px solid var(--token-border, rgba(127,127,127,0.08))',
      boxShadow: '0 16px 42px rgba(0, 0, 0, 0.35)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '13px',
    });

    function addItem({ label, icon, destructive, onClick }) {
      const item = document.createElement('button');
      item.type = 'button';
      item.className =
        'no-drag cursor-interaction flex items-center gap-2 rounded-md hover:bg-token-list-hover-background w-full';
      Object.assign(item.style, {
        minHeight: '32px',
        padding: '6px 8px',
        border: '0',
        background: 'transparent',
        color: destructive ? '#ef4444' : 'inherit',
        textAlign: 'left',
      });
      const iconWrap = document.createElement('span');
      iconWrap.style.display = 'inline-flex';
      iconWrap.style.flex = '0 0 auto';
      iconWrap.innerHTML = icon;
      const text = document.createElement('span');
      text.textContent = label;
      text.style.flex = '1';
      item.appendChild(iconWrap);
      item.appendChild(text);
      const handle = async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        console.log('[ShimXMenu] item click', label);
        dismissThreadMenu();
        try {
          await onClick();
        } catch (err) {
          console.error('[ShimXMenu] onClick error', err);
        }
      };
      // mousedown/pointerdown 也得吞, 避免 onThreadMenuOutside 先把菜单关掉
      const stop = (e) => {
        e.stopPropagation();
        e.stopImmediatePropagation();
      };
      item.addEventListener('mousedown', stop, true);
      item.addEventListener('pointerdown', stop, true);
      item.addEventListener('click', handle, true);
      menu.appendChild(item);
    }

    const ICON_MD = `<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 2.5h7l3 3v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.2"/><path d="M10 2.5V6h3" stroke="currentColor" stroke-width="1.2"/></svg>`;
    const ICON_RAW = `<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M4 2h6l2 2v10H4z" stroke="currentColor" stroke-width="1.2"/><path d="M6 6h4M6 9h4M6 12h3" stroke="currentColor" stroke-width="1.2"/></svg>`;
    const ICON_HTML = `<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 2.5h7l3 3v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.2"/><path d="M10 2.5V6h3" stroke="currentColor" stroke-width="1.2"/><path d="M5 10l-1.2 1.2L5 12.4M11 10l1.2 1.2L11 12.4M8.5 9.6l-1 3.2" stroke="currentColor" stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
    const ICON_DEL = `<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 4h10M6 4V3a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v1M4.5 4l.7 9a1 1 0 0 0 1 .9h3.6a1 1 0 0 0 1-.9l.7-9" stroke="currentColor" stroke-width="1.2"/></svg>`;

    addItem({
      label: S('threadExportMarkdown', 'Export as Markdown'),
      icon: ICON_MD,
      onClick: () => exportThread(row, 'markdown'),
    });
    addItem({
      label: S('threadExportRaw', 'Export raw data'),
      icon: ICON_RAW,
      onClick: () => exportThread(row, 'raws'),
    });
    addItem({
      label: S('threadExportHtml', 'Export as HTML'),
      icon: ICON_HTML,
      onClick: () => exportThread(row, 'html'),
    });
    const sep = document.createElement('div');
    sep.style.cssText = 'height:1px;margin:4px 6px;background:var(--token-border,rgba(127,127,127,0.10));';
    menu.appendChild(sep);
    addItem({
      label: S('deleteOk', 'Delete'),
      icon: ICON_DEL,
      destructive: true,
      onClick: () => deleteThread(row),
    });

    document.body.appendChild(menu);
    // 定位: 挂在 anchorBtn 下方右对齐
    const rect = anchorBtn.getBoundingClientRect();
    const mRect = menu.getBoundingClientRect();
    let left = rect.right - mRect.width;
    let top = rect.bottom + 4;
    if (left < 8) left = 8;
    if (top + mRect.height > window.innerHeight - 8) {
      top = rect.top - mRect.height - 4;
    }
    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;

    document.addEventListener('mousedown', onThreadMenuOutside, true);
    document.addEventListener('keydown', onThreadMenuKey, true);
  }

  function threadIdFromRow(row) {
    const rawId = row.getAttribute('data-app-action-sidebar-thread-id') || '';
    return rawId.includes(':') ? rawId.split(':').slice(1).join(':') : rawId;
  }

  async function exportThread(row, format) {
    const id = threadIdFromRow(row);
    if (!id) {
      toast(S('deleteSessionIdMissing', 'Session id not found'), 'error');
      return;
    }
    const busyToken = busy.show(exportBusyLabel(format));
    try {
      const res = await window.shimx('/session/export', { id, format });
      if (res?.code !== 0) {
        toast(`${S('threadExportFailed', 'Export failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
        return;
      }
      if (res.data?.cancelled) return; // 用户取消保存
      toast(S('threadExportedToast', 'Exported'), 'success');
    } catch (err) {
      toast(`${S('threadExportFailed', 'Export failed')}: ${err?.message || err}`, 'error');
    } finally {
      busy.hide(busyToken);
    }
  }

  async function deleteThread(row) {
    const title = row.getAttribute('data-app-action-sidebar-thread-title') ||
      row.querySelector('[data-thread-title]')?.textContent?.trim() ||
      S('deleteDefaultTitle', 'this thread');
    const ok = await confirmDelete(title);
    if (!ok) return;
    const id = threadIdFromRow(row);
    if (!id) {
      toast(S('deleteSessionIdMissing', 'Session id not found'), 'error');
      return;
    }
    try {
      const res = await window.shimx('/session/delete', { id });
      if (res?.code !== 0) {
        toast(`${S('deleteFailed', 'Delete failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
        return;
      }
      const container =
        row.closest('[role="listitem"]') || row.closest('.after\\:block') || row;
      container.remove();
      toast(S('deleteSuccess', 'Deleted'), 'success');
    } catch (err) {
      toast(`${S('deleteFailed', 'Delete failed')}: ${err?.message || err}`, 'error');
    }
  }

  function buildDeleteButton(row) {
    const wrapper = document.createElement('span');
    wrapper.setAttribute('data-state', 'closed');
    wrapper.className = 'contents';

    const btn = document.createElement('button');
    btn.type = 'button';
    btn.setAttribute('aria-label', S('threadMenu', 'More'));
    btn.className =
      'border-token-border no-drag cursor-interaction flex items-center gap-1 border whitespace-nowrap select-none focus:outline-none disabled:cursor-not-allowed disabled:opacity-40 rounded-full electron:rounded-md text-token-muted-foreground enabled:hover:bg-transparent data-[state=open]:bg-transparent hover:text-token-foreground border-transparent electron:p-1 electron:[&>svg]:icon-sm flex items-center justify-center p-0.5 !h-5 !w-5 !p-0 opacity-50 hover:opacity-100 focus-visible:opacity-100 [&>svg]:!h-4 [&>svg]:!w-4';

    btn.innerHTML = `
      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
        <circle cx="3" cy="8" r="1.4"/>
        <circle cx="8" cy="8" r="1.4"/>
        <circle cx="13" cy="8" r="1.4"/>
      </svg>
    `;

    btn.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      const existing = document.getElementById(THREAD_MENU_ID);
      if (existing) {
        dismissThreadMenu();
        return;
      }
      openThreadMenu(btn, row);
    }, true);

    wrapper.appendChild(btn);
    return wrapper;
  }

  // codex 侧边行的归档按钮 aria-label 会随语言 / 版本变化:
  // - 旧版中文: "归档对话"
  // - 新版中文: "归档任务"
  // - 英文: "Archive task" / "Archive chat" / "Archive conversation" 都可能出现
  // 靠 aria-label 命中最直接,同时保留 SVG path 兜底(不依赖文案)。
  const ARCHIVE_ARIA_KEYWORDS = ['归档', 'archive'];
  // codex 归档按钮 SVG 里独有的 path 起始片段(带盒子+抽屉图标),多版本没变。
  const ARCHIVE_SVG_PATH_PREFIX = 'M11.8008 10.1816';

  function findArchiveButton(row) {
    const buttons = row.querySelectorAll('button[aria-label]');
    for (const btn of buttons) {
      const label = (btn.getAttribute('aria-label') || '').toLowerCase();
      if (ARCHIVE_ARIA_KEYWORDS.some((k) => label.includes(k))) return btn;
    }
    // 兜底:找到 svg path[d^="M11.8008 10.1816"] 所属的 button。
    const paths = row.querySelectorAll('svg path');
    for (const path of paths) {
      const d = path.getAttribute('d') || '';
      if (d.startsWith(ARCHIVE_SVG_PATH_PREFIX)) {
        const btn = path.closest('button');
        if (btn) return btn;
      }
    }
    return null;
  }

  function ensure() {
    const rows = document.querySelectorAll(
      '[data-app-action-sidebar-thread-row]',
    );
    let added = 0;
    for (const row of rows) {
      if (row.getAttribute(DELETE_BUTTON_FLAG) === '1') continue;
      const archiveButton = findArchiveButton(row);
      if (!archiveButton) continue;
      const actionGroup = archiveButton.closest('span.contents')?.parentElement;
      if (!actionGroup) continue;
      const deleteWrapper = buildDeleteButton(row);
      actionGroup.appendChild(deleteWrapper);
      row.setAttribute(DELETE_BUTTON_FLAG, '1');
      added += 1;
    }
    const trace = ns.runtime?.trace?.t;
    if (added > 0 && typeof trace === 'function') {
      trace('ensureDeleteButtons: INSERT', { added, totalRows: rows.length });
    }
  }

  ns.features.threadRow = { ensure };
})();

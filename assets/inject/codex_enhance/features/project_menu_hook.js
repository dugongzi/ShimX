// ==Shim==
// @name        Shim codex_enhance — features/project_menu_hook
// @description 在 Codex 项目折叠头右侧的 "⋯" 按钮 (radix dropdown) 顶部插两项:
//              "导入 zip" — 选 .zip → /session/import-bundle 进当前项目目录
//              "导出为 ▸" — hover 出二级菜单 (Markdown / 原始数据 / HTML), 各 zip 打包
//
//              通过 MutationObserver 监听菜单弹出, 用 aria-labelledby 反查 trigger 找到项目 cwd。
//              install() 在 bootstrap 阶段调一次, 内部有 window.__shimCodexProjectMenuHookInstalled 守卫,
//              防止热重载/再注入时重复挂载。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const S = (k, f) => ns.i18n.S(k, f);
  const showToast = (msg, kind) => ns.ui.toast.show(msg, kind);
  const showBusyIndicator = (label) => ns.ui.busy.show(label);
  const hideBusyIndicator = (token) => ns.ui.busy.hide(token);

  // 跟 control_panel 里的 runImportBundle 是同一份逻辑, 故意 copy 一份避免污染
  // control_panel 的公开 API 表面; 二者只是路由相同, 各自调度 busy/toast 是独立的。
  async function runImportBundle(targetCwd) {
    const busyToken = showBusyIndicator(S('shimControlImportBusyZip', 'Importing project bundle…'));
    try {
      const res = await window.shim('/session/import-bundle', targetCwd ? { targetCwd } : {});
      if (!res || res.code !== 0) {
        showToast(`${S('shimControlImportFailed', 'Import failed')}: ${res?.message || ''}`, 'error');
        return;
      }
      const data = res.data || {};
      if (data.cancelled) return;
      if (data.reason === 'no-jsonl-in-zip') {
        showToast(S('shimControlImportEmpty', 'No .jsonl files inside the zip'), 'warning');
        return;
      }
      if (data.reason === 'bad-zip') {
        showToast(`${S('shimControlImportFailed', 'Import failed')}: ${data.message || ''}`, 'error');
        return;
      }
      if (!data.ok) {
        showToast(`${S('shimControlImportFailed', 'Import failed')}: ${data.reason || ''}`, 'error');
        return;
      }
      const ok = data.count || 0;
      const failed = data.failed || 0;
      const tail = failed > 0 ? ` · ${failed} failed` : '';
      showToast(`${S('shimControlImportDoneN', 'Imported')} · ${ok}${tail}`, 'success');
    } catch (err) {
      showToast(`${S('shimControlImportFailed', 'Import failed')}: ${err?.message || err}`, 'error');
    } finally {
      hideBusyIndicator(busyToken);
    }
  }

  function install() {
    if (window.__shimCodexProjectMenuHookInstalled) return;
    window.__shimCodexProjectMenuHookInstalled = true;
    const SHIM_INJECTED_FLAG = 'data-shim-export-injected';

    const observer = new MutationObserver((records) => {
      for (const rec of records) {
        for (const node of rec.addedNodes) {
          if (!(node instanceof HTMLElement)) continue;
          // 菜单可能就是 added node, 也可能在它的子树里
          const menus = node.matches('[data-radix-menu-content]')
            ? [node]
            : Array.from(node.querySelectorAll('[data-radix-menu-content]'));
          for (const menu of menus) {
            if (menu.getAttribute(SHIM_INJECTED_FLAG) === '1') continue;
            tryInjectProjectExportItem(menu);
          }
        }
      }
    });
    observer.observe(document.body || document.documentElement, {
      childList: true,
      subtree: true,
    });

    function tryInjectProjectExportItem(menu) {
      // 用 aria-labelledby 反查 trigger
      const triggerId = menu.getAttribute('aria-labelledby');
      if (!triggerId) return;
      const trigger = document.getElementById(triggerId);
      if (!trigger) return;
      // trigger 外面必须包着一个项目 row 才认
      const projectRow = trigger.closest('[data-app-action-sidebar-project-row]');
      if (!projectRow) return;
      const cwd = projectRow.getAttribute('data-app-action-sidebar-project-id') || '';
      const label = projectRow.getAttribute('data-app-action-sidebar-project-label') || '';

      menu.setAttribute(SHIM_INJECTED_FLAG, '1');

      // 找菜单里现有任意 menuitem 当样式模板
      const sampleItem = menu.querySelector('[role="menuitem"]');
      // 顺序: 导入 zip → 导出为 ▸ (导入在最上面, 跟"导出为"对称)
      const exportItem = buildProjectExportMenuItem(cwd, label, sampleItem);
      menu.insertBefore(exportItem, menu.firstChild);
      const importItem = buildProjectImportMenuItem(cwd, label, sampleItem);
      menu.insertBefore(importItem, menu.firstChild);
    }
  }

  // 项目菜单第一项: "导入 zip" - 点击直接弹文件选择器, 走 /session/import-bundle
  function buildProjectImportMenuItem(cwd, label, sampleItem) {
    const item = document.createElement('div');
    item.setAttribute('role', 'menuitem');
    item.setAttribute('tabindex', '-1');
    item.setAttribute('data-orientation', 'vertical');
    item.setAttribute('aria-label', S('projectMenuImportZipAria', 'Import all conversations from a zip into this project'));
    if (sampleItem) {
      item.className = sampleItem.className;
    } else {
      item.className =
        'no-drag text-token-foreground outline-hidden rounded-lg px-[var(--padding-row-x)] py-[var(--padding-row-y)] text-sm group hover:bg-token-list-hover-background focus:bg-token-list-hover-background cursor-interaction flex flex-col';
    }
    const row = document.createElement('div');
    row.className = 'flex w-full items-center gap-1.5';
    const icon = document.createElement('span');
    icon.style.cssText = 'display:inline-flex;align-items:center;justify-content:center;width:20px;height:20px;opacity:0.75;';
    icon.innerHTML = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8 2v8M4.5 7.5L8 11l3.5-3.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 13h10" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';
    const text = document.createElement('span');
    text.className = 'flex-1 min-w-0 truncate';
    text.textContent = S('projectMenuImportZip', 'Import zip');
    row.appendChild(icon);
    row.appendChild(text);
    item.appendChild(row);

    item.addEventListener('click', async (e) => {
      e.preventDefault();
      e.stopPropagation();
      // 关掉父 radix 菜单 (codex 自己监听 outside-click)
      document.body.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }));
      await runImportBundle(cwd);
    });
    return item;
  }

  // 项目菜单第一项: "导出为" + 右箭头, hover 弹子菜单 (我们自己的浮层, 不嵌套 radix)
  function buildProjectExportMenuItem(cwd, label, sampleItem) {
    const item = document.createElement('div');
    item.setAttribute('role', 'menuitem');
    item.setAttribute('tabindex', '-1');
    item.setAttribute('data-orientation', 'vertical');
    if (sampleItem) {
      item.className = sampleItem.className;
    } else {
      // fallback: 大致 cosplay radix item 的样式
      item.className =
        'no-drag text-token-foreground outline-hidden rounded-lg px-[var(--padding-row-x)] py-[var(--padding-row-y)] text-sm group hover:bg-token-list-hover-background focus:bg-token-list-hover-background cursor-interaction flex flex-col';
    }

    const row = document.createElement('div');
    row.className = 'flex w-full items-center gap-1.5';
    const icon = document.createElement('span');
    icon.style.cssText = 'display:inline-flex;align-items:center;justify-content:center;width:20px;height:20px;opacity:0.75;';
    icon.innerHTML = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 2.5h7l3 3v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.2"/><path d="M10 2.5V6h3" stroke="currentColor" stroke-width="1.2"/><path d="M5 9h6M5 11.5h4" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/></svg>';
    const text = document.createElement('span');
    text.className = 'flex-1 min-w-0 truncate';
    text.textContent = S('projectMenuExportAs', 'Export as');
    const chevron = document.createElement('span');
    chevron.style.cssText = 'opacity:0.55;font-size:11px;';
    chevron.textContent = '▸';
    row.appendChild(icon);
    row.appendChild(text);
    row.appendChild(chevron);
    item.appendChild(row);

    let submenu = null;
    let hideTimer = null;

    const openSubmenu = () => {
      if (hideTimer) { clearTimeout(hideTimer); hideTimer = null; }
      if (submenu) return;
      submenu = buildProjectExportSubmenu(cwd, label, item, () => {
        // 子菜单要求自己关闭 (点完了之类)
        closeSubmenu(true);
      });
      document.body.appendChild(submenu);
      positionAtRightOf(submenu, item);
    };
    const scheduleClose = () => {
      if (hideTimer) clearTimeout(hideTimer);
      hideTimer = setTimeout(() => closeSubmenu(false), 200);
    };
    const closeSubmenu = (immediate) => {
      if (hideTimer) { clearTimeout(hideTimer); hideTimer = null; }
      if (!submenu) return;
      submenu.remove();
      submenu = null;
    };

    item.addEventListener('mouseenter', openSubmenu);
    item.addEventListener('mouseleave', scheduleClose);
    item.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      openSubmenu();
    });
    // 父 radix 菜单被关闭时, 我们的子菜单也跟着消失
    const parentMenu = item.closest('[data-radix-menu-content]');
    if (parentMenu) {
      const mo = new MutationObserver(() => {
        if (!document.body.contains(parentMenu)) {
          closeSubmenu(true);
          mo.disconnect();
        }
      });
      mo.observe(document.body, { childList: true });
    }
    return item;
  }

  function buildProjectExportSubmenu(cwd, label, anchor, onClose) {
    const menu = document.createElement('div');
    menu.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(menu.style, {
      position: 'fixed',
      zIndex: '2147483647',
      minWidth: '200px',
      padding: '4px',
      borderRadius: '10px',
      outline: '0.5px solid var(--token-border, rgba(255,255,255,0.08))',
      boxShadow: '0 16px 42px rgba(0, 0, 0, 0.42)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '13px',
    });

    // 鼠标在 anchor 与 menu 之间移动时不要意外关闭 — 我们把 menu 也注册 enter
    menu.addEventListener('mouseenter', () => {
      // 阻断 anchor 的 leave-close 计时
      const event = new Event('mouseenter');
      anchor.dispatchEvent(event);
    });
    menu.addEventListener('mouseleave', () => {
      const event = new Event('mouseleave');
      anchor.dispatchEvent(event);
    });

    const formats = [
      { key: 'markdown', label: S('projectMenuExportMarkdownZip', 'Markdown · zip') },
      { key: 'raws', label: S('projectMenuExportRawZip', 'Raw data · zip') },
      { key: 'html', label: S('projectMenuExportHtmlZip', 'HTML · zip') },
    ];
    for (const f of formats) {
      menu.appendChild(buildProjectExportSubmenuItem(f.label, async () => {
        onClose && onClose();
        // 关闭父 radix 菜单: 找一个空白点击模拟一下 (radix 自己有 outside-click 监听)
        document.body.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }));
        await runProjectExportBundle(cwd, label, f.key);
      }));
    }
    return menu;
  }

  function buildProjectExportSubmenuItem(label, onClick) {
    const btn = document.createElement('button');
    btn.type = 'button';
    Object.assign(btn.style, {
      display: 'flex',
      alignItems: 'center',
      width: '100%',
      padding: '8px 10px',
      border: '0',
      borderRadius: '6px',
      background: 'transparent',
      color: 'var(--token-text-primary, currentColor)',
      cursor: 'pointer',
      fontSize: '13px',
      textAlign: 'left',
      transition: 'background 140ms ease',
    });
    btn.textContent = label;
    btn.addEventListener('mouseenter', () => {
      btn.style.background = 'rgba(255,255,255,0.06)';
    });
    btn.addEventListener('mouseleave', () => {
      btn.style.background = 'transparent';
    });
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      onClick();
    });
    return btn;
  }

  function positionAtRightOf(submenu, anchor) {
    const r = anchor.getBoundingClientRect();
    const sr = submenu.getBoundingClientRect();
    let left = r.right + 4;
    let top = r.top;
    if (left + sr.width > window.innerWidth - 8) {
      left = r.left - sr.width - 4;
    }
    if (top + sr.height > window.innerHeight - 8) {
      top = Math.max(8, window.innerHeight - sr.height - 8);
    }
    submenu.style.left = `${Math.max(8, left)}px`;
    submenu.style.top = `${Math.max(8, top)}px`;
  }

  async function runProjectExportBundle(cwd, label, format) {
    if (!cwd) {
      showToast(S('projectMenuExportMissingCwd', 'Project path not detected'), 'error');
      return;
    }
    const busyToken = showBusyIndicator(S('exportBusyBundle', 'Packing export…'));
    try {
      const res = await window.shim('/session/export-bundle', { cwd, format });
      if (!res || res.code !== 0) {
        const msg = res && res.message ? res.message : '';
        showToast(`${S('projectMenuExportFailed', 'Export failed')}: ${msg}`, 'error');
        return;
      }
      if (res.data && res.data.cancelled) return;
      if (res.data && res.data.reason === 'empty') {
        showToast(S('projectMenuExportEmpty', 'This project has no conversations to export'), 'warning');
        return;
      }
      const count = (res.data && res.data.count) || 0;
      showToast(`${S('projectMenuExportDone', 'Exported')} · ${count}`, 'success');
    } catch (err) {
      showToast(`${S('projectMenuExportFailed', 'Export failed')}: ${err && err.message ? err.message : err}`, 'error');
    } finally {
      hideBusyIndicator(busyToken);
    }
  }

  ns.features.projectMenuHook = { install };
})();

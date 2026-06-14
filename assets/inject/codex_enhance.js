// ==Shim==
// @name        Shim Injected Badge + Menu
// @description 在 Codex 工具栏「请求批准」按钮右侧显示已注入徽章，并在设置菜单顶部插入 Shim 菜单项
// @version     1.0.0
// @author      shim
// ==/Shim==
(() => {
  const BADGE_ID = '__shim_injected_badge__';
  const MENU_ITEM_ID = '__shim_menu_item__';
  const POPOVER_ID = '__shim_popover__';

  const BADGE_ANCHOR_SVG_D_PREFIX = 'M16.835 8.66301C16.835 7.71885';
  const SETTINGS_ANCHOR_SVG_D_PREFIX = 'M9.99944 7.24939';

  const SHIM_ICON_SVG = `
    <svg viewBox="0 0 1210 1024" width="20" height="20" xmlns="http://www.w3.org/2000/svg" class="icon-xs shrink-0 opacity-75 group-focus:opacity-100 group-hover:opacity-100">
      <path d="M929.170154 428.766111a24.122983 24.122983 0 0 1 24.205717 24.169078v108.663343a29.35416 29.35416 0 0 0 29.237151 29.350614h214.831653c14.863823 0 17.889538 21.483756 3.44175 25.411276L768.803729 740.837852a23.561571 23.561571 0 0 1-29.311611-15.998467 20.064271 20.064271 0 0 1-0.945536-6.694393v-113.582493a10.712921 10.712921 0 0 0-10.55218-10.590002H254.267944a10.657371 10.657371 0 0 1-10.55218-10.438716V455.959722a32.661172 32.661172 0 0 0-31.960294-32.787638l-201.635518-3.517393c-11.838109-0.491679-14.031752-17.137837-2.609679-20.57486l441.769711-127.540966a10.503721 10.503721 0 0 1 12.821466 7.37518 11.305063 11.305063 0 0 1 0.340393 2.685321v123.111131a24.320364 24.320364 0 0 0 24.169078 24.093435zM443.152911 135.94548c15.393324-2.609679 18.910717 17.549145 18.910717 17.549145s1.248107 47.769653 0 67.474619c-1.361572 19.667146-19.326753 18.910717-19.326752 18.910717H267.429803s-15.885002-5.711036-18.003003-26.3249c-2.685322-20.57486 21.89861-32.073758 21.89861-32.073757s156.54646-42.928509 171.714037-45.538188z m296.791882-55.674333s-2.269286-23.260182 23.756588-33.284043C789.526329 37.342638 928.489368 1.411094 928.489368 1.411094s25.833221-10.098323 27.573007 23.756588c1.77288 33.700079 0 311.543423 0 311.543423s0.907714 22.730682-23.638396 24.509471c-24.622935 1.77288-162.632165 0-162.632165 0s-29.842293 2.685322-29.842293-21.028717z m3.933429 722.785327c1.248107-19.704967 19.326753-18.910717 18.910717-19.364574h175.23143s15.393324 5.711036 18.003003 26.3249c2.685322 20.57486-21.974253 32.030027-21.974253 32.030027s-156.432996 42.928509-171.751858 45.503912c-15.393324 3.139179-18.419038-17.095288-18.419039-17.095288s-1.248107-47.656188 0-67.361155z m-278.259379 140.699279s2.571857 23.260182-23.756588 33.284044c-25.871043 9.57355-164.791532 45.538188-164.791532 45.538188s-25.908864 10.136144-27.563552-23.715221c-1.77288-33.700079 0-311.543423 0-311.543423s-0.907714-22.730682 23.638396-24.509471 162.632165 0 162.632165 0 26.665293-2.685322 29.842293 21.028717c2.987893 23.185721 0 39.830697 0 39.830698z" fill="currentColor"></path>
    </svg>
  `;

  // ========== 徽章 ==========

  function buildBadge(inline) {
    const badge = document.createElement('span');
    badge.id = BADGE_ID;
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
      background: '#22c55e',
      boxShadow: '0 0 6px rgba(34, 197, 94, 0.8)',
    });

    const text = document.createElement('span');
    text.textContent = 'Shim Injected';

    badge.appendChild(dot);
    badge.appendChild(text);
    return badge;
  }

  function findBadgeAnchor() {
    const paths = document.querySelectorAll('svg path');
    for (const path of paths) {
      const d = path.getAttribute('d');
      if (d && d.startsWith(BADGE_ANCHOR_SVG_D_PREFIX)) {
        const button = path.closest('button');
        if (!button) continue;
        return button.parentElement;
      }
    }
    return null;
  }

  function ensureBadge() {
    const existing = document.getElementById(BADGE_ID);
    const anchor = findBadgeAnchor();
    if (anchor) {
      if (existing && existing.parentElement === anchor) return;
      existing?.remove();
      anchor.appendChild(buildBadge(true));
      return;
    }
    if (existing) return;
    (document.body || document.documentElement).appendChild(buildBadge(false));
  }

  // ========== Shim 菜单项（插入到 Codex 设置菜单顶部） ==========

  function findSettingsMenuList() {
    const paths = document.querySelectorAll('svg path');
    for (const path of paths) {
      const d = path.getAttribute('d');
      if (!d || !d.startsWith(SETTINGS_ANCHOR_SVG_D_PREFIX)) continue;
      const menuItem = path.closest('[role="menuitem"]');
      if (!menuItem) continue;
      const list = menuItem.parentElement;
      if (!list) continue;
      const menu = list.closest('[role="menu"]');
      if (!menu) continue;
      return list;
    }
    return null;
  }

  function buildShimMenuItem() {
    const item = document.createElement('div');
    item.id = MENU_ITEM_ID;
    item.setAttribute('role', 'menuitem');
    item.setAttribute('tabindex', '-1');
    item.setAttribute('data-orientation', 'vertical');
    item.className =
      'no-drag text-token-foreground outline-hidden rounded-lg px-[var(--padding-row-x)] py-[var(--padding-row-y)] text-sm group hover:bg-token-list-hover-background focus:bg-token-list-hover-background cursor-interaction flex flex-col';

    const row = document.createElement('div');
    row.className = 'flex w-full items-center gap-1.5';

    const iconWrap = document.createElement('span');
    iconWrap.style.display = 'inline-flex';
    iconWrap.style.color = '#1296db';
    iconWrap.innerHTML = SHIM_ICON_SVG;

    const label = document.createElement('span');
    label.className = 'flex-1 min-w-0 truncate';
    label.textContent = 'Shim';

    row.appendChild(iconWrap);
    row.appendChild(label);
    item.appendChild(row);

    item.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      togglePopover(item);
    });
    item.addEventListener('mouseenter', () => {
      item.setAttribute('data-highlighted', '');
    });
    item.addEventListener('mouseleave', () => {
      item.removeAttribute('data-highlighted');
    });

    return item;
  }

  function ensureShimMenuItem() {
    const list = findSettingsMenuList();
    if (!list) return;
    if (document.getElementById(MENU_ITEM_ID)?.parentElement === list) return;
    document.getElementById(MENU_ITEM_ID)?.remove();
    const item = buildShimMenuItem();
    list.insertBefore(item, list.firstChild);
  }

  // ========== 浮层 ==========

  function buildPopover() {
    const popover = document.createElement('div');
    popover.id = POPOVER_ID;
    Object.assign(popover.style, {
      position: 'fixed',
      zIndex: '2147483647',
      padding: '14px 16px',
      minWidth: '180px',
      background: 'rgba(20, 20, 20, 0.92)',
      color: '#fff',
      borderRadius: '12px',
      boxShadow: '0 12px 32px rgba(0, 0, 0, 0.35)',
      backdropFilter: 'blur(8px)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '13px',
      lineHeight: '1.5',
      userSelect: 'none',
    });

    const titleRow = document.createElement('div');
    Object.assign(titleRow.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '8px',
      fontWeight: '700',
      fontSize: '14px',
      marginBottom: '6px',
    });
    const dot = document.createElement('span');
    Object.assign(dot.style, {
      width: '8px',
      height: '8px',
      borderRadius: '50%',
      background: '#22c55e',
      boxShadow: '0 0 6px rgba(34, 197, 94, 0.8)',
    });
    const titleText = document.createElement('span');
    titleText.textContent = 'Shim Injected';
    titleRow.appendChild(dot);
    titleRow.appendChild(titleText);

    const version = document.createElement('div');
    version.textContent = 'v0.1.0';
    Object.assign(version.style, {
      color: 'rgba(255, 255, 255, 0.6)',
      fontSize: '12px',
    });

    popover.appendChild(titleRow);
    popover.appendChild(version);
    return popover;
  }

  function positionPopover(popover, anchor) {
    const rect = anchor.getBoundingClientRect();
    const popRect = popover.getBoundingClientRect();
    const gap = 8;
    let left = rect.right + gap;
    let top = rect.top;
    if (left + popRect.width > window.innerWidth - 8) {
      left = rect.left - popRect.width - gap;
    }
    if (left < 8) left = 8;
    if (top + popRect.height > window.innerHeight - 8) {
      top = window.innerHeight - popRect.height - 8;
    }
    if (top < 8) top = 8;
    popover.style.left = `${left}px`;
    popover.style.top = `${top}px`;
  }

  function dismissPopover() {
    document.getElementById(POPOVER_ID)?.remove();
    document.removeEventListener('mousedown', onPopoverOutside, true);
    document.removeEventListener('keydown', onPopoverKey, true);
  }

  function onPopoverOutside(event) {
    const popover = document.getElementById(POPOVER_ID);
    const item = document.getElementById(MENU_ITEM_ID);
    if (!popover) return;
    if (popover.contains(event.target)) return;
    if (item && item.contains(event.target)) return;
    dismissPopover();
  }

  function onPopoverKey(event) {
    if (event.key === 'Escape') dismissPopover();
  }

  function togglePopover(anchor) {
    if (document.getElementById(POPOVER_ID)) {
      dismissPopover();
      return;
    }
    const popover = buildPopover();
    document.body.appendChild(popover);
    positionPopover(popover, anchor);
    document.addEventListener('mousedown', onPopoverOutside, true);
    document.addEventListener('keydown', onPopoverKey, true);
  }

  // ========== Toast 提示（用 Codex 主题） ==========

  const TOAST_CONTAINER_ID = '__shim_toast_container__';

  function ensureToastContainer() {
    let container = document.getElementById(TOAST_CONTAINER_ID);
    if (container) return container;
    container = document.createElement('div');
    container.id = TOAST_CONTAINER_ID;
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

  function showToast(message, kind = 'info') {
    const container = ensureToastContainer();
    const toast = document.createElement('div');
    toast.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(toast.style, {
      padding: '10px 16px',
      borderRadius: '12px',
      fontSize: '13px',
      fontWeight: '500',
      maxWidth: '420px',
      outline: '0.5px solid var(--token-border, rgba(255,255,255,0.08))',
      boxShadow: '0 8px 24px rgba(0, 0, 0, 0.25)',
      pointerEvents: 'auto',
      borderLeft: `3px solid ${
        kind === 'error' ? '#ef4444' : kind === 'success' ? '#22c55e' : '#3b82f6'
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

  // ========== 删除确认对话框（用 Codex 主题） ==========

  const CONFIRM_DIALOG_ID = '__shim_confirm_dialog__';

  function showDeleteConfirm(title) {
    return new Promise((resolve) => {
      document.getElementById(CONFIRM_DIALOG_ID)?.remove();

      const overlay = document.createElement('div');
      overlay.id = CONFIRM_DIALOG_ID;
      Object.assign(overlay.style, {
        position: 'fixed',
        inset: '0',
        zIndex: '2147483647',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'rgba(0, 0, 0, 0.4)',
        backdropFilter: 'blur(2px)',
      });

      const dialog = document.createElement('div');
      dialog.setAttribute('role', 'dialog');
      dialog.setAttribute('aria-modal', 'true');
      dialog.className =
        'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
      Object.assign(dialog.style, {
        minWidth: '320px',
        maxWidth: '420px',
        padding: '20px 22px',
        borderRadius: '16px',
        outline: '0.5px solid var(--token-border, rgba(255,255,255,0.08))',
        boxShadow: '0 24px 64px rgba(0, 0, 0, 0.4)',
      });

      const heading = document.createElement('div');
      heading.textContent = '删除对话';
      Object.assign(heading.style, {
        fontSize: '15px',
        fontWeight: '700',
        marginBottom: '8px',
      });

      const desc = document.createElement('div');
      desc.className = 'text-token-description-foreground';
      desc.style.fontSize = '13px';
      desc.style.lineHeight = '1.5';
      desc.style.marginBottom = '18px';
      desc.textContent = `确定删除「${title}」？此操作不可逆。`;

      const actions = document.createElement('div');
      Object.assign(actions.style, {
        display: 'flex',
        justifyContent: 'flex-end',
        gap: '8px',
      });

      const cancelBtn = document.createElement('button');
      cancelBtn.type = 'button';
      cancelBtn.textContent = '取消';
      cancelBtn.className =
        'border-token-border no-drag cursor-interaction flex items-center gap-1 border whitespace-nowrap select-none focus:outline-none rounded-full text-token-foreground hover:bg-token-list-hover-background px-3 py-1.5 text-sm';

      const okBtn = document.createElement('button');
      okBtn.type = 'button';
      okBtn.textContent = '删除';
      okBtn.className =
        'no-drag cursor-interaction flex items-center gap-1 whitespace-nowrap select-none focus:outline-none rounded-full px-3 py-1.5 text-sm font-semibold';
      Object.assign(okBtn.style, {
        background: '#dc2626',
        color: '#fff',
        border: '0',
      });
      okBtn.addEventListener('mouseenter', () => {
        okBtn.style.background = '#b91c1c';
      });
      okBtn.addEventListener('mouseleave', () => {
        okBtn.style.background = '#dc2626';
      });

      actions.appendChild(cancelBtn);
      actions.appendChild(okBtn);
      dialog.appendChild(heading);
      dialog.appendChild(desc);
      dialog.appendChild(actions);
      overlay.appendChild(dialog);
      document.body.appendChild(overlay);

      const cleanup = (result) => {
        document.removeEventListener('keydown', onKey, true);
        overlay.remove();
        resolve(result);
      };
      const onKey = (e) => {
        if (e.key === 'Escape') cleanup(false);
        if (e.key === 'Enter') cleanup(true);
      };

      overlay.addEventListener('mousedown', (e) => {
        if (e.target === overlay) cleanup(false);
      });
      cancelBtn.addEventListener('click', () => cleanup(false));
      okBtn.addEventListener('click', () => cleanup(true));
      document.addEventListener('keydown', onKey, true);

      setTimeout(() => okBtn.focus(), 0);
    });
  }

  // ========== 会话删除按钮 ==========

  const DELETE_BUTTON_FLAG = 'data-shim-delete-added';

  function buildDeleteButton(row) {
    const wrapper = document.createElement('span');
    wrapper.setAttribute('data-state', 'closed');
    wrapper.className = 'contents';

    const btn = document.createElement('button');
    btn.type = 'button';
    btn.setAttribute('aria-label', '删除对话');
    btn.className =
      'border-token-border no-drag cursor-interaction flex items-center gap-1 border whitespace-nowrap select-none focus:outline-none disabled:cursor-not-allowed disabled:opacity-40 rounded-full electron:rounded-md text-token-muted-foreground enabled:hover:bg-transparent data-[state=open]:bg-transparent hover:text-token-foreground border-transparent electron:p-1 electron:[&>svg]:icon-sm flex items-center justify-center p-0.5 !h-5 !w-5 !p-0 opacity-50 hover:opacity-100 focus-visible:opacity-100 [&>svg]:!h-4 [&>svg]:!w-4';
    btn.style.color = '#ef4444';

    btn.innerHTML = `
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8.33301 3.33301H11.667C12.0341 3.33301 12.332 3.63087 12.332 3.99805V4.66602H7.66797V3.99805C7.66797 3.63087 7.96586 3.33301 8.33301 3.33301ZM6.33789 4.66602V3.99805C6.33789 2.89623 7.23119 2.00293 8.33301 2.00293H11.667C12.7688 2.00293 13.6621 2.89623 13.6621 3.99805V4.66602H16.667C17.0342 4.66602 17.332 4.96383 17.332 5.33105C17.332 5.69826 17.0342 5.99609 16.667 5.99609H15.6191L14.7891 14.5479C14.6553 15.917 13.5045 16.9648 12.1289 16.9648H7.87109C6.49551 16.9648 5.34469 15.917 5.21094 14.5479L4.38086 5.99609H3.33301C2.96586 5.99609 2.66797 5.69826 2.66797 5.33105C2.66797 4.96383 2.96586 4.66602 3.33301 4.66602H6.33789ZM6.53516 14.4189C6.59995 15.082 7.20566 15.6348 7.87109 15.6348H12.1289C12.7944 15.6348 13.4001 15.082 13.4648 14.4189L14.2832 5.99609H5.7168L6.53516 14.4189Z" fill="currentColor"/>
      </svg>
    `;

    btn.addEventListener('click', async (event) => {
      event.preventDefault();
      event.stopPropagation();
      const title = row.getAttribute('data-app-action-sidebar-thread-title') ||
        row.querySelector('[data-thread-title]')?.textContent?.trim() || '此对话';
      const ok = await showDeleteConfirm(title);
      if (!ok) return;

      const rawId = row.getAttribute('data-app-action-sidebar-thread-id') || '';
      const id = rawId.includes(':') ? rawId.split(':').slice(1).join(':') : rawId;
      if (!id) {
        showToast('未找到会话 id', 'error');
        return;
      }

      btn.disabled = true;
      try {
        const res = await window.shim('/session/delete', { id });
        if (res?.code !== 0) {
          showToast(`删除失败：${res?.message || '未知错误'}`, 'error');
          btn.disabled = false;
          return;
        }
        const container =
          row.closest('[role="listitem"]') || row.closest('.after\\:block') || row;
        container.remove();
        showToast('已删除', 'success');
      } catch (err) {
        showToast(`删除失败：${err?.message || err}`, 'error');
        btn.disabled = false;
      }
    });

    wrapper.appendChild(btn);
    return wrapper;
  }

  function ensureDeleteButtons() {
    const rows = document.querySelectorAll(
      '[data-app-action-sidebar-thread-row]',
    );
    for (const row of rows) {
      if (row.getAttribute(DELETE_BUTTON_FLAG) === '1') continue;
      const archiveButton = row.querySelector(
        'button[aria-label="归档对话"]',
      );
      if (!archiveButton) continue;
      const actionGroup = archiveButton.closest('span.contents')?.parentElement;
      if (!actionGroup) continue;
      const deleteWrapper = buildDeleteButton(row);
      actionGroup.appendChild(deleteWrapper);
      row.setAttribute(DELETE_BUTTON_FLAG, '1');
    }
  }

  // ========== 总调度 ==========

  function ensureAll() {
    ensureBadge();
    ensureShimMenuItem();
    ensureDeleteButtons();
  }

  function installUiScheduler() {
    if (!document.documentElement) {
      setTimeout(installUiScheduler, 50);
      return;
    }
    if (window.__shimUiSchedulerInstalled) {
      ensureAll();
      return;
    }
    window.__shimUiSchedulerInstalled = true;

    ensureAll();

    let scheduled = false;
    const observer = new MutationObserver(() => {
      if (scheduled) return;
      scheduled = true;
      setTimeout(() => {
        scheduled = false;
        ensureAll();
      }, 200);
    });
    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
  }

  installUiScheduler();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', ensureAll, { once: true });
  }


})();

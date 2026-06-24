// ==Shim==
// @name        Shim Injected Badge + Menu
// @description 在 Codex 工具栏「请求批准」按钮右侧显示已注入徽章，并在设置菜单顶部插入 Shim 菜单项
// @version     1.0.0
// @author      shim
// ==/Shim==
(() => {
  // ========== 全脚本 once guard ==========
  // 整个 codex_enhance.js 必须在同一个页面 context 里**只执行一次**。
  //
  // 重复执行的后果:
  //   - 每个 ensureXxx 里的 addEventListener / MutationObserver 叠 N 份
  //   - window.fetch / XMLHttpRequest hook 链叠 N 层
  //   - 用户点一次按钮触发 N 次 handler → codex 自己看着像"狂发请求"
  //
  // 触发场景:用户点 shim 的"刷新 codex"或"注入"按钮,cdp_service 走
  // Page.addScriptToEvaluateOnNewDocument(累积式注册,reload 时全部执行) +
  // Runtime.evaluate(当前页立刻再来一次)。
  //
  // cdp_service 侧也做了去重(remove + add),这里再加一层 IIFE 级别的 once
  // 是兜底,任何路径走来都只装一次。
  if (window.__shimCodexEnhanceLoaded) {
    if (typeof console !== 'undefined') {
      console.log('[Shim] codex_enhance 已加载过,跳过重复执行');
    }
    return;
  }
  window.__shimCodexEnhanceLoaded = true;

  // ========== 阻断 Statsig 等被墙的请求,避免主页面 hydration 卡 10 秒 ==========
  // ab.chatgpt.com / chatgpt.com/ces 在国内不可达,Codex 启动会等到 10s 超时,
  // 表现为主页面一直 loading。这里直接让请求立即失败,SPA 拿到 error 会走 fallback。
  (function installNetworkBlocker() {
    if (window.__shimNetBlockerInstalled) return;
    window.__shimNetBlockerInstalled = true;

    const BLOCKED_HOSTS = [
      'ab.chatgpt.com',
      'chatgpt.com/ces/',
      'statsigapi.net',
      'featuregates.org',
      'events.statsigapi.net',
    ];
    let blockedCount = 0;

    function isBlocked(url) {
      if (!url) return false;
      const s = String(url);
      for (const host of BLOCKED_HOSTS) {
        if (s.includes(host)) return true;
      }
      return false;
    }

    // 返回一个 Statsig 看起来合法的"空成功"响应,避免触发 SPA 的 error 路径(会重渲染整个页面)
    function fakeStatsigBody(url) {
      const u = String(url || '');
      if (u.includes('/v1/initialize')) {
        return JSON.stringify({
          feature_gates: {},
          dynamic_configs: {},
          layer_configs: {},
          sdkParams: {},
          has_updates: false,
          time: Date.now(),
          hash_used: 'djb2',
        });
      }
      // rgstr / log_event / 其它端点 → 空对象 200 就够
      return JSON.stringify({ success: true });
    }

    const origFetch = window.fetch;
    window.fetch = function shimBlockingFetch(input, init) {
      const url = typeof input === 'string' ? input : input?.url;
      if (isBlocked(url)) {
        blockedCount += 1;
        if (blockedCount <= 3) {
          console.log('[ShimNetBlock] fetch faked', url);
        }
        const body = fakeStatsigBody(url);
        return Promise.resolve(new Response(body, {
          status: 200,
          statusText: 'OK',
          headers: { 'Content-Type': 'application/json' },
        }));
      }
      return origFetch.apply(this, arguments);
    };

    const OrigXHR = window.XMLHttpRequest;
    const origOpen = OrigXHR.prototype.open;
    const origSend = OrigXHR.prototype.send;
    const origSetReqHeader = OrigXHR.prototype.setRequestHeader;
    OrigXHR.prototype.open = function shimBlockingOpen(method, url) {
      this.__shimBlockedUrl = url;
      this.__shimIsBlocked = isBlocked(url);
      return origOpen.apply(this, arguments);
    };
    OrigXHR.prototype.setRequestHeader = function (name, value) {
      if (this.__shimIsBlocked) return; // 不真发,header 也别真写
      return origSetReqHeader.apply(this, arguments);
    };
    OrigXHR.prototype.send = function shimBlockingSend() {
      if (this.__shimIsBlocked) {
        blockedCount += 1;
        if (blockedCount <= 3) {
          console.log('[ShimNetBlock] xhr faked', this.__shimBlockedUrl);
        }
        const body = fakeStatsigBody(this.__shimBlockedUrl);
        setTimeout(() => {
          try {
            Object.defineProperty(this, 'readyState', { value: 4, configurable: true });
            Object.defineProperty(this, 'status', { value: 200, configurable: true });
            Object.defineProperty(this, 'statusText', { value: 'OK', configurable: true });
            Object.defineProperty(this, 'responseText', { value: body, configurable: true });
            Object.defineProperty(this, 'response', { value: body, configurable: true });
            Object.defineProperty(this, 'responseURL', { value: this.__shimBlockedUrl, configurable: true });
            this.dispatchEvent(new Event('readystatechange'));
            this.dispatchEvent(new Event('load'));
            this.dispatchEvent(new Event('loadend'));
          } catch (_) {}
        }, 0);
        return;
      }
      return origSend.apply(this, arguments);
    };

    // sendBeacon 也可能被 Statsig 用,直接返回 true 装作发了
    const origBeacon = navigator.sendBeacon?.bind(navigator);
    if (origBeacon) {
      navigator.sendBeacon = function shimBlockingBeacon(url, data) {
        if (isBlocked(url)) {
          blockedCount += 1;
          if (blockedCount <= 3) console.log('[ShimNetBlock] beacon faked', url);
          return true;
        }
        return origBeacon(url, data);
      };
    }

    console.log('[ShimNetBlock] installed (fake-success mode), targets:', BLOCKED_HOSTS.join(', '));
  })();

  const BADGE_ID = '__shim_injected_badge__';
  const MENU_ITEM_ID = '__shim_menu_item__';
  const POPOVER_ID = '__shim_popover__';
  const PROVIDER_PICKER_ID = '__shim_provider_picker__';
  const PROVIDER_PICKER_POPOVER_ID = '__shim_provider_picker_popover__';

  const BADGE_ANCHOR_SVG_D_PREFIX = 'M16.835 8.66301C16.835 7.71885';
  const SETTINGS_ANCHOR_SVG_D_PREFIX = 'M9.99944 7.24939';
  const SEND_BUTTON_SVG_D_PREFIX = 'M9.33467 16.6663V4.93978';
  const CODEX_MODEL_SELECTOR_FLAG = 'data-shim-hidden-codex-model-selector';

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
      if (typeof __t === 'function') __t('ensureBadge: REPLACE inline', { hadExisting: !!existing });
      existing?.remove();
      anchor.appendChild(buildBadge(true));
      return;
    }
    if (existing) return;
    if (typeof __t === 'function') __t('ensureBadge: INSERT fixed (no anchor)');
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
    if (typeof __t === 'function') __t('ensureShimMenuItem: INSERT into settings menu');
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
      heading.textContent = S('deleteHeading', 'Delete thread');
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
      desc.textContent =
        S('deleteConfirmPrefix', 'Delete "') + title +
        S('deleteConfirmSuffix', '"? This cannot be undone.');

      const actions = document.createElement('div');
      Object.assign(actions.style, {
        display: 'flex',
        justifyContent: 'flex-end',
        gap: '8px',
      });

      const cancelBtn = document.createElement('button');
      cancelBtn.type = 'button';
      cancelBtn.textContent = S('cancel', 'Cancel');
      cancelBtn.className =
        'border-token-border no-drag cursor-interaction flex items-center gap-1 border whitespace-nowrap select-none focus:outline-none rounded-full text-token-foreground hover:bg-token-list-hover-background px-3 py-1.5 text-sm';

      const okBtn = document.createElement('button');
      okBtn.type = 'button';
      okBtn.textContent = S('deleteOk', 'Delete');
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

  const THREAD_MENU_ID = '__shim_thread_menu__';

  function dismissThreadMenu() {
    document.getElementById(THREAD_MENU_ID)?.remove();
    document.removeEventListener('mousedown', __onThreadMenuOutside, true);
    document.removeEventListener('keydown', __onThreadMenuKey, true);
  }

  function __onThreadMenuOutside(event) {
    const menu = document.getElementById(THREAD_MENU_ID);
    if (!menu) return;
    if (menu.contains(event.target)) return;
    dismissThreadMenu();
  }
  function __onThreadMenuKey(event) {
    if (event.key === 'Escape') dismissThreadMenu();
  }

  function openThreadMenu(anchorBtn, row) {
    console.log('[ShimMenu] openThreadMenu');
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
      outline: '0.5px solid var(--token-border, rgba(255,255,255,0.08))',
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
        console.log('[ShimMenu] item click', label);
        dismissThreadMenu();
        try {
          await onClick();
        } catch (err) {
          console.error('[ShimMenu] onClick error', err);
        }
      };
      // mousedown/pointerdown 也得吞,避免 __onThreadMenuOutside 先把菜单关掉
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
    const ICON_DEL = `<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 4h10M6 4V3a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v1M4.5 4l.7 9a1 1 0 0 0 1 .9h3.6a1 1 0 0 0 1-.9l.7-9" stroke="currentColor" stroke-width="1.2"/></svg>`;

    addItem({
      label: S('threadExportMarkdown', 'Export as Markdown'),
      icon: ICON_MD,
      onClick: () => exportThread(row, 'markdown'),
    });
    addItem({
      label: S('threadExportRaw', 'Export raw data'),
      icon: ICON_RAW,
      onClick: () => exportThread(row, 'raw'),
    });
    // 分隔线
    const sep = document.createElement('div');
    sep.style.cssText = 'height:1px;margin:4px 6px;background:var(--token-border,rgba(255,255,255,0.10));';
    menu.appendChild(sep);
    addItem({
      label: S('deleteOk', 'Delete'),
      icon: ICON_DEL,
      destructive: true,
      onClick: () => deleteThread(row),
    });

    document.body.appendChild(menu);
    // 定位:挂在 anchorBtn 下方右对齐
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

    document.addEventListener('mousedown', __onThreadMenuOutside, true);
    document.addEventListener('keydown', __onThreadMenuKey, true);
  }

  function threadIdFromRow(row) {
    const rawId = row.getAttribute('data-app-action-sidebar-thread-id') || '';
    return rawId.includes(':') ? rawId.split(':').slice(1).join(':') : rawId;
  }

  async function exportThread(row, format) {
    const id = threadIdFromRow(row);
    if (!id) {
      showToast(S('deleteSessionIdMissing', 'Session id not found'), 'error');
      return;
    }
    try {
      const res = await window.shim('/session/export', { id, format });
      if (res?.code !== 0) {
        showToast(`${S('threadExportFailed', 'Export failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
        return;
      }
      if (res.data?.cancelled) return; // 用户取消保存
      showToast(S('threadExportedToast', 'Exported'), 'success');
    } catch (err) {
      showToast(`${S('threadExportFailed', 'Export failed')}: ${err?.message || err}`, 'error');
    }
  }

  async function deleteThread(row) {
    const title = row.getAttribute('data-app-action-sidebar-thread-title') ||
      row.querySelector('[data-thread-title]')?.textContent?.trim() ||
      S('deleteDefaultTitle', 'this thread');
    const ok = await showDeleteConfirm(title);
    if (!ok) return;
    const id = threadIdFromRow(row);
    if (!id) {
      showToast(S('deleteSessionIdMissing', 'Session id not found'), 'error');
      return;
    }
    try {
      const res = await window.shim('/session/delete', { id });
      if (res?.code !== 0) {
        showToast(`${S('deleteFailed', 'Delete failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
        return;
      }
      const container =
        row.closest('[role="listitem"]') || row.closest('.after\\:block') || row;
      container.remove();
      showToast(S('deleteSuccess', 'Deleted'), 'success');
    } catch (err) {
      showToast(`${S('deleteFailed', 'Delete failed')}: ${err?.message || err}`, 'error');
    }
  }

  function buildDeleteButton(row) {
    // 复用旧函数名(DELETE_BUTTON_FLAG 等不变),但内部改成三点菜单
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

  function ensureDeleteButtons() {
    const rows = document.querySelectorAll(
      '[data-app-action-sidebar-thread-row]',
    );
    let added = 0;
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
      added += 1;
    }
    if (added > 0 && typeof __t === 'function') __t('ensureDeleteButtons: INSERT', { added, totalRows: rows.length });
  }

  // ========== 对话供应商标签（只标注最新 turn） ==========

  const PROVIDER_BADGE_CLASS = '__shim_provider_badge__';
  // 当前供应商标签缓存（已含语言前缀，如「供应商：muxue」），由 bridge 拉取并定时刷新
  let shimCurrentProviderLabel = null;
  let shimProviderState = {
    selectedId: null,
    reasoningEffort: 'high',
    providers: [],
    labels: {},
  };
  let shimProviderRefreshInFlight = null;

  // 取 dart 返回的本地化文案;万一没拉到走 fallback 不会留下中文。
  function S(key, fallback) {
    const v = shimProviderState.labels && shimProviderState.labels[key];
    return v || fallback || '';
  }

  function refreshCurrentProvider() {
    if (typeof window.shim !== 'function') return;
    window.shim('/provider/current', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimCurrentProviderLabel = res.data.label ?? null;
        ensureProviderBadge();
      }
    }).catch(() => {});
  }

  /// rebuildPopover=false 时不重建 popover 内容(避免用户点击按钮被销毁),
  /// 但 picker 按钮和 Codex 原生选择器可见性依然刷新。
  function refreshProviderPickerState(opts) {
    if (typeof window.shim !== 'function') return;
    const rebuildPopover = !opts || opts.rebuildPopover !== false;
    if (shimProviderRefreshInFlight) return shimProviderRefreshInFlight;
    shimProviderRefreshInFlight = window.shim('/provider/list', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimProviderState = {
          selectedId: res.data.selectedId ?? null,
          reasoningEffort: res.data.reasoningEffort || 'high',
          providers: Array.isArray(res.data.providers) ? res.data.providers : [],
          labels: res.data.labels || {},
        };
        updateProviderPickerButton();
        if (rebuildPopover) updateProviderPickerPopover();
        updateCodexModelSelectorVisibility();
      }
    }).catch(() => {}).finally(() => {
      shimProviderRefreshInFlight = null;
    });
    return shimProviderRefreshInFlight;
  }

  function scheduleProviderPickerRefresh() {
    const run = () => refreshProviderPickerState();
    if (typeof window.requestIdleCallback === 'function') {
      window.requestIdleCallback(run, { timeout: 600 });
      return;
    }
    setTimeout(run, 80);
  }

  function currentProvider() {
    return shimProviderState.providers.find(
      (p) => p.id === shimProviderState.selectedId,
    ) || null;
  }

  function findProviderPickerAnchor() {
    const paths = document.querySelectorAll('svg path');
    for (const path of paths) {
      const d = path.getAttribute('d');
      if (!d || !d.startsWith(SEND_BUTTON_SVG_D_PREFIX)) continue;
      const button = path.closest('button');
      const group = button?.closest('.flex.shrink-0.items-center.gap-2');
      if (button && group) return { group, button };
    }
    return null;
  }

  function buildProviderPickerButton() {
    const button = document.createElement('button');
    button.id = PROVIDER_PICKER_ID;
    button.type = 'button';
    button.className =
      'no-drag cursor-interaction flex items-center gap-1 whitespace-nowrap select-none focus:outline-none rounded-full text-token-foreground';
    Object.assign(button.style, {
      height: '30px',
      maxWidth: '360px',
      padding: '0 10px',
      border: '1px solid rgba(127, 127, 127, 0.38)',
      background: 'rgba(127, 127, 127, 0.18)',
      boxShadow: '0 1px 3px rgba(0, 0, 0, 0.12)',
      fontSize: '13px',
      fontWeight: '600',
      lineHeight: '1',
    });
    button.addEventListener('pointerdown', (event) => {
      if (isProviderModelClearTarget(event.target)) return;
      event.preventDefault();
      event.stopPropagation();
    }, true);
    button.addEventListener('mousedown', (event) => {
      if (isProviderModelClearTarget(event.target)) return;
      event.preventDefault();
      event.stopPropagation();
    }, true);
    button.addEventListener('click', (event) => {
      if (isProviderModelClearTarget(event.target)) return;
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      toggleProviderPickerPopover(button);
    }, true);
    return button;
  }

  function providerProtocolValue(provider) {
    const value = provider?.protocol || provider?.upstreamProtocol || 'responses';
    if (value === 'chat' || value === 'messages') return value;
    return 'responses';
  }

  function providerProtocolLabel(protocol) {
    if (protocol === 'chat') return 'Chat';
    if (protocol === 'messages') return 'Messages';
    return 'Responses';
  }

  function buildProviderProtocolChip(protocol) {
    const chip = document.createElement('span');
    chip.textContent = providerProtocolLabel(protocol);
    Object.assign(chip.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      flex: '0 0 auto',
      height: '20px',
      padding: '0 6px',
      borderRadius: '999px',
      background: protocol === 'messages'
        ? 'rgba(16, 185, 129, 0.16)'
        : protocol === 'chat'
          ? 'rgba(59, 130, 246, 0.16)'
          : 'rgba(127, 127, 127, 0.14)',
      color: protocol === 'messages'
        ? '#34d399'
        : protocol === 'chat'
          ? '#60a5fa'
          : 'var(--text-secondary, currentColor)',
      fontSize: '11px',
      fontWeight: '700',
      lineHeight: '1',
      whiteSpace: 'nowrap',
    });
    return chip;
  }
  function updateProviderPickerButton() {
    const button = document.getElementById(PROVIDER_PICKER_ID);
    if (!button) return;
    const provider = currentProvider();
    const selectedModel = provider?.selectedModel || '';
    const providerName = provider?.name || S('providerFallback', 'Provider');
    const protocol = providerProtocolValue(provider);
    const renderKey = [
      provider?.id || '',
      providerName,
      protocol,
      selectedModel,
      shimProviderState.reasoningEffort || 'high',
    ].join('|');
    if (button.getAttribute('data-shim-render-key') === renderKey) {
      updateCodexModelSelectorVisibility();
      return;
    }
    button.setAttribute('data-shim-render-key', renderKey);
    button.innerHTML = '';

    button.appendChild(buildProviderProtocolChip(protocol));

    const name = document.createElement('span');
    name.textContent = providerName;
    Object.assign(name.style, {
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
      maxWidth: selectedModel ? '120px' : '220px',
    });
    button.appendChild(name);

    if (selectedModel) {
      const model = document.createElement('span');
      model.textContent = selectedModel;
      Object.assign(model.style, {
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        maxWidth: '170px',
        color: 'var(--text-primary, currentColor)',
      });
      button.appendChild(model);

      if (shouldShowShimReasoningEffort(selectedModel)) {
        const effort = document.createElement('span');
        effort.textContent = reasoningEffortLabel(
          shimProviderState.reasoningEffort || 'high',
        );
        Object.assign(effort.style, {
          padding: '2px 5px',
          borderRadius: '999px',
          background: 'rgba(59, 130, 246, 0.16)',
          color: '#60a5fa',
          fontSize: '11px',
          fontWeight: '700',
          lineHeight: '1.2',
        });
        button.appendChild(effort);
      }

      const clear = document.createElement('span');
      clear.textContent = '×';
      clear.setAttribute('data-shim-clear-model', '1');
      clear.setAttribute('aria-label', S('clearModel', 'Clear model'));
      Object.assign(clear.style, {
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: '16px',
        height: '16px',
        borderRadius: '999px',
        fontSize: '14px',
        fontWeight: '700',
      });
      clear.addEventListener('pointerdown', (event) => {
        event.preventDefault();
        event.stopPropagation();
      }, true);
      clear.addEventListener('click', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        if (!provider?.id) return;
        await selectProviderModel(provider.id, null, 'click:clear-model-x');
      }, true);
      button.appendChild(clear);
    }
    updateCodexModelSelectorVisibility();
  }

  function isProviderModelClearTarget(target) {
    return !!target?.closest?.('[data-shim-clear-model="1"]');
  }

  function selectedShimModel() {
    const provider = currentProvider();
    return provider?.selectedModel || '';
  }

  function supportsCodexReasoningEffort(model) {
    const name = String(model || '').toLowerCase();
    if (!name) return false;
    if (
      name.includes('image') ||
      name.includes('img') ||
      name.includes('dall-e') ||
      name.includes('dalle')
    ) {
      return false;
    }
    return name.includes('gpt');
  }

  function shouldShowShimReasoningEffort(model) {
    return supportsCodexReasoningEffort(model);
  }

  function reasoningEffortLabel(value) {
    if (value === 'low') return S('effortLow', 'Low');
    if (value === 'medium') return S('effortMedium', 'Med');
    if (value === 'xhigh') return S('effortXHigh', 'XHigh');
    return S('effortHigh', 'High');
  }

  function findCodexModelSelector() {
    const trigger = document.querySelector(
      'button[data-codex-intelligence-trigger="true"]',
    );
    if (!trigger) return null;
    return trigger.closest('span.contents') || trigger;
  }

  function updateCodexModelSelectorVisibility() {
    const model = selectedShimModel();
    const shouldHide = !!model;
    const selector =
      findCodexModelSelector() ||
      document.querySelector(`[${CODEX_MODEL_SELECTOR_FLAG}="1"]`);
    if (!selector) return;

    if (shouldHide) {
      selector.setAttribute(CODEX_MODEL_SELECTOR_FLAG, '1');
      selector.style.display = 'none';
    } else if (selector.getAttribute(CODEX_MODEL_SELECTOR_FLAG) === '1') {
      selector.removeAttribute(CODEX_MODEL_SELECTOR_FLAG);
      selector.style.removeProperty('display');
    }
  }

  function ensureProviderPicker() {
    if (document.getElementById(PROVIDER_PICKER_ID)) {
      updateProviderPickerButton();
      return;
    }
    const anchor = findProviderPickerAnchor();
    if (!anchor) {
      if (typeof __t === 'function') __t('ensureProviderPicker: anchor missing');
      return;
    }

    if (typeof __t === 'function') __t('ensureProviderPicker: INSERT button');
    const button = buildProviderPickerButton();
    anchor.group.insertBefore(button, anchor.button);
    updateProviderPickerButton();
    refreshProviderPickerState();
  }

  function toggleProviderPickerPopover(anchor) {
    const existing = document.getElementById(PROVIDER_PICKER_POPOVER_ID);
    if (existing) {
      dismissProviderPickerPopover();
      return;
    }
    const popover = buildProviderPickerPopover();
    document.body.appendChild(popover);
    positionProviderPickerPopover(popover, anchor);
    document.addEventListener('mousedown', onProviderPickerOutside, true);
    document.addEventListener('keydown', onProviderPickerKey, true);
    scheduleProviderPickerRefresh();
    triggerHealthRefresh();
    ensureAutoSwitchLoaded().then(() => updateProviderPickerPopover());
  }

  // picker 打开 → 测速触发的客户端节流(60s 内不重复打,后端也有同样的去重兜底)
  let __shimLastHealthRefreshAt = 0;
  function triggerHealthRefresh() {
    if (typeof window.shim !== 'function') return;
    const now = Date.now();
    if (now - __shimLastHealthRefreshAt < 60 * 1000) return;
    __shimLastHealthRefreshAt = now;
    // 默认 scope = selected,只测当前选中的家;用户量大也只多一次中转
    window.shim('/provider/health/refresh', {}).then(() => {
      refreshProviderPickerState();
    }).catch(() => {});
  }

  function dismissProviderPickerPopover() {
    document.getElementById(PROVIDER_PICKER_POPOVER_ID)?.remove();
    document.removeEventListener('mousedown', onProviderPickerOutside, true);
    document.removeEventListener('keydown', onProviderPickerKey, true);
  }

  function onProviderPickerOutside(event) {
    const popover = document.getElementById(PROVIDER_PICKER_POPOVER_ID);
    const button = document.getElementById(PROVIDER_PICKER_ID);
    if (!popover) return;
    if (popover.contains(event.target)) return;
    if (button && button.contains(event.target)) return;
    dismissProviderPickerPopover();
  }

  function onProviderPickerKey(event) {
    if (event.key === 'Escape') dismissProviderPickerPopover();
  }

  function positionProviderPickerPopover(popover, anchor) {
    const rect = anchor.getBoundingClientRect();
    const popRect = popover.getBoundingClientRect();
    let left = rect.left;
    let top = rect.bottom + 8;
    if (left + popRect.width > window.innerWidth - 8) {
      left = window.innerWidth - popRect.width - 8;
    }
    if (top + popRect.height > window.innerHeight - 8) {
      top = rect.top - popRect.height - 8;
    }
    popover.style.left = `${Math.max(8, left)}px`;
    popover.style.top = `${Math.max(8, top)}px`;
  }

  function buildProviderPickerPopover() {
    const popover = document.createElement('div');
    popover.id = PROVIDER_PICKER_POPOVER_ID;
    popover.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(popover.style, {
      position: 'fixed',
      zIndex: '2147483647',
      width: '320px',
      maxHeight: 'min(420px, calc(100vh - 24px))',
      overflowX: 'hidden',
      overflowY: 'auto',
      overscrollBehavior: 'contain',
      padding: '6px',
      borderRadius: '12px',
      outline: '0.5px solid var(--token-border, rgba(255,255,255,0.08))',
      boxShadow: '0 16px 42px rgba(0, 0, 0, 0.35)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '13px',
    });
    renderProviderPickerPopover(popover);
    return popover;
  }

  function updateProviderPickerPopover() {
    const popover = document.getElementById(PROVIDER_PICKER_POPOVER_ID);
    if (popover) renderProviderPickerPopover(popover);
  }

  function buildProbeButton(provider) {
    // 渲染成 span (而不是 button) —— 父级 providerRow 已经是 <button>,
    // 浏览器不允许嵌套 button。click 事件用 capture 阶段拦截,阻止冒泡到父级 selectProvider。
    const btn = document.createElement('span');
    btn.setAttribute('role', 'button');
    btn.setAttribute('aria-label', S('probeNow', 'Measure latency'));
    btn.setAttribute('title', S('probeNow', 'Measure latency'));
    btn.setAttribute('data-shim-probe-btn', '1');
    Object.assign(btn.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      flex: '0 0 auto',
      width: '20px',
      height: '20px',
      marginLeft: '6px',
      borderRadius: '6px',
      cursor: 'pointer',
      color: 'var(--text-secondary, currentColor)',
      opacity: '0.7',
    });
    btn.innerHTML = `
      <svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8 1.5a6.5 6.5 0 1 0 6.5 6.5h-1.5a5 5 0 1 1-5-5V1.5z" fill="currentColor"/>
        <path d="M8 4.5l3 3-3 1V4.5z" fill="currentColor"/>
      </svg>
    `;
    btn.addEventListener('mouseenter', () => { btn.style.opacity = '1'; });
    btn.addEventListener('mouseleave', () => {
      if (btn.dataset.shimProbing !== '1') btn.style.opacity = '0.7';
    });
    const stopAll = (e) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
    };
    // 阻止外层 providerRow 的 click capture 拦截到这里再触发 selectProvider
    btn.addEventListener('pointerdown', stopAll, true);
    btn.addEventListener('mousedown', stopAll, true);
    btn.addEventListener('click', async (event) => {
      stopAll(event);
      if (btn.dataset.shimProbing === '1') return;
      btn.dataset.shimProbing = '1';
      btn.style.opacity = '1';
      // 简单转圈动画
      btn.style.transition = 'transform 0.6s linear';
      let angle = 0;
      const spin = setInterval(() => {
        angle = (angle + 60) % 360;
        btn.style.transform = `rotate(${angle}deg)`;
      }, 100);
      try {
        await window.shim('/provider/health/refresh', {
          id: provider.id,
          force: true,
        });
        // 拉新的 list,弹层开着时只刷数据不重建按钮(避免破坏其它点击),
        // 但 health chip 要更新到本行 → 我们手动只更新这一行的 chip
        await refreshProviderPickerState({ rebuildPopover: false });
        const updated = (shimProviderState.providers || []).find((p) => p.id === provider.id);
        if (updated) {
          const chip = btn.nextSibling;
          if (chip && chip.parentElement === btn.parentElement) {
            const newChip = buildHealthChip(updated.health);
            btn.parentElement.replaceChild(newChip, chip);
          }
        }
      } catch (err) {
        showToast(`${err?.message || err}`, 'error');
      } finally {
        clearInterval(spin);
        btn.style.transform = '';
        btn.style.transition = '';
        btn.dataset.shimProbing = '0';
        btn.style.opacity = '0.7';
      }
    }, true);
    return btn;
  }

  function buildHealthChip(health) {
    const chip = document.createElement('span');
    Object.assign(chip.style, {
      display: 'inline-flex',
      alignItems: 'center',
      flex: '0 0 auto',
      marginLeft: '6px',
      padding: '1px 6px',
      borderRadius: '999px',
      fontSize: '11px',
      fontWeight: '700',
      lineHeight: '1.4',
      whiteSpace: 'nowrap',
    });
    if (!health || health.status === 'unknown') {
      chip.textContent = '—';
      chip.style.background = 'rgba(127,127,127,0.16)';
      chip.style.color = 'var(--text-secondary, currentColor)';
      return chip;
    }
    if (health.status === 'unreachable') {
      chip.textContent = S('healthTimeout', 'timeout');
      chip.style.background = 'rgba(239, 68, 68, 0.18)';
      chip.style.color = '#ef4444';
      return chip;
    }
    const ms = typeof health.latencyMs === 'number' ? `${health.latencyMs}ms` : '—';
    chip.textContent = ms;
    if (health.status === 'slow') {
      chip.style.background = 'rgba(234, 179, 8, 0.18)';
      chip.style.color = '#eab308';
    } else {
      chip.style.background = 'rgba(34, 197, 94, 0.18)';
      chip.style.color = '#22c55e';
    }
    return chip;
  }

  function renderProviderPickerPopover(popover) {
    const providers = shimProviderState.providers;
    if (!providers.length) {
      const empty = document.createElement('div');
      empty.textContent = S('noProviders', 'No providers configured yet');
      empty.className = 'text-token-text-tertiary';
      Object.assign(empty.style, {
        padding: '12px',
        textAlign: 'center',
      });
      popover.replaceChildren(empty);
      return;
    }

    const fragment = document.createDocumentFragment();
    for (const provider of providers) {
      const providerRow = document.createElement('button');
      providerRow.type = 'button';
      providerRow.className =
        'no-drag cursor-interaction flex items-center gap-2 rounded-lg hover:bg-token-list-hover-background';
      Object.assign(providerRow.style, {
        width: '100%',
        minHeight: '34px',
        padding: '8px 10px',
        border: '0',
        background: provider.id === shimProviderState.selectedId
          ? 'var(--token-main-surface-secondary, rgba(255,255,255,0.08))'
          : 'transparent',
        color: 'inherit',
        textAlign: 'left',
      });
      providerRow.addEventListener('click', async (event) => {
        // 点的是测速按钮 → 放行(让按钮自己的 listener 跑)
        if (event.target.closest && event.target.closest('[data-shim-probe-btn="1"]')) {
          return;
        }
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        await selectProvider(provider.id, 'click:provider-row');
      }, true);

      const name = document.createElement('span');
      name.textContent = provider.name || S('unnamedProvider', 'Unnamed provider');
      Object.assign(name.style, {
        flex: '1',
        minWidth: '0',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        fontWeight: provider.id === shimProviderState.selectedId ? '700' : '500',
      });
      providerRow.appendChild(name);
      providerRow.appendChild(buildProbeButton(provider));
      providerRow.appendChild(buildHealthChip(provider.health));
      fragment.appendChild(providerRow);

      if (provider.id === shimProviderState.selectedId) {
        const modelList = document.createElement('div');
        Object.assign(modelList.style, {
          margin: '0 0 4px 14px',
          paddingLeft: '10px',
          borderLeft: '1px solid var(--token-border, rgba(255,255,255,0.10))',
          maxHeight: '260px',
          overflowX: 'hidden',
          overflowY: 'auto',
          overscrollBehavior: 'contain',
        });
        const models = Array.isArray(provider.models) ? provider.models : [];
        if (!models.length) {
          const empty = document.createElement('div');
          empty.textContent = S('providerNoModels', 'No models for this provider');
          empty.className = 'text-token-text-tertiary';
          Object.assign(empty.style, { padding: '6px 8px' });
          modelList.appendChild(empty);
        }
        for (const modelName of models) {
          const modelRow = document.createElement('button');
          modelRow.type = 'button';
          modelRow.textContent = modelName;
          modelRow.className =
            'no-drag cursor-interaction rounded-md hover:bg-token-list-hover-background';
          Object.assign(modelRow.style, {
            display: 'block',
            width: '100%',
            minHeight: '30px',
            padding: '6px 8px',
            border: '0',
            background: modelName === provider.selectedModel
              ? 'var(--token-main-surface-tertiary, rgba(255,255,255,0.10))'
              : 'transparent',
            color: 'inherit',
            textAlign: 'left',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
            fontWeight: modelName === provider.selectedModel ? '700' : '400',
          });
          modelRow.addEventListener('click', async (event) => {
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation();
            await selectProviderModel(provider.id, modelName, 'click:model-row');
            if (!shouldShowShimReasoningEffort(modelName)) {
              dismissProviderPickerPopover();
            }
          }, true);
          modelList.appendChild(modelRow);
        }
        if (shouldShowShimReasoningEffort(provider.selectedModel)) {
          modelList.appendChild(buildReasoningEffortPicker(provider.id));
        }
        fragment.appendChild(modelList);
      }
    }

    fragment.appendChild(buildAutoSwitchFooter());
    popover.replaceChildren(fragment);
  }

  function buildReasoningEffortPicker(providerId) {
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      marginTop: '8px',
      padding: '8px',
      borderRadius: '8px',
      background: 'rgba(127, 127, 127, 0.10)',
    });

    const label = document.createElement('div');
    label.textContent = S('reasoningEffort', 'Reasoning');
    Object.assign(label.style, {
      marginBottom: '6px',
      fontSize: '12px',
      fontWeight: '700',
      color: 'var(--text-secondary, currentColor)',
    });
    wrap.appendChild(label);

    const choices = document.createElement('div');
    Object.assign(choices.style, {
      display: 'grid',
      gridTemplateColumns: 'repeat(4, minmax(0, 1fr))',
      gap: '4px',
    });

    const items = [
      ['low', S('effortLow', 'Low')],
      ['medium', S('effortMedium', 'Med')],
      ['high', S('effortHigh', 'High')],
      ['xhigh', S('effortXHigh', 'XHigh')],
    ];
    for (const [value, text] of items) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = text;
      const selected = (shimProviderState.reasoningEffort || 'high') === value;
      Object.assign(btn.style, {
        height: '28px',
        border: selected
          ? '1px solid rgba(59, 130, 246, 0.75)'
          : '1px solid rgba(127, 127, 127, 0.25)',
        borderRadius: '7px',
        background: selected
          ? 'rgba(59, 130, 246, 0.20)'
          : 'rgba(127, 127, 127, 0.08)',
        color: 'inherit',
        fontSize: '12px',
        fontWeight: selected ? '700' : '500',
      });
      btn.addEventListener('click', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        await selectReasoningEffort(providerId, value);
      }, true);
      choices.appendChild(btn);
    }
    wrap.appendChild(choices);
    return wrap;
  }

  // ========== 自动切换 ==========

  let shimAutoSwitch = null; // {strategy, scope, failureThreshold, fastestMarginMs, cooldownSeconds, probeIntervalSeconds}
  let shimAutoSwitchExpanded = false;

  function ensureAutoSwitchLoaded() {
    if (shimAutoSwitch || typeof window.shim !== 'function') return Promise.resolve();
    return window.shim('/auto-switch/get', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimAutoSwitch = res.data;
      }
    }).catch(() => {});
  }

  function saveAutoSwitch(patch) {
    const next = Object.assign({}, shimAutoSwitch || {}, patch);
    return window.shim('/auto-switch/set', next).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimAutoSwitch = res.data;
        updateProviderPickerPopover();
      } else {
        showToast(`${S('saveFailed', 'Save failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      }
    }).catch((err) => {
      showToast(`${S('saveFailed', 'Save failed')}: ${err?.message || err}`, 'error');
    });
  }

  function shimAutoSwitchLabels() {
    return (shimAutoSwitch && shimAutoSwitch.labels) || {};
  }

  function strategyLabel(value) {
    const L = shimAutoSwitchLabels();
    if (value === 'failover') return L.strategyFailover || 'Failover';
    if (value === 'fastest') return L.strategyFastest || 'Fastest';
    return L.strategyManual || 'Manual';
  }

  function scopeLabel(value) {
    const L = shimAutoSwitchLabels();
    if (value === 'same-protocol') return L.scopeSameProtocol || 'Same proto';
    if (value === 'any') return L.scopeAny || 'Any';
    return L.scopeSameType || 'Same type';
  }

  function buildAutoSwitchFooter() {
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      marginTop: '8px',
      borderTop: '1px solid var(--token-border, rgba(255,255,255,0.10))',
      paddingTop: '8px',
    });

    const header = document.createElement('button');
    header.type = 'button';
    header.className = 'no-drag cursor-interaction rounded-md hover:bg-token-list-hover-background';
    Object.assign(header.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '6px',
      width: '100%',
      minHeight: '32px',
      padding: '6px 8px',
      border: '0',
      background: 'transparent',
      color: 'inherit',
      textAlign: 'left',
      fontSize: '12px',
      fontWeight: '700',
    });
    const L = shimAutoSwitchLabels();
    const headerLabel = document.createElement('span');
    headerLabel.textContent = '⚙ ' + (L.title || 'Auto switch');
    headerLabel.style.flex = '1';

    const summary = document.createElement('span');
    summary.style.color = 'var(--text-secondary, currentColor)';
    summary.style.fontWeight = '500';
    summary.style.fontSize = '11px';
    if (shimAutoSwitch) {
      summary.textContent = `${strategyLabel(shimAutoSwitch.strategy)} · ${scopeLabel(shimAutoSwitch.scope)}`;
    } else {
      summary.textContent = '…';
    }

    const caret = document.createElement('span');
    caret.textContent = shimAutoSwitchExpanded ? '▴' : '▾';
    caret.style.fontSize = '10px';
    caret.style.opacity = '0.6';

    header.appendChild(headerLabel);
    header.appendChild(summary);
    header.appendChild(caret);
    header.addEventListener('click', async (event) => {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      shimAutoSwitchExpanded = !shimAutoSwitchExpanded;
      if (shimAutoSwitchExpanded) await ensureAutoSwitchLoaded();
      updateProviderPickerPopover();
    }, true);
    wrap.appendChild(header);

    if (shimAutoSwitchExpanded && shimAutoSwitch) {
      const body = document.createElement('div');
      Object.assign(body.style, {
        marginTop: '6px',
        padding: '8px',
        borderRadius: '8px',
        background: 'rgba(127, 127, 127, 0.10)',
      });

      body.appendChild(buildAutoSwitchSegment(L.strategy || 'Strategy', 'strategy', [
        ['manual', L.strategyManual || 'Manual'],
        ['failover', L.strategyFailover || 'Failover'],
        ['fastest', L.strategyFastest || 'Fastest'],
      ]));

      body.appendChild(buildAutoSwitchSegment(L.scope || 'Scope', 'scope', [
        ['same-type', L.scopeSameType || 'Same type'],
        ['same-protocol', L.scopeSameProtocol || 'Same proto'],
        ['any', L.scopeAny || 'Any'],
      ]));

      body.appendChild(buildAutoSwitchNumberRow(L.failureThreshold || 'Threshold', 'failureThreshold', L.unitTimes || 'x', 1, 10, 1));
      body.appendChild(buildAutoSwitchNumberRow(L.fastestMarginMs || 'Margin', 'fastestMarginMs', L.unitMs || 'ms', 50, 2000, 50));
      body.appendChild(buildAutoSwitchNumberRow(L.cooldownSeconds || 'Cooldown', 'cooldownSeconds', L.unitSeconds || 's', 5, 600, 5));
      body.appendChild(buildAutoSwitchNumberRow(L.probeIntervalSeconds || 'Interval', 'probeIntervalSeconds', L.unitSeconds || 's', 60, 1800, 30));
      body.appendChild(buildAutoSwitchNumberRow(L.slowRequestTimeoutSeconds || 'Slow th.', 'slowRequestTimeoutSeconds', L.unitSeconds || 's', 0, 120, 5));
      body.appendChild(buildAutoSwitchNumberRow(L.slowRequestSwitchThreshold || 'Slow streak', 'slowRequestSwitchThreshold', L.unitTimes || 'x', 1, 10, 1));
      body.appendChild(buildAutoSwitchSegment(L.allowSameProviderSibling || 'Sibling fallback', 'allowSameProviderSibling', [
        [false, L.allowSameProviderSiblingOff || 'Off'],
        [true, L.allowSameProviderSiblingOn || 'On'],
      ]));

      wrap.appendChild(body);
    }

    return wrap;
  }

  function buildAutoSwitchSegment(labelText, fieldKey, items) {
    const row = document.createElement('div');
    Object.assign(row.style, {
      marginBottom: '8px',
    });

    const label = document.createElement('div');
    label.textContent = labelText;
    Object.assign(label.style, {
      marginBottom: '4px',
      fontSize: '11px',
      fontWeight: '700',
      color: 'var(--text-secondary, currentColor)',
    });
    row.appendChild(label);

    const choices = document.createElement('div');
    Object.assign(choices.style, {
      display: 'grid',
      gridTemplateColumns: `repeat(${items.length}, minmax(0, 1fr))`,
      gap: '4px',
    });
    for (const [value, text] of items) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = text;
      const selected = shimAutoSwitch[fieldKey] === value;
      Object.assign(btn.style, {
        height: '26px',
        border: selected
          ? '1px solid rgba(59, 130, 246, 0.75)'
          : '1px solid rgba(127, 127, 127, 0.25)',
        borderRadius: '6px',
        background: selected
          ? 'rgba(59, 130, 246, 0.20)'
          : 'rgba(127, 127, 127, 0.08)',
        color: 'inherit',
        fontSize: '11px',
        fontWeight: selected ? '700' : '500',
      });
      btn.addEventListener('click', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        await saveAutoSwitch({ [fieldKey]: value });
      }, true);
      choices.appendChild(btn);
    }
    row.appendChild(choices);
    return row;
  }

  function buildAutoSwitchNumberRow(labelText, fieldKey, suffix, min, max, step) {
    const row = document.createElement('div');
    Object.assign(row.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '6px',
      marginBottom: '4px',
    });

    const label = document.createElement('span');
    label.textContent = labelText;
    Object.assign(label.style, {
      flex: '1',
      fontSize: '11px',
      color: 'var(--text-secondary, currentColor)',
    });

    const current = Number(shimAutoSwitch[fieldKey] ?? 0);

    function btn(text, delta, disabled) {
      const b = document.createElement('button');
      b.type = 'button';
      b.textContent = text;
      Object.assign(b.style, {
        width: '20px',
        height: '20px',
        border: '1px solid rgba(127, 127, 127, 0.25)',
        borderRadius: '5px',
        background: 'rgba(127, 127, 127, 0.08)',
        color: 'inherit',
        fontSize: '12px',
        lineHeight: '1',
        opacity: disabled ? '0.4' : '1',
        cursor: disabled ? 'default' : 'pointer',
      });
      if (!disabled) {
        b.addEventListener('click', async (event) => {
          event.preventDefault();
          event.stopPropagation();
          event.stopImmediatePropagation();
          const next = Math.max(min, Math.min(max, current + delta));
          if (next !== current) {
            await saveAutoSwitch({ [fieldKey]: next });
          }
        }, true);
      }
      return b;
    }

    const valSpan = document.createElement('span');
    valSpan.textContent = `${current} ${suffix}`;
    Object.assign(valSpan.style, {
      minWidth: '54px',
      textAlign: 'center',
      fontSize: '11px',
      fontWeight: '700',
    });

    row.appendChild(label);
    row.appendChild(btn('−', -step, current <= min));
    row.appendChild(valSpan);
    row.appendChild(btn('+', step, current >= max));
    return row;
  }

  async function selectProvider(id, caller) {
    // caller: 'user-click' / 'auto' / etc. 仅用于 dart 端日志定位是哪段 JS 触发的
    console.log('[ShimDbg] selectProvider', { id, caller, stack: new Error().stack });
    const res = await window.shim('/provider/select', { id, __caller: caller || 'js:unknown' });
    if (!res || res.code !== 0) {
      showToast(`${S('switchProviderFailed', 'Switch provider failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      return;
    }
    shimProviderState = {
      selectedId: res.data.selectedId ?? null,
      reasoningEffort: res.data.reasoningEffort || 'high',
      providers: Array.isArray(res.data.providers) ? res.data.providers : [],
      labels: res.data.labels || shimProviderState.labels || {},
    };
    updateProviderPickerButton();
    updateProviderPickerPopover();
    updateCodexModelSelectorVisibility();
    refreshCurrentProvider();
  }

  async function selectProviderModel(id, model, caller) {
    console.log('[ShimDbg] selectProviderModel', { id, model, caller, stack: new Error().stack });
    const res = await window.shim('/provider/select-model', { id, model, __caller: caller || 'js:unknown' });
    if (!res || res.code !== 0) {
      showToast(`${S('switchModelFailed', 'Switch model failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      return;
    }
    shimProviderState = {
      selectedId: res.data.selectedId ?? null,
      reasoningEffort: res.data.reasoningEffort || 'high',
      providers: Array.isArray(res.data.providers) ? res.data.providers : [],
      labels: res.data.labels || shimProviderState.labels || {},
    };
    updateProviderPickerButton();
    updateProviderPickerPopover();
    updateCodexModelSelectorVisibility();
    refreshCurrentProvider();
  }

  async function selectReasoningEffort(id, effort) {
    const res = await window.shim('/provider/set-reasoning-effort', {
      id,
      effort,
    });
    if (!res || res.code !== 0) {
      showToast(`${S('switchEffortFailed', 'Switch reasoning failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      return;
    }
    shimProviderState = {
      selectedId: res.data.selectedId ?? null,
      reasoningEffort: res.data.reasoningEffort || 'high',
      providers: Array.isArray(res.data.providers) ? res.data.providers : [],
      labels: res.data.labels || shimProviderState.labels || {},
    };
    updateProviderPickerButton();
    updateProviderPickerPopover();
  }

  function buildProviderBadge(label) {
    const badge = document.createElement('div');
    badge.className = PROVIDER_BADGE_CLASS;
    Object.assign(badge.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '6px',
      alignSelf: 'flex-start',
      margin: '0 0 6px 2px',
      padding: '2px 10px',
      borderRadius: '999px',
      fontSize: '11px',
      fontWeight: '600',
      lineHeight: '1.6',
      userSelect: 'none',
      pointerEvents: 'none',
    });
    badge.classList.add(
      'bg-token-foreground/5',
      'text-token-text-tertiary',
    );

    const dot = document.createElement('span');
    Object.assign(dot.style, {
      width: '6px',
      height: '6px',
      borderRadius: '50%',
      background: '#22c55e',
    });

    const text = document.createElement('span');
    text.textContent = label;

    badge.appendChild(dot);
    badge.appendChild(text);
    return badge;
  }

  function ensureProviderBadge() {
    const label = shimCurrentProviderLabel;
    const turns = document.querySelectorAll('[data-turn-key]');
    const latest = turns.length ? turns[turns.length - 1] : null;
    const existing = document.querySelectorAll('.' + PROVIDER_BADGE_CLASS);

    if (!label || !latest) {
      if (existing.length) {
        if (typeof __t === 'function') __t('ensureProviderBadge: REMOVE all (no label/turn)', { existing: existing.length });
        existing.forEach((el) => el.remove());
      }
      return;
    }

    const desiredText = String(label);
    let already = null;
    for (const el of existing) {
      if (el.parentElement === latest && el.textContent?.endsWith(desiredText)) {
        already = el;
        break;
      }
    }
    if (already) {
      const stale = [...existing].filter((el) => el !== already);
      if (stale.length) {
        if (typeof __t === 'function') __t('ensureProviderBadge: REMOVE stale', { stale: stale.length });
        stale.forEach((el) => el.remove());
      }
      return;
    }

    if (typeof __t === 'function') __t('ensureProviderBadge: REPLACE -> insert latest', {
      existing: existing.length,
      label: desiredText,
    });
    existing.forEach((el) => el.remove());
    latest.insertBefore(buildProviderBadge(label), latest.firstChild);
  }


  // ========== Codex 插件运行时兼容 ==========

  const shimRuntimePlugins = (() => {
    const version = 'shim-runtime-plugin-layer-v1';
    const arrayGuardVersion = 'shim-runtime-array-visibility-v1';
    const clientBridgeVersion = 'shim-runtime-client-bridge-v1';
    const scanFlag = 'data-shim-plugin-ready';
    const installFlag = 'data-shim-install-ready';
    const logPrefix = '[ShimPlugin]';
    const navSelector = 'nav[role="navigation"] button.h-token-nav-row.w-full';
    const pluginIconPathPrefix = 'M7.94562 14.0277';
    const marketIds = new Set([
      'openai-bundled',
      'openai-curated',
      'openai-primary-runtime',
    ]);
    const moduleCache = new Map();
    const state = {
      navSignature: '',
      installSignature: '',
      promptSignature: '',
      arrayGuardInstalled: false,
      clients: [],
      pluginRecords: new Map(),
      lastPluginListParams: null,
      runtimeHostId: 'local',
    };

    function log(message, data) {
      if (data === undefined) {
        console.info(logPrefix + ' ' + message);
        return;
      }
      let detail;
      try {
        detail = JSON.stringify(data);
      } catch (_) {
        detail = String(data);
      }
      console.info(logPrefix + ' ' + message + ' ' + detail);
    }

    function visibleText(element) {
      return (element?.textContent || '').replace(/\s+/g, ' ').trim();
    }

    function isLoginSurface() {
      // 用具体的登录 DOM 节点判断,避免对整个 body 文本做正则——
      // 否则主界面只要瞬间出现"Codex"字样就会被误判,触发 array guard 反复装卸。
      if (document.querySelector('[data-testid="login-with-chatgpt"], [data-testid="login-with-api-key"]')) {
        return true;
      }
      // nav 都没渲染出来时,大概率还在登录页/启动屏
      if (!document.querySelector(navSelector)) return true;
      return false;
    }

    function isRuntimeSurfaceReady() {
      if (isLoginSurface()) return false;
      return pluginNavButtons().length > 0;
    }

    function canonicalMarketName(value) {
      const raw = String(value || '');
      return raw.startsWith('remote:') ? raw.slice('remote:'.length) : raw;
    }

    function isNativeMarket(value) {
      return marketIds.has(canonicalMarketName(value));
    }

    function marketLabel(value, fallback) {
      const name = canonicalMarketName(value);
      if (name === 'openai-bundled') return 'OpenAI Bundled';
      if (name === 'openai-curated') return 'OpenAI Curated';
      if (name === 'openai-primary-runtime') return 'OpenAI Runtime';
      return fallback || name || '';
    }

    function runtimeMethodName(method, params) {
      const raw = String(method || '');
      if (raw === 'send-cli-request-for-host' && params?.method) return String(params.method);
      return raw;
    }

    function normalizeMarketParams(params) {
      if (!params || typeof params !== 'object') return params;
      let next = params;
      if (Array.isArray(params.marketplaceKinds)) {
        const kinds = params.marketplaceKinds.map((kind) => {
          const value = String(kind || '');
          return value.startsWith('remote:')
            ? 'remote:' + canonicalMarketName(value)
            : canonicalMarketName(value);
        });
        next = { ...next, marketplaceKinds: Array.from(new Set(kinds)) };
      }
      if (typeof params.remoteMarketplaceName === 'string') {
        next = next === params ? { ...params } : { ...next };
        next.remoteMarketplaceName = canonicalMarketName(params.remoteMarketplaceName);
      }
      if (typeof params.marketplacePath === 'string' && params.marketplacePath.startsWith('remote:')) {
        next = next === params ? { ...params } : { ...next };
        next.remoteMarketplaceName = canonicalMarketName(params.marketplacePath);
        delete next.marketplacePath;
      }
      return next;
    }

    function prepareRuntimeParams(method, params) {
      if (!params || typeof params !== 'object') return params;
      const nested = params.method && params.params && typeof params.params === 'object';
      const target = nested ? params.params : params;
      let nextTarget = normalizeMarketParams(target);
      if (method === 'list-plugins' && nextTarget && typeof nextTarget === 'object' &&
          Object.prototype.hasOwnProperty.call(nextTarget, 'marketplaceKinds')) {
        nextTarget = { ...nextTarget };
        delete nextTarget.marketplaceKinds;
      }
      if (nested) {
        let nextParams = nextTarget !== target ? { ...params, params: nextTarget } : params;
        if (typeof nextParams.hostId === 'string' && nextParams.hostId.trim()) {
          state.runtimeHostId = nextParams.hostId.trim();
        } else if (String(params.method || '') === method) {
          nextParams = { ...nextParams, hostId: state.runtimeHostId || 'local' };
        }
        return nextParams;
      }
      return nextTarget;
    }

    function normalizeMarketObject(marketplace) {
      if (!marketplace || typeof marketplace !== 'object') return false;
      if (marketplace.__shimRuntimeMarket === version) return false;
      const name = canonicalMarketName(marketplace.name || marketplace.marketplaceName || marketplace.remoteMarketplaceName);
      if (!marketIds.has(name)) return false;
      const label = marketLabel(name, marketplace.displayName || marketplace.title || marketplace.label || marketplace.name);
      marketplace.name = name;
      marketplace.marketplaceName = name;
      marketplace.remoteMarketplaceName = name;
      marketplace.displayName = label;
      marketplace.title = label;
      marketplace.label = label;
      if (marketplace.interface && typeof marketplace.interface === 'object') {
        marketplace.interface = {
          ...marketplace.interface,
          displayName: label,
          title: label,
          label,
        };
      } else {
        marketplace.interface = { displayName: label, title: label, label };
      }
      if (Array.isArray(marketplace.plugins)) {
        marketplace.plugins.forEach((item) => {
          if (item && typeof item === 'object' && isNativeMarket(item.marketplaceName || name)) {
            item.marketplaceName = name;
          }
        });
      }
      marketplace.__shimRuntimeMarket = version;
      return true;
    }

    function pluginRecordKeys(plugin, marketplace) {
      return [
        plugin?.displayName,
        plugin?.title,
        plugin?.label,
        plugin?.name,
        plugin?.pluginName,
        plugin?.id,
        marketplace?.displayName,
      ].map((value) => String(value || '').replace(/\s+/g, ' ').trim().toLowerCase()).filter(Boolean);
    }

    function rememberPluginRecords(payload) {
      const roots = [payload, payload?.data, payload?.result].filter(Boolean);
      let count = 0;
      for (const root of roots) {
        const marketplaces = Array.isArray(root?.marketplaces) ? root.marketplaces : Array.isArray(root) ? root : [];
        for (const marketplace of marketplaces) {
          const marketName = canonicalMarketName(marketplace?.name || marketplace?.marketplaceName || marketplace?.remoteMarketplaceName);
          const plugins = Array.isArray(marketplace?.plugins) ? marketplace.plugins : [];
          for (const plugin of plugins) {
            if (!plugin || typeof plugin !== 'object') continue;
            const pluginName = plugin.pluginName || plugin.name || plugin.id || plugin.slug;
            if (!pluginName) continue;
            const remoteMarketplaceName = canonicalMarketName(plugin.marketplaceName || marketName);
            const record = {
              pluginName: String(pluginName),
              remoteMarketplaceName,
              marketplacePath: 'remote:' + remoteMarketplaceName,
              title: plugin.displayName || plugin.title || plugin.label || plugin.name || String(pluginName),
              raw: plugin,
            };
            for (const key of pluginRecordKeys(plugin, marketplace)) {
              state.pluginRecords.set(key, record);
            }
            count += 1;
          }
        }
      }
      if (count > 0) log('plugin records cached', { count });
    }

    function normalizeRuntimePayload(method, payload) {
      if (method !== 'list-plugins') return payload;
      let changed = 0;
      const roots = [payload, payload?.data, payload?.result].filter(Boolean);
      for (const root of roots) {
        if (Array.isArray(root?.marketplaces)) {
          root.marketplaces.forEach((marketplace) => {
            if (normalizeMarketObject(marketplace)) changed += 1;
          });
        }
        if (Array.isArray(root)) {
          root.forEach((marketplace) => {
            if (normalizeMarketObject(marketplace)) changed += 1;
          });
        }
      }
      rememberPluginRecords(payload);
      if (changed > 0) log('marketplace payload normalized', { changed });
      return payload;
    }

    function isSourceGate(callback, items) {
      if (!Array.isArray(items) || items.length === 0 || typeof callback !== 'function') return false;
      if (!items.some((item) => isNativeMarket(item?.marketplaceName))) return false;
      let source = '';
      try {
        source = Function.prototype.toString.call(callback);
      } catch (_) {
        return false;
      }
      if (!source.includes('marketplaceName')) return false;
      return items.some((item) => isNativeMarket(item?.marketplaceName) && !callback(item));
    }

    function isVisibilityGate(callback, items) {
      if (!Array.isArray(items) || items.length === 0 || typeof callback !== 'function') return false;
      if (!items.some((item) => isNativeMarket(item?.name))) return false;
      let source = '';
      try {
        source = Function.prototype.toString.call(callback);
      } catch (_) {
        return false;
      }
      if (!source.includes('includes') || !source.includes('name')) return false;
      return items.some((item) => isNativeMarket(item?.name) && !callback(item));
    }

    function installScopedArrayGuard() {
      const baseFilter = Array.prototype.__shimRuntimeArrayFilterSource ||
        Array.prototype.__shimPluginOriginalFilter ||
        Array.prototype.filter;
      if (!Array.prototype.__shimRuntimeArrayFilterSource) {
        Object.defineProperty(Array.prototype, '__shimRuntimeArrayFilterSource', {
          value: baseFilter,
          configurable: true,
          writable: true,
        });
      }
      if (Array.prototype.filter.__shimRuntimeArrayGuard === arrayGuardVersion) {
        state.arrayGuardInstalled = true;
        return;
      }
      const guardedFilter = function shimRuntimeScopedFilter(callback, thisArg) {
        if (isSourceGate(callback, this) || isVisibilityGate(callback, this)) {
          log('runtime marketplace visibility retained', { count: this.length });
          return Array.from(this);
        }
        return baseFilter.call(this, callback, thisArg);
      };
      Object.defineProperty(guardedFilter, '__shimRuntimeArrayGuard', {
        value: arrayGuardVersion,
        configurable: true,
      });
      Array.prototype.filter = guardedFilter;
      state.arrayGuardInstalled = true;
      log('runtime array guard attached');
    }

    function codexAssetUrl(part) {
      const urls = [
        ...Array.from(document.scripts || []).map((script) => script.src),
        ...Array.from(document.querySelectorAll('link[href]') || []).map((link) => link.href),
        ...performance.getEntriesByType('resource').map((entry) => entry.name),
      ].filter(Boolean);
      return urls.find((url) => url.includes('/assets/') && url.includes(part) && url.split('?')[0].endsWith('.js')) || '';
    }

    function importCodexRuntime(part) {
      if (!moduleCache.has(part)) {
        moduleCache.set(part, Promise.resolve().then(async () => {
          const url = codexAssetUrl(part);
          if (!url) throw new Error('Codex asset not found: ' + part);
          return import(url);
        }));
      }
      return moduleCache.get(part);
    }

    function attachRequestMiddleware(client) {
      if (!client || typeof client.sendRequest !== 'function') return false;
      if (client.__shimRuntimeClientBridge === clientBridgeVersion) return true;
      const baseSend = client.__shimRuntimeOriginalSendRequest ||
        client.__shimPluginOriginalSendRequest ||
        client.sendRequest.bind(client);
      client.__shimRuntimeOriginalSendRequest = baseSend;
      client.sendRequest = async function shimRuntimeSendRequest(method, params, options) {
        const resolvedMethod = runtimeMethodName(method, params);
        const nextParams = prepareRuntimeParams(resolvedMethod, params);
        if (resolvedMethod === 'list-plugins') state.lastPluginListParams = nextParams;
        if (resolvedMethod === 'list-plugins' || resolvedMethod === 'install-plugin' || resolvedMethod === 'plugin/install') {
          log('runtime request normalized', {
            method: String(method || ''),
            resolvedMethod,
            changed: nextParams !== params,
          });
        }
        const result = await baseSend(method, nextParams, options);
        return normalizeRuntimePayload(resolvedMethod, result);
      };
      client.__shimRuntimeClientBridge = clientBridgeVersion;
      if (!state.clients.includes(client)) state.clients.push(client);
      return true;
    }

    function attachRuntimeClientBridge() {
      if (window.__shimRuntimeClientBridgeReady === clientBridgeVersion) return;
      importCodexRuntime('app-server-manager-signals-').then((module) => {
        const exports = Object.values(module || {}).filter((value) => value && typeof value === 'object');
        let attached = 0;
        for (const candidate of exports) {
          if (attachRequestMiddleware(candidate)) attached += 1;
          if (typeof candidate.sendRequest !== 'function' && typeof candidate.get === 'function') {
            try {
              if (attachRequestMiddleware(candidate.get())) attached += 1;
            } catch (_) {}
          }
        }
        if (attached > 0) {
          window.__shimRuntimeClientBridgeReady = clientBridgeVersion;
          log('runtime client bridge attached', { exports: Object.keys(module || {}).length, candidates: exports.length, attached });
        } else {
          log('runtime client bridge not found', { exports: Object.keys(module || {}).length, candidates: exports.length });
        }
      }).catch((error) => {
        log('runtime client bridge failed', { error: error?.message || String(error) });
      });
    }

    function pluginNavButtons() {
      const byIcon = document
        .querySelector(navSelector + ' svg path[d^="' + pluginIconPathPrefix + '"]')
        ?.closest('button');
      const candidates = Array.from(
        document.querySelectorAll(navSelector + ', nav button, aside button, [role="navigation"] button'),
      );
      const matched = candidates.filter((button) => /^(插件|Plugins)(\s|$|[-:：])/.test(visibleText(button)));
      if (byIcon && !matched.includes(byIcon)) matched.unshift(byIcon);
      return matched;
    }

    function patchReactDisabledProps(element) {
      Object.keys(element || {})
        .filter((key) => key.startsWith('__reactProps') || key.startsWith('__reactFiber'))
        .forEach((key) => {
          const ref = element[key];
          const props = ref?.memoizedProps || ref?.pendingProps || ref;
          if (!props || typeof props !== 'object') return;
          if ('disabled' in props) props.disabled = false;
          if ('aria-disabled' in props) props['aria-disabled'] = false;
          if ('data-disabled' in props) props['data-disabled'] = undefined;
          if ('inert' in props) props.inert = false;
        });
    }

    function makeControlInteractive(element) {
      if (!(element instanceof HTMLElement)) return;
      if ('disabled' in element) element.disabled = false;
      element.removeAttribute('disabled');
      element.removeAttribute('aria-disabled');
      element.removeAttribute('data-disabled');
      element.removeAttribute('inert');
      element.removeAttribute('aria-describedby');
      const title = element.getAttribute('title') || '';
      if (/不可用|unavailable/i.test(title)) element.removeAttribute('title');
      element.style.pointerEvents = 'auto';
      element.style.opacity = '';
      element.style.cursor = 'pointer';
      element.tabIndex = 0;
      element.classList.remove('disabled', 'pointer-events-none', 'cursor-not-allowed', 'opacity-40', 'opacity-50');
      patchReactDisabledProps(element);
    }

    function relatedInteractiveNodes(control) {
      const nodes = [control];
      control.querySelectorAll?.('button, [role="button"], [disabled], [aria-disabled], [data-disabled], .cursor-not-allowed, .pointer-events-none')
        .forEach((node) => nodes.push(node));
      let parent = control.parentElement;
      for (let depth = 0; parent && depth < 4; depth += 1, parent = parent.parentElement) {
        if (parent.matches?.('button, [role="button"], [disabled], [aria-disabled], [data-disabled], .cursor-not-allowed, .pointer-events-none, [data-state]')) {
          nodes.push(parent);
        }
      }
      return Array.from(new Set(nodes));
    }

    function forceInteractiveCluster(control) {
      relatedInteractiveNodes(control).forEach(makeControlInteractive);
    }

    function keepControlInteractive(control) {
      if (!(control instanceof HTMLElement)) return;
      if (control.dataset.shimKeepInteractive === '1') return;
      control.dataset.shimKeepInteractive = '1';
      const keep = () => forceInteractiveCluster(control);
      ['pointerover', 'pointerenter', 'pointerdown', 'mousedown', 'mouseup', 'click', 'focus'].forEach((eventName) => {
        control.addEventListener(eventName, keep, true);
      });
    }

    function syncNavigationControls() {
      const buttons = pluginNavButtons();
      const signature = buttons.length + ':' + buttons.map(visibleText).join(' | ');
      if (signature !== state.navSignature) {
        state.navSignature = signature;
        log('navigation controls synced', { count: buttons.length, labels: buttons.map(visibleText).join(' | ') || null });
      }
      for (const button of buttons) {
        // 每个 button 只处理一次——重复 makeControlInteractive 会触发 React reconcile 循环
        if (button.getAttribute('data-shim-nav-handled') === '1') continue;
        makeControlInteractive(button);
        button.style.display = '';
        button.setAttribute(scanFlag, '1');
        button.setAttribute('data-shim-nav-handled', '1');
        button.title = button.title || 'Shim plugin runtime ready';
      }
    }

    function isInstallControlText(text) {
      const label = String(text || '').replace(/\s+/g, ' ').trim();
      return label === '添加' || label === 'Add' || label === '安装' || label === 'Install' || label === '强制安装';
    }

    function normalizeInstallControls() {
      const controls = Array.from(document.querySelectorAll(
        'button:disabled, button[aria-disabled="true"], [role="button"][aria-disabled="true"], button[data-disabled], [role="button"][data-disabled], button.cursor-not-allowed, [role="button"].cursor-not-allowed, button.pointer-events-none, [role="button"].pointer-events-none',
      ));
      const unique = Array.from(new Set(controls.map((node) => node.closest?.('button, [role="button"]') || node)));
      let matched = 0;
      let changed = 0;
      for (const control of unique) {
        if (!(control instanceof HTMLElement)) continue;
        if (!isInstallControlText(control.textContent)) continue;
        matched += 1;
        const blocked = control.hasAttribute('disabled') ||
          control.getAttribute('aria-disabled') === 'true' ||
          control.getAttribute('data-disabled') === 'true' ||
          control.classList.contains('cursor-not-allowed') ||
          control.classList.contains('pointer-events-none');
        forceInteractiveCluster(control);
        keepControlInteractive(control);
        control.setAttribute(installFlag, '1');
        control.title = control.title || 'Shim install control ready';
        if (blocked) changed += 1;
      }
      const signature = matched + ':' + changed;
      if (signature !== state.installSignature) {
        state.installSignature = signature;
        log('install controls normalized', { matched, changed });
      }
    }

    function normalizePromptExampleControls() {
      const controls = Array.from(document.querySelectorAll('button[aria-disabled="true"], [role="button"][aria-disabled="true"]'))
        .filter((control) => control instanceof HTMLElement && String(control.className || '').includes('group/prompt'));
      let changed = 0;
      for (const control of controls) {
        forceInteractiveCluster(control);
        keepControlInteractive(control);
        control.setAttribute('data-shim-prompt-ready', '1');
        control.title = control.title || 'Shim prompt ready';
        changed += 1;
      }
      const signature = controls.length + ':' + changed;
      if (signature !== state.promptSignature) {
        state.promptSignature = signature;
        log('prompt example controls normalized', { matched: controls.length, changed });
      }
    }

    function tick(flags) {
      const f = flags || {};
      const ready = isRuntimeSurfaceReady();
      if (typeof __t === 'function') __t('plugin tick', { ready, isLogin: isLoginSurface() });
      if (!ready) return;
      if (f.arrayGuard !== false) installScopedArrayGuard();
      if (f.clientBridge !== false) attachRuntimeClientBridge();
      if (f.syncNav !== false) syncNavigationControls();
      if (f.normalizeInstall !== false) normalizeInstallControls();
      if (f.normalizePrompt !== false) normalizePromptExampleControls();
    }

    return { tick };
  })();

  const __SHIM_PLUGIN_FLAGS = {
    arrayGuard: true,
    clientBridge: true,
    syncNav: true,
    normalizeInstall: true,
    normalizePrompt: true,
  };
  window.__SHIM_PLUGIN_FLAGS = __SHIM_PLUGIN_FLAGS;

  function ensureCodexPluginFeatures() {
    shimRuntimePlugins.tick(__SHIM_PLUGIN_FLAGS);
  }
  // ========== 总调度 ==========

  // ========== Debug trace ==========
  const __SHIM_TRACE = true;
  let __shimEnsureCount = 0;
  let __shimObserverCount = 0;
  function __t(tag, data) {
    if (!__SHIM_TRACE) return;
    if (data === undefined) console.log('[ShimTrace]', tag);
    else console.log('[ShimTrace]', tag, data);
  }

  function __countDomBefore() {
    return {
      badge: document.querySelectorAll('#' + BADGE_ID).length,
      menu: document.querySelectorAll('#' + MENU_ITEM_ID).length,
      picker: document.querySelectorAll('#' + PROVIDER_PICKER_ID).length,
      providerBadge: document.querySelectorAll('.' + PROVIDER_BADGE_CLASS).length,
      delBtns: document.querySelectorAll('[data-shim-delete-added="1"]').length,
    };
  }

  // ========== Claude 桥:在 codex 侧栏 nav 列表里加一个折叠按钮 ==========
  // 点击展开 → 列出 ~/.claude/projects/ 下所有项目分组,每个项目下又能再折叠列出会话。
  // 点会话目前先 toast(接续逻辑等 codex 写入面调查报告出来再做)。
  const NAV_BTN_ID = '__shim_claude_bridge_nav__';
  const NAV_PANEL_ID = '__shim_claude_bridge_panel__';

  // 找到 codex 自带 nav 按钮所在的列表容器(包含"插件"按钮的 .flex.flex-col.gap-px)。
  // 我们把"Claude 桥"按钮追加到该容器末尾,折叠面板紧跟其后。
  function findCodexNavList() {
    const sample = document.querySelector(
      'nav[role="navigation"] button.h-token-nav-row.w-full',
    );
    if (!sample) return null;
    return sample.closest('div.flex.flex-col.gap-px') || sample.parentElement;
  }

  function ensureClaudeBridge() {
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
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" class="icon-xs">
          <path d="M2.667 3.333A1.333 1.333 0 0 1 4 2h8a1.333 1.333 0 0 1 1.333 1.333v6.667A1.333 1.333 0 0 1 12 11.333H5.886l-2.553 2.553V3.333Z" stroke="currentColor" stroke-width="1.2" fill="none" stroke-linejoin="round"/>
          <circle cx="6" cy="7" r="0.8" fill="currentColor"/>
          <circle cx="8" cy="7" r="0.8" fill="currentColor"/>
          <circle cx="10" cy="7" r="0.8" fill="currentColor"/>
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
      'margin: 4px 0 6px 12px; padding: 6px 0; border-left: 1px solid var(--token-border, rgba(255,255,255,0.12)); max-height: 50vh; overflow-y: auto; overscroll-behavior: contain;';
    // codex 的 sidebar 容器可能拦截 wheel 事件,这里阻止冒泡,保证内部能滚
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
      try {
        const res = await window.shim('/claude-bridge/bind', {
          sessionId: thread.sessionId,
          jsonlPath: thread.jsonlPath,
          title: title,
        });
        if (!res || res.code !== 0) {
          showToast(`${S('claudeBridgeBindFailed', 'Bind failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
          return;
        }
        shimClaudeBridgeState = res.data || { bound: false };
        ensureClaudeBridgeChip();
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

  // ========== Claude 桥:composer 旁的绑定状态 chip ==========
  // 单一全局绑定:dart 侧 LocalProxyService 持有 ClaudeBridgeBinding。
  // - 进页面/刷新时通过 /claude-bridge/state 拉一次,后续 ensure 时只复用缓存
  // - 用户点会话 row → /claude-bridge/bind → 刷新 chip
  // - 用户点 chip 的 × → /claude-bridge/unbind → 静默移除 chip
  const CLAUDE_BRIDGE_CHIP_ID = '__shim_claude_bridge_chip__';
  let shimClaudeBridgeState = { bound: false };
  let shimClaudeBridgeStateLoaded = false;

  function refreshClaudeBridgeState() {
    if (typeof window.shim !== 'function') return Promise.resolve();
    return window.shim('/claude-bridge/state', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimClaudeBridgeState = res.data;
        ensureClaudeBridgeChip();
      }
    }).catch(() => {});
  }

  function ensureClaudeBridgeChip() {
    if (!shimClaudeBridgeStateLoaded) {
      shimClaudeBridgeStateLoaded = true;
      refreshClaudeBridgeState();
      return;
    }
    const existing = document.getElementById(CLAUDE_BRIDGE_CHIP_ID);
    if (!shimClaudeBridgeState.bound) {
      existing?.remove();
      return;
    }
    const anchor = findProviderPickerAnchor();
    if (!anchor) return;
    if (existing && existing.parentElement === anchor.group) {
      const labelEl = existing.querySelector('[data-shim-bridge-label]');
      if (labelEl) {
        const title = shimClaudeBridgeState.title || shimClaudeBridgeState.sessionId || '';
        const expected = `${S('claudeBridgeChipPrefix', 'Claude:')} ${title}`;
        if (labelEl.textContent !== expected) labelEl.textContent = expected;
      }
      return;
    }
    existing?.remove();
    const chip = buildClaudeBridgeChip();
    // 挂在 provider picker 同一行的最左边,picker 按钮之前
    const pickerBtn = document.getElementById(PROVIDER_PICKER_ID);
    if (pickerBtn && pickerBtn.parentElement === anchor.group) {
      anchor.group.insertBefore(chip, pickerBtn);
    } else {
      anchor.group.insertBefore(chip, anchor.button);
    }
  }

  function buildClaudeBridgeChip() {
    const chip = document.createElement('span');
    chip.id = CLAUDE_BRIDGE_CHIP_ID;
    Object.assign(chip.style, {
      display: 'inline-flex',
      alignItems: 'center',
      gap: '6px',
      height: '24px',
      padding: '0 8px',
      borderRadius: '999px',
      background: 'rgba(34, 197, 94, 0.14)',
      color: '#22c55e',
      border: '1px solid rgba(34, 197, 94, 0.32)',
      fontSize: '12px',
      fontWeight: '600',
      lineHeight: '1',
      maxWidth: '220px',
      whiteSpace: 'nowrap',
    });
    const title = shimClaudeBridgeState.title || shimClaudeBridgeState.sessionId || '';
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
        const res = await window.shim('/claude-bridge/unbind', {});
        if (res && res.code === 0) {
          shimClaudeBridgeState = res.data || { bound: false };
          ensureClaudeBridgeChip();
        }
      } catch (_) {
        // 静默,即使后端没回,chip 也直接消失
        shimClaudeBridgeState = { bound: false };
        ensureClaudeBridgeChip();
      }
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

  function ensureAll() {
    __shimEnsureCount += 1;
    const seq = __shimEnsureCount;
    const before = __countDomBefore();
    __t('ensureAll #' + seq + ' before', before);

    const t0 = performance.now();
    ensureBadge();
    const t1 = performance.now();
    ensureShimMenuItem();
    const t2 = performance.now();
    ensureDeleteButtons();
    const t3 = performance.now();
    ensureProviderPicker();
    const t4 = performance.now();
    updateCodexModelSelectorVisibility();
    const t5 = performance.now();
    ensureProviderBadge();
    const t6 = performance.now();
    ensureCodexPluginFeatures();
    const t7 = performance.now();
    ensureClaudeBridge();
    ensureClaudeBridgeChip();
    const t8 = performance.now();

    const after = __countDomBefore();
    const changed = JSON.stringify(before) !== JSON.stringify(after);
    __t('ensureAll #' + seq + ' done', {
      changed,
      after,
      ms: {
        badge: +(t1 - t0).toFixed(1),
        menu: +(t2 - t1).toFixed(1),
        del: +(t3 - t2).toFixed(1),
        picker: +(t4 - t3).toFixed(1),
        codexModel: +(t5 - t4).toFixed(1),
        providerBadge: +(t6 - t5).toFixed(1),
        plugin: +(t7 - t6).toFixed(1),
        claudeBridge: +(t8 - t7).toFixed(1),
        total: +(t8 - t0).toFixed(1),
      },
    });
  }

  let __shimEnsureRunning = false;
  function runEnsureAll(source) {
    if (__shimEnsureRunning) {
      __t('runEnsureAll skip (reentrant)', { source });
      return;
    }
    __shimEnsureRunning = true;
    __t('runEnsureAll start', { source });
    try {
      ensureAll();
    } finally {
      requestAnimationFrame(() => {
        __shimEnsureRunning = false;
      });
    }
  }

  const SHIM_SELF_NODE_SELECTOR = [
    '#' + BADGE_ID,
    '#' + MENU_ITEM_ID,
    '#' + POPOVER_ID,
    '#' + PROVIDER_PICKER_ID,
    '#' + PROVIDER_PICKER_POPOVER_ID,
    '#' + TOAST_CONTAINER_ID,
    '#' + CONFIRM_DIALOG_ID,
    '.' + PROVIDER_BADGE_CLASS,
    '[data-shim-delete-added]',
    '[data-shim-nav-handled]',
    '[data-shim-install-ready]',
    '[data-shim-prompt-ready]',
    '[data-shim-clear-model]',
  ].join(', ');

  const SHIM_WATCH_TARGET_SELECTOR = [
    '[data-app-action-sidebar-thread-row]',
    '[data-app-action-sidebar-thread-id]',
    'button[aria-label="归档对话"]',
    'nav[role="navigation"]',
    '[data-codex-intelligence-trigger]',
    '[data-turn-key]',
    '[role="menu"]',
    '[role="menuitem"]',
    '.composer-footer',
    'button[aria-disabled="true"]',
    'button.cursor-not-allowed',
    'button[disabled]',
  ].join(', ');

  function isSelfManagedNode(node) {
    if (!(node instanceof Element)) return false;
    return !!node.matches?.(SHIM_SELF_NODE_SELECTOR) || !!node.closest?.(SHIM_SELF_NODE_SELECTOR);
  }

  function nodeTouchesWatchTarget(node) {
    if (node.nodeType !== 1) return false;
    if (isSelfManagedNode(node)) return false;
    return !!node.matches?.(SHIM_WATCH_TARGET_SELECTOR) ||
      !!node.closest?.(SHIM_WATCH_TARGET_SELECTOR) ||
      !!node.querySelector?.(SHIM_WATCH_TARGET_SELECTOR);
  }

  function mutationTouchesWatchTarget(record) {
    const target = record.target;
    if (target instanceof Element && isSelfManagedNode(target)) return false;
    if (target instanceof Element && (
      target.matches?.(SHIM_WATCH_TARGET_SELECTOR) ||
      target.closest?.(SHIM_WATCH_TARGET_SELECTOR)
    )) return true;
    for (const n of record.addedNodes) {
      if (nodeTouchesWatchTarget(n)) return true;
    }
    for (const n of record.removedNodes) {
      if (nodeTouchesWatchTarget(n)) return true;
    }
    return false;
  }

  function recordsRequireEnsureAll(records) {
    if (!records || records.length === 0) return true;
    return records.some(mutationTouchesWatchTarget);
  }

  function summarizeMutations(records) {
    const summary = {
      total: records.length,
      addedNodes: 0,
      removedNodes: 0,
      attrChanges: 0,
      sampleTargets: [],
      sampleAdded: [],
      sampleRemoved: [],
    };
    for (const r of records) {
      summary.addedNodes += r.addedNodes.length;
      summary.removedNodes += r.removedNodes.length;
      if (r.type === 'attributes') summary.attrChanges += 1;
      if (summary.sampleTargets.length < 5 && r.target instanceof Element) {
        summary.sampleTargets.push(
          r.target.tagName + (r.target.id ? '#' + r.target.id : '') +
          (r.target.className && typeof r.target.className === 'string'
            ? '.' + r.target.className.split(/\s+/).slice(0, 2).join('.')
            : ''),
        );
      }
      for (const n of r.addedNodes) {
        if (summary.sampleAdded.length >= 5) break;
        if (n instanceof Element) {
          summary.sampleAdded.push(
            n.tagName + (n.id ? '#' + n.id : '') +
            (n.className && typeof n.className === 'string'
              ? '.' + n.className.split(/\s+/).slice(0, 2).join('.')
              : ''),
          );
        } else if (n.nodeType === 3) {
          summary.sampleAdded.push('#text:' + String(n.textContent || '').slice(0, 20));
        }
      }
      for (const n of r.removedNodes) {
        if (summary.sampleRemoved.length >= 5) break;
        if (n instanceof Element) {
          summary.sampleRemoved.push(
            n.tagName + (n.id ? '#' + n.id : '') +
            (n.className && typeof n.className === 'string'
              ? '.' + n.className.split(/\s+/).slice(0, 2).join('.')
              : ''),
          );
        }
      }
    }
    return summary;
  }

  function installUiScheduler() {
    if (!document.documentElement) {
      setTimeout(installUiScheduler, 50);
      return;
    }
    if (window.__shimUiSchedulerInstalled) {
      runEnsureAll('reinit');
      return;
    }
    window.__shimUiSchedulerInstalled = true;

    runEnsureAll('initial');

    let scheduled = false;
    let pendingRecords = [];
    const observer = new MutationObserver((records) => {
      __shimObserverCount += 1;
      const obsSeq = __shimObserverCount;
      if (__shimEnsureRunning) {
        __t('observer #' + obsSeq + ' suppressed (self)', { records: records.length });
        return;
      }
      if (!recordsRequireEnsureAll(records)) {
        __t('observer #' + obsSeq + ' filtered (irrelevant)', { records: records.length });
        return;
      }
      pendingRecords.push(...records);
      if (scheduled) return;
      scheduled = true;
      setTimeout(() => {
        scheduled = false;
        const summary = summarizeMutations(pendingRecords);
        pendingRecords = [];
        __t('observer batch fired', summary);
        runEnsureAll('observer');
      }, 400);
    });
    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
    __t('UI scheduler installed');
  }

  installUiScheduler();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', ensureAll, { once: true });
  }

  // bridge 就绪后拉一次当前供应商，并定时刷新（供应商切换后标签随之更新）
  (function initProviderBadge() {
    if (typeof window.shim !== 'function') {
      setTimeout(initProviderBadge, 500);
      return;
    }
    refreshCurrentProvider();
    refreshProviderPickerState();
    if (!window.__shimProviderPollInstalled) {
      window.__shimProviderPollInstalled = true;
      setInterval(() => {
        refreshCurrentProvider();
        // 总是刷新数据(按钮跟着变),popover 只有关着才重建
        const popoverOpen = !!document.getElementById(PROVIDER_PICKER_POPOVER_ID);
        refreshProviderPickerState({ rebuildPopover: !popoverOpen });
      }, 15000);
    }

    // 订阅 dart 推送的自动切换事件。注意:picker 打开时不要触发 list 重建,
    // 否则用户正点的按钮会被销毁重建,表现为"菜单卡死无法点击"。
    let __shimLastPushAt = 0;
    if (typeof window.__shimOn === 'function' && !window.__shimAutoSwitchSub) {
      window.__shimAutoSwitchSub = window.__shimOn('/provider/auto-switched', (payload) => {
        if (!payload) return;
        const now = Date.now();
        // 节流:同一秒内多次 push 只处理一次
        if (now - __shimLastPushAt < 1000) return;
        __shimLastPushAt = now;
        if (payload.event === 'switched') {
          const fromName = providerNameFromId(payload.from) || payload.from || '';
          const toName = providerNameFromId(payload.to) || payload.to || '';
          showToast(`${S('autoSwitchedToast', 'Provider auto-switched')}: ${fromName} → ${toName}`, 'success');
          // 总是刷新数据(按钮跟着变),popover 只有关着才重建
          const popoverOpen = !!document.getElementById(PROVIDER_PICKER_POPOVER_ID);
          refreshProviderPickerState({ rebuildPopover: !popoverOpen });
          refreshCurrentProvider();
        } else if (payload.event === 'maintenance') {
          showToast(`${S('autoSwitchMaintenanceToast', 'Auto-switch paused')}: ${payload.reason || ''}`, 'error');
        } else if (payload.event === 'no-eligible') {
          showToast(S('autoSwitchNoEligibleToast', 'Current provider unhealthy, but no eligible candidate to switch — please check manually'), 'error');
        }
      });
    }
  })();

  function providerNameFromId(id) {
    if (!id) return null;
    const list = (shimProviderState && shimProviderState.providers) || [];
    const p = list.find((x) => x.id === id);
    return p?.name || null;
  }

})();

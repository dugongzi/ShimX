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
  const THREAD_PREVIEW_ID = '__shim_thread_preview__';
  const THREAD_PREVIEW_LENS_ID = '__shim_thread_preview_lens__';

  const BADGE_ANCHOR_SVG_D_PREFIX = 'M16.835 8.66301C16.835 7.71885';
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
      background: '#60a5fa',
      boxShadow: '0 0 6px rgba(96, 165, 250, 0.62)',
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

  function removeInjectedBadge() {
    document.getElementById(BADGE_ID)?.remove();
  }

  // ========== Shim 控制入口（侧栏 Claude bridge 下方） ==========

  function findShimMenuInsertAnchor() {
    const panel = document.getElementById(NAV_PANEL_ID);
    if (panel) return panel;
    return document.getElementById(NAV_BTN_ID);
  }

  function buildShimMenuItem() {
    const item = document.createElement('button');
    item.id = MENU_ITEM_ID;
    item.type = 'button';
    item.className =
      'focus-visible:outline-token-border relative h-token-nav-row px-row-x py-row-y cursor-interaction shrink-0 items-center overflow-hidden rounded-lg text-left text-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50 gap-2 flex w-full hover:bg-token-list-hover-background';

    const row = document.createElement('div');
    row.className = 'flex min-w-0 items-center text-base gap-2 flex-1 text-token-foreground';

    const iconWrap = document.createElement('span');
    iconWrap.style.display = 'inline-flex';
    iconWrap.style.color = '#1296db';
    iconWrap.innerHTML = SHIM_ICON_SVG;

    const label = document.createElement('span');
    label.className = 'flex-1 min-w-0 truncate';
    label.textContent = 'Shim';

    const statusDot = document.createElement('span');
    statusDot.setAttribute('aria-hidden', 'true');
    Object.assign(statusDot.style, {
      width: '8px',
      height: '8px',
      borderRadius: '999px',
      background: '#60a5fa',
      boxShadow: '0 0 8px rgba(96, 165, 250, 0.48)',
      flex: '0 0 auto',
    });

    row.appendChild(iconWrap);
    row.appendChild(label);
    row.appendChild(statusDot);
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
    const navList = findCodexNavList();
    if (!navList) return;
    const anchor = findShimMenuInsertAnchor();
    if (!anchor || anchor.parentElement !== navList) return;

    const existing = document.getElementById(MENU_ITEM_ID);
    if (existing && existing.parentElement === navList && existing.previousElementSibling === anchor) {
      return;
    }
    if (typeof __t === 'function') __t('ensureShimMenuItem: INSERT into nav');
    existing?.remove();
    const item = buildShimMenuItem();
    anchor.insertAdjacentElement('afterend', item);
  }

  // ========== Shim 控制面板 ==========

  let shimControlPanelSnapshot = null;
  // 控制面板当前选中的 tab key。模块级状态, 点击切换 + 重渲染 chrome 即可。
  let shimControlActiveTab = 'overview';
  // 日志页面级状态 (只在 logs tab 用)
  let shimControlLogsState = {
    loading: false,
    error: null,
    entries: [],
    filter: 'all',
  };

  function buildPopover() {
    const panel = document.createElement('div');
    panel.id = POPOVER_ID;
    panel.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(panel.style, {
      position: 'fixed',
      zIndex: '2147483647',
      width: 'min(880px, calc(100vw - 96px))',
      maxWidth: 'calc(100vw - 32px)',
      height: 'min(620px, calc(100vh - 96px))',
      maxHeight: 'calc(100vh - 48px)',
      minHeight: '0',
      padding: '0',
      borderRadius: '14px',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      background: 'var(--token-main-surface-primary, var(--token-sidebar-surface-primary, rgba(20,20,22,0.985)))',
      boxShadow: '0 20px 60px rgba(0, 0, 0, 0.44)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '13px',
      lineHeight: '1.5',
      userSelect: 'none',
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column',
    });

    renderControlPanelChrome(panel);
    refreshControlPanel(panel);
    return panel;
  }

  const ICON_OVERVIEW = '<svg width="15" height="15" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.3"/><rect x="9" y="2" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.3"/><rect x="2" y="9" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.3"/><rect x="9" y="9" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.3"/></svg>';
  const ICON_LOGS = '<svg width="15" height="15" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 3h10M3 6h10M3 9h7M3 12h5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';

  function controlPanelTabs() {
    return [
      { key: 'overview', label: S('shimControlOverviewTab', 'Data overview'), icon: ICON_OVERVIEW },
      { key: 'logs', label: S('shimControlLogsTab', 'Logs'), icon: ICON_LOGS },
    ];
  }

  // 把整个 popover 内部(header + sidebar + content)的"外壳"重建一次。
  // labels 是异步拉的, 第一次渲染时可能还是英文 fallback, 拿到中文后重建以更新所有静态文案。
  // 同时也是 tab 切换的统一入口 —— 不依赖各 tab 自己增量更新 sidebar。
  function renderControlPanelChrome(panel) {
    panel.innerHTML = '';

    panel.appendChild(buildControlPanelHeader());

    const narrow = window.innerWidth < 760;
    const shell = document.createElement('div');
    Object.assign(shell.style, {
      display: 'grid',
      gridTemplateColumns: narrow ? '160px minmax(0, 1fr)' : '200px minmax(0, 1fr)',
      flex: '1 1 auto',
      minHeight: '0',
      overflow: 'hidden',
    });
    shell.appendChild(buildControlPanelSidebar(panel));

    const content = document.createElement('div');
    content.setAttribute('data-shim-control-body', '1');
    Object.assign(content.style, {
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden',
      minHeight: '0',
    });
    shell.appendChild(content);
    panel.appendChild(shell);

    renderActiveTab(panel);
  }

  // 根据当前 active tab 把 content 区填上对应页面。
  // overview 用已经拉好的 snapshot (没拉到就 loading); logs 触发自己的 loader。
  function renderActiveTab(panel) {
    const body = panel.querySelector('[data-shim-control-body]');
    if (!body) return;
    body.innerHTML = '';
    if (shimControlActiveTab === 'logs') {
      body.appendChild(buildLogsPage(panel));
      // 第一次进 logs tab, 或上次出错时, 自动拉一次
      if (!shimControlLogsState.entries.length && !shimControlLogsState.loading) {
        reloadLogs(panel);
      }
      return;
    }
    // overview
    if (shimControlPanelSnapshot) {
      renderControlPanelSnapshot(body, shimControlPanelSnapshot);
    } else {
      renderControlPanelLoading(body);
    }
  }

  function switchControlTab(panel, key) {
    if (shimControlActiveTab === key) return;
    shimControlActiveTab = key;
    renderControlPanelChrome(panel);
  }

  function buildControlPanelSidebar(panel) {
    const sidebar = document.createElement('aside');
    Object.assign(sidebar.style, {
      display: 'flex',
      flexDirection: 'column',
      padding: '20px 12px',
      gap: '2px',
      borderRight: '1px solid var(--token-border, rgba(255,255,255,0.06))',
      background: 'rgba(255,255,255,0.018)',
      overflowY: 'auto',
    });

    const navLabel = document.createElement('div');
    navLabel.textContent = S('shimControlNavTitle', 'Sections');
    Object.assign(navLabel.style, {
      padding: '4px 10px 10px',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.42))',
      fontSize: '10px',
      fontWeight: '600',
      letterSpacing: '0.8px',
      textTransform: 'uppercase',
    });
    sidebar.appendChild(navLabel);

    for (const tab of controlPanelTabs()) {
      const active = tab.key === shimControlActiveTab;
      sidebar.appendChild(buildSidebarNavItem(tab.icon, tab.label, active, () => {
        switchControlTab(panel, tab.key);
      }));
    }

    return sidebar;
  }

  function buildSidebarNavItem(iconHtml, label, active, onClick) {
    const item = document.createElement('button');
    item.type = 'button';
    Object.assign(item.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      width: '100%',
      padding: '8px 10px',
      border: '0',
      borderRadius: '8px',
      background: active ? 'rgba(96,165,250,0.10)' : 'transparent',
      color: active
        ? 'var(--token-text-primary, currentColor)'
        : 'var(--token-text-secondary, rgba(255,255,255,0.62))',
      cursor: active ? 'default' : 'pointer',
      fontSize: '13px',
      fontWeight: active ? '600' : '500',
      textAlign: 'left',
      transition: 'background 140ms ease, color 140ms ease',
    });
    const icon = document.createElement('span');
    icon.innerHTML = iconHtml;
    Object.assign(icon.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '16px',
      height: '16px',
      flex: '0 0 auto',
      color: active ? '#93c5fd' : 'currentColor',
    });
    const text = document.createElement('span');
    text.textContent = label;
    Object.assign(text.style, {
      flex: '1 1 auto',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    item.appendChild(icon);
    item.appendChild(text);
    if (!active) {
      item.addEventListener('mouseenter', () => {
        item.style.background = 'rgba(255,255,255,0.045)';
        item.style.color = 'var(--token-text-primary, #f8fafc)';
      });
      item.addEventListener('mouseleave', () => {
        item.style.background = 'transparent';
        item.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.62))';
      });
      item.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        onClick && onClick();
      });
    }
    return item;
  }

  function buildControlPanelHeader() {
    const header = document.createElement('div');
    Object.assign(header.style, {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      gap: '12px',
      padding: '14px 20px',
      borderBottom: '1px solid var(--token-border, rgba(255,255,255,0.06))',
    });

    const titleWrap = document.createElement('div');
    Object.assign(titleWrap.style, {
      minWidth: '0',
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
    });

    const dot = document.createElement('span');
    dot.innerHTML = SHIM_ICON_SVG;
    Object.assign(dot.style, {
      width: '22px',
      height: '22px',
      color: '#93c5fd',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      flex: '0 0 auto',
      opacity: '0.9',
    });

    const titleText = document.createElement('span');
    titleText.textContent = S('shimControlTitle', 'Shim control');
    Object.assign(titleText.style, {
      fontSize: '14px',
      fontWeight: '600',
      letterSpacing: '0.2px',
      color: 'var(--token-text-primary, currentColor)',
    });

    titleWrap.appendChild(dot);
    titleWrap.appendChild(titleText);

    const actions = document.createElement('div');
    Object.assign(actions.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '4px',
      flex: '0 0 auto',
    });

    const ICON_REFRESH = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M13.5 8a5.5 5.5 0 1 1-1.61-3.89" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><path d="M13.5 2.5v3h-3" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    const ICON_COPY = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="5" y="5" width="8" height="9" rx="1.4" stroke="currentColor" stroke-width="1.3"/><path d="M11 5V3.4a1.4 1.4 0 0 0-1.4-1.4H4.4A1.4 1.4 0 0 0 3 3.4v6.2A1.4 1.4 0 0 0 4.4 11H5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';
    const ICON_CLOSE = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 4l8 8M12 4l-8 8" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>';

    actions.appendChild(buildControlIconButton(
      ICON_REFRESH,
      S('shimControlRefreshAria', 'Refresh status'),
      () => refreshOpenControlPanel(),
    ));
    actions.appendChild(buildControlIconButton(
      ICON_COPY,
      S('shimControlCopyAria', 'Copy status summary'),
      () => copyControlPanelSnapshot(),
    ));
    actions.appendChild(buildControlIconButton(
      ICON_CLOSE,
      S('shimControlClose', 'Close'),
      () => dismissPopover(),
    ));

    header.appendChild(titleWrap);
    header.appendChild(actions);
    return header;
  }

  function buildControlIconButton(svgHtml, ariaLabel, onClick) {
    const button = document.createElement('button');
    button.type = 'button';
    button.innerHTML = svgHtml;
    button.setAttribute('aria-label', ariaLabel);
    button.setAttribute('title', ariaLabel);
    Object.assign(button.style, {
      width: '28px',
      height: '28px',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: '0',
      borderRadius: '6px',
      background: 'transparent',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.62))',
      cursor: 'pointer',
      transition: 'background 140ms ease, color 140ms ease',
    });
    button.addEventListener('mouseenter', () => {
      button.style.background = 'rgba(255,255,255,0.06)';
      button.style.color = 'var(--token-text-primary, #f8fafc)';
    });
    button.addEventListener('mouseleave', () => {
      button.style.background = 'transparent';
      button.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.62))';
    });
    button.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      onClick();
    });
    return button;
  }

  function refreshOpenControlPanel() {
    const panel = document.getElementById(POPOVER_ID);
    const body = panel?.querySelector?.('[data-shim-control-body]');
    if (!panel || !body) return;
    // 刷新按钮的行为按当前 tab 走 - overview 重拉 snapshot, logs 重拉日志列表
    if (shimControlActiveTab === 'logs') {
      reloadLogs(panel);
      return;
    }
    renderControlPanelLoading(body);
    refreshControlPanel(panel);
  }

  async function copyControlPanelSnapshot() {
    if (shimControlActiveTab === 'logs') {
      const entries = shimControlLogsState.entries;
      if (!entries.length) {
        showToast(S('shimControlCopyEmpty', 'No status to copy yet'), 'warning');
        return;
      }
      const text = entries.map(formatLogEntryForCopy).join('\n');
      await copyTextToClipboard(text, S('shimControlCopied', 'Status copied'));
      return;
    }
    const snapshot = shimControlPanelSnapshot;
    if (!snapshot) {
      showToast(S('shimControlCopyEmpty', 'No status to copy yet'), 'warning');
      return;
    }
    const text = controlPanelSnapshotText(snapshot);
    await copyTextToClipboard(text, S('shimControlCopied', 'Status copied'));
  }

  async function copyTextToClipboard(text, successMessage) {
    try {
      if (!navigator.clipboard?.writeText) throw new Error('clipboard unavailable');
      await navigator.clipboard.writeText(text);
      showToast(successMessage, 'success');
    } catch (_) {
      showToast(S('shimControlCopyFailed', 'Copy failed'), 'error');
    }
  }

  function controlPanelSnapshotText(snapshot) {
    const providerLabel = snapshot.provider.ok
      ? (snapshot.provider.data.label || S('shimControlProviderEmpty', 'No active provider'))
      : `${S('shimControlProviderFailed', 'Provider unavailable')}: ${snapshot.provider.message || ''}`;
    const autoData = snapshot.autoSwitch.data || {};
    const labels = autoData.labels || {};
    const strategy = autoData.strategy || 'manual';
    const strategyLabel = labels[`strategy${strategy.charAt(0).toUpperCase()}${strategy.slice(1)}`] || strategy;
    const bridgeLabel = snapshot.bridge.ok
      ? S('shimControlBridgeReady', 'Connected')
      : `${S('shimControlBridgeFailed', 'Unavailable')}: ${snapshot.bridge.message || ''}`;
    const thread = snapshot.currentThread || {};
    const lines = [
      `${S('shimControlTitle', 'Shim control')}`,
      `${S('shimControlCurrentThread', 'Current thread')}: ${thread.label || ''}`,
      `${S('shimControlThreadId', 'Thread ID')}: ${thread.id || ''}`,
      `${S('shimControlBridge', 'Bridge')}: ${bridgeLabel}`,
      `${S('shimControlProvider', 'Provider')}: ${providerLabel}`,
      `${S('shimControlAutoSwitch', 'Auto switch')}: ${strategyLabel}`,
      `${S('shimControlClaudeBinding', 'Claude binding')}: ${snapshot.claude.value || ''}`,
    ];
    for (const item of snapshot.claude.details || []) {
      if (item && typeof item === 'object') {
        lines.push(`- ${item.source || ''} -> ${item.target || ''}`);
      } else {
        lines.push(`- ${item}`);
      }
    }
    return lines.join('\n');
  }

  function renderControlPanelLoading(body) {
    body.innerHTML = '';
    body.appendChild(buildControlLoadingPanel());
  }

  function buildControlLoadingPanel() {
    const loading = document.createElement('div');
    Object.assign(loading.style, {
      minHeight: '200px',
      display: 'grid',
      placeItems: 'center',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      textAlign: 'center',
      padding: '24px',
    });
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: '8px',
    });
    const spinner = document.createElement('div');
    Object.assign(spinner.style, {
      width: '18px',
      height: '18px',
      borderRadius: '999px',
      border: '2px solid rgba(255,255,255,0.10)',
      borderTopColor: '#60a5fa',
      animation: 'shimSpin 0.9s linear infinite',
      marginBottom: '4px',
    });
    if (!document.getElementById('__shim_spin_kf__')) {
      const style = document.createElement('style');
      style.id = '__shim_spin_kf__';
      style.textContent = '@keyframes shimSpin{to{transform:rotate(360deg)}}';
      document.head.appendChild(style);
    }
    const title = document.createElement('div');
    title.textContent = S('shimControlChecking', 'Checking…');
    Object.assign(title.style, {
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '13px',
      fontWeight: '500',
    });
    const desc = document.createElement('div');
    desc.textContent = S('shimControlCheckingDescription', 'Collecting bridge, provider, failover, and binding status.');
    Object.assign(desc.style, {
      fontSize: '12px',
      lineHeight: '1.5',
      maxWidth: '320px',
    });
    wrap.appendChild(spinner);
    wrap.appendChild(title);
    wrap.appendChild(desc);
    loading.appendChild(wrap);
    return loading;
  }

  async function refreshControlPanel(panel) {
    // labels 由 /provider/list 响应填充, 这里主动拉一次确保 i18n 是最新的,
    // 否则用户在 dart 改了文案后 JS 端 shimProviderState.labels 仍是旧值。
    // 用 Promise.all 让 labels 跟 snapshot 并行拉,不卡渲染。
    const [, snapshot] = await Promise.all([
      refreshProviderPickerState({ rebuildPopover: false }),
      loadControlPanelSnapshot(),
    ]);
    shimControlPanelSnapshot = snapshot;
    if (!document.body.contains(panel)) return;
    // labels 现在已经是最新的, 把 header/sidebar 静态文案跟着重建,
    // 顺带按当前 active tab 渲染内容区。
    renderControlPanelChrome(panel);
  }

  async function loadControlPanelSnapshot() {
    const bridge = await callShimRoute('/echo', { from: 'control-panel' }, 900);
    const provider = await callShimRoute('/provider/current', {}, 1600);
    const autoSwitch = await callShimRoute('/auto-switch/get', {}, 1600);
    const claude = await loadClaudeBindingOverview();
    const currentThread = {
      id: currentCodexThreadId() || '',
      label: currentCodexThreadLabel() || S('shimControlNoCodexThread', 'No active Codex conversation'),
    };
    return { bridge, provider, autoSwitch, claude, currentThread };
  }

  async function callShimRoute(path, payload, timeoutMs) {
    if (typeof window.shim !== 'function') {
      return { ok: false, message: 'bridge not ready' };
    }
    let timer;
    try {
      const timeout = new Promise((resolve) => {
        timer = setTimeout(() => resolve({ code: -1, message: 'timeout' }), timeoutMs);
      });
      const res = await Promise.race([window.shim(path, payload || {}), timeout]);
      if (res && res.code === 0) return { ok: true, data: res.data || {} };
      return { ok: false, message: res?.message || 'rpc error' };
    } catch (error) {
      return { ok: false, message: error?.message || String(error) };
    } finally {
      if (timer) clearTimeout(timer);
    }
  }

  async function loadClaudeBindingOverview() {
    const res = await callShimRoute('/claude-bridge/list', {}, 1600);
    if (!res.ok) {
      return {
        tone: 'error',
        value: `${S('shimControlClaudeBindingFailed', 'Binding status unavailable')}: ${res.message || ''}`,
        count: 0,
        details: [],
      };
    }
    const bindings = Array.isArray(res.data.bindings) ? res.data.bindings : [];
    if (!bindings.length) {
      return {
        tone: 'muted',
        value: S('shimControlClaudeBindingEmpty', 'No Codex conversations are bound'),
        count: 0,
        details: [],
      };
    }
    const details = bindings.map((binding) => {
      const codexThreadId = binding.codexThreadId || '';
      const claudeTitle = binding.title || binding.sessionId || S('shimControlClaudeSession', 'Claude session');
      const codexTitle = codexThreadLabelById(codexThreadId) ||
        (codexThreadId === '__legacy_claude_binding__'
          ? S('shimControlLegacyBinding', 'Legacy global binding')
          : shortThreadId(codexThreadId));
      if (codexThreadId) {
        applyClaudeBridgeStateForThread(codexThreadId, {
          bound: true,
          codexThreadId,
          sessionId: binding.sessionId,
          jsonlPath: binding.jsonlPath,
          title: binding.title,
        });
      }
      return {
        source: codexTitle,
        target: claudeTitle,
        codexThreadId,
        sessionId: binding.sessionId || '',
      };
    });
    return {
      tone: 'success',
      value: `${bindings.length} ${S('shimControlClaudeBindingCount', 'Codex conversations bound')}`,
      count: bindings.length,
      details,
    };
  }

  function renderControlPanelSnapshot(body, snapshot) {
    body.innerHTML = '';
    const model = controlPanelViewModel(snapshot);
    body.appendChild(buildStatusPreviewPage(snapshot, model));
  }

  // 一旦内容溢出 popover 自身的高度,左/右两列各自滚动比整页滚动更舒服:
  // 用户能边看右侧的 binding 列表边对照左侧的供应商详情。
  function buildStatusPreviewPage(snapshot, model) {
    const narrow = window.innerWidth < 760;

    const page = document.createElement('div');
    Object.assign(page.style, {
      minHeight: '0',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden',
    });

    page.appendChild(buildOverviewPageHeader());

    const scroll = document.createElement('div');
    Object.assign(scroll.style, {
      flex: '1 1 auto',
      minHeight: '0',
      overflowY: 'auto',
      overflowX: 'hidden',
      padding: narrow ? '16px 18px 22px' : '8px 28px 24px',
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
    });

    scroll.appendChild(buildStatusBar(snapshot, model));

    const workbench = document.createElement('div');
    Object.assign(workbench.style, {
      display: 'grid',
      gridTemplateColumns: narrow ? '1fr' : 'minmax(0, 1fr) minmax(260px, 320px)',
      gap: narrow ? '20px' : '24px',
      alignItems: 'stretch',
      minHeight: '0',
    });

    const leftCol = document.createElement('div');
    Object.assign(leftCol.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      gap: '20px',
      order: narrow ? '2' : '1',
    });
    const currentContext = buildCurrentContextCard(snapshot);
    if (currentContext) leftCol.appendChild(currentContext);
    leftCol.appendChild(buildProviderSection(model));

    const rightCol = document.createElement('div');
    Object.assign(rightCol.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      order: narrow ? '1' : '2',
    });
    rightCol.appendChild(buildBindingTable(snapshot));

    workbench.appendChild(leftCol);
    workbench.appendChild(rightCol);
    scroll.appendChild(workbench);

    page.appendChild(scroll);
    return page;
  }

  function buildOverviewPageHeader() {
    const header = document.createElement('div');
    Object.assign(header.style, {
      padding: '22px 28px 14px',
      flex: '0 0 auto',
      borderBottom: '1px solid var(--token-border, rgba(255,255,255,0.05))',
    });
    const title = document.createElement('h2');
    title.textContent = S('shimControlOverviewTab', 'Data overview');
    Object.assign(title.style, {
      margin: '0 0 4px',
      fontSize: '16px',
      fontWeight: '600',
      color: 'var(--token-text-primary, currentColor)',
      letterSpacing: '0.1px',
    });
    const desc = document.createElement('div');
    desc.textContent = S('shimControlCheckingDescription', 'Collecting bridge, provider, failover, and binding status.');
    Object.assign(desc.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      fontSize: '12px',
      lineHeight: '1.5',
    });
    header.appendChild(title);
    header.appendChild(desc);
    return header;
  }

  // 顶部健康状态条:一行四个 chip,Bridge/Provider/Auto/Mappings 各占一格。
  // 用户一眼看全, 不需要扫描 4 个 detail row。
  function buildStatusBar(snapshot, model) {
    const bar = document.createElement('div');
    Object.assign(bar.style, {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))',
      gap: '8px',
    });
    bar.appendChild(buildStatusChip(
      S('shimControlBridge', 'Bridge'),
      snapshot.bridge.ok
        ? S('shimControlBridgeReady', 'Connected')
        : S('shimControlBridgeFailed', 'Unavailable'),
      model.bridgeTone,
    ));
    bar.appendChild(buildStatusChip(
      S('shimControlProvider', 'Provider'),
      model.providerName || S('shimControlProviderEmpty', 'No active provider'),
      model.providerTone,
    ));
    bar.appendChild(buildStatusChip(
      S('shimControlAutoSwitch', 'Auto switch'),
      snapshot.autoSwitch.ok
        ? model.strategyLabel
        : S('shimControlAutoSwitchFailed', 'Unavailable'),
      model.autoTone,
    ));
    bar.appendChild(buildStatusChip(
      S('shimControlClaudeBinding', 'Context mapping'),
      `${snapshot.claude.count || 0} ${S('shimControlBoundMetricSuffix', 'mappings')}`,
      snapshot.claude.tone || 'muted',
    ));
    return bar;
  }

  function buildStatusChip(label, value, tone) {
    const chip = document.createElement('div');
    Object.assign(chip.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      minWidth: '0',
      padding: '10px 12px',
      borderRadius: '10px',
      background: 'rgba(255,255,255,0.028)',
      border: '1px solid var(--token-border, rgba(255,255,255,0.05))',
    });
    const dot = document.createElement('span');
    Object.assign(dot.style, {
      width: '8px',
      height: '8px',
      borderRadius: '999px',
      background: statusToneColor(tone),
      boxShadow: tone === 'success' || tone === 'error'
        ? `0 0 8px ${statusToneSoftBackground(tone)}`
        : 'none',
      flex: '0 0 auto',
    });
    const text = document.createElement('div');
    Object.assign(text.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      gap: '1px',
    });
    const labelEl = document.createElement('div');
    labelEl.textContent = label;
    Object.assign(labelEl.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      fontSize: '11px',
      fontWeight: '500',
      letterSpacing: '0.2px',
    });
    const valueEl = document.createElement('div');
    valueEl.textContent = value;
    valueEl.title = value;
    Object.assign(valueEl.style, {
      color: tone === 'error' ? statusToneColor(tone) : 'var(--token-text-primary, currentColor)',
      fontSize: '12.5px',
      fontWeight: '600',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    text.appendChild(labelEl);
    text.appendChild(valueEl);
    chip.appendChild(dot);
    chip.appendChild(text);
    return chip;
  }

  function buildProviderSection(model) {
    const section = buildPanelSection(S('shimControlProviderSection', 'Provider details'));

    if (model.providerTone !== 'success') {
      section.appendChild(buildEmptyState(
        ICON_PROVIDER_EMPTY,
        S('shimControlProviderEmpty', 'No active provider'),
        S('shimControlProviderEmptyDescription', 'Codex is using its current default provider.'),
      ));
      return section;
    }

    // 主信息: name + model 突出, protocol/weights/strategy 用元数据行带过
    const head = document.createElement('div');
    Object.assign(head.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      gap: '4px',
      padding: '4px 0 10px',
    });
    const name = document.createElement('div');
    name.textContent = model.providerName || model.providerLabel;
    name.title = name.textContent;
    Object.assign(name.style, {
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '15px',
      fontWeight: '600',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    const sub = document.createElement('div');
    sub.textContent = model.providerModel || S('shimControlProviderModelEmpty', 'Passthrough');
    sub.title = sub.textContent;
    Object.assign(sub.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.62))',
      fontSize: '13px',
      fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    head.appendChild(name);
    head.appendChild(sub);
    section.appendChild(head);

    section.appendChild(buildMetaRow([
      { label: S('shimControlProviderProtocol', 'Protocol'), value: model.providerProtocol || '—' },
      {
        label: S('shimControlProviderWeights', 'Weights'),
        value: model.providerWeight == null ? '—' : `${model.providerWeight}/${model.modelWeight ?? '—'}`,
      },
      { label: S('shimControlCurrentMode', 'Mode'), value: model.strategyLabel },
    ]));

    const hint = model.strategy === 'manual'
      ? S('shimControlAutoSwitchManualDescription', 'Automatic failover is standing by.')
      : S('shimControlAutoSwitchDescription', 'Provider health can trigger failover.');
    section.appendChild(buildPanelHint(hint));
    return section;
  }

  // 一行 N 项: label / value, 用中点分隔。比 detail row 节省空间。
  function buildMetaRow(items) {
    const row = document.createElement('div');
    Object.assign(row.style, {
      display: 'flex',
      flexWrap: 'wrap',
      alignItems: 'baseline',
      gap: '12px 16px',
      paddingTop: '10px',
      borderTop: '1px solid var(--token-border, rgba(255,255,255,0.05))',
    });
    for (const item of items) {
      const node = document.createElement('div');
      Object.assign(node.style, {
        display: 'flex',
        alignItems: 'baseline',
        gap: '6px',
        minWidth: '0',
      });
      const label = document.createElement('span');
      label.textContent = item.label;
      Object.assign(label.style, {
        color: 'var(--token-text-secondary, rgba(255,255,255,0.48))',
        fontSize: '11px',
        fontWeight: '500',
        letterSpacing: '0.2px',
      });
      const value = document.createElement('span');
      value.textContent = item.value;
      value.title = item.value;
      Object.assign(value.style, {
        color: 'var(--token-text-primary, currentColor)',
        fontSize: '12.5px',
        fontWeight: '500',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
      });
      node.appendChild(label);
      node.appendChild(value);
      row.appendChild(node);
    }
    return row;
  }

  const ICON_PROVIDER_EMPTY = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5 7h14v10a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V7z" stroke="currentColor" stroke-width="1.5"/><path d="M9 11h6M9 14h4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>';
  const ICON_BINDING_EMPTY = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9 7a3 3 0 1 0 0 6h2M15 17a3 3 0 1 0 0-6h-2" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>';

  function buildEmptyState(iconHtml, title, description) {
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: '8px',
      padding: '28px 16px',
      textAlign: 'center',
    });
    const icon = document.createElement('div');
    icon.innerHTML = iconHtml;
    Object.assign(icon.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.32))',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
    });
    const t = document.createElement('div');
    t.textContent = title;
    Object.assign(t.style, {
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '13px',
      fontWeight: '600',
    });
    const d = document.createElement('div');
    d.textContent = description;
    Object.assign(d.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.48))',
      fontSize: '12px',
      lineHeight: '1.5',
      maxWidth: '260px',
    });
    wrap.appendChild(icon);
    wrap.appendChild(t);
    wrap.appendChild(d);
    return wrap;
  }

  // ========== 日志 tab ==========

  // Logs 页面整体: page header + 过滤段 + 列表区
  function buildLogsPage(panel) {
    const page = document.createElement('div');
    Object.assign(page.style, {
      minHeight: '0',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden',
    });

    page.appendChild(buildLogsPageHeader());
    page.appendChild(buildLogsFilterRow(panel));

    const listWrap = document.createElement('div');
    listWrap.setAttribute('data-shim-logs-list', '1');
    Object.assign(listWrap.style, {
      flex: '1 1 auto',
      minHeight: '0',
      overflowY: 'auto',
      overflowX: 'hidden',
      padding: '8px 24px 20px',
    });
    page.appendChild(listWrap);

    renderLogsListContent(listWrap);
    return page;
  }

  function buildLogsPageHeader() {
    const header = document.createElement('div');
    Object.assign(header.style, {
      padding: '22px 24px 14px',
      flex: '0 0 auto',
      borderBottom: '1px solid var(--token-border, rgba(255,255,255,0.05))',
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between',
      gap: '12px',
    });
    const left = document.createElement('div');
    Object.assign(left.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      gap: '4px',
      flex: '1 1 auto',
    });
    const title = document.createElement('h2');
    title.textContent = S('shimControlLogsHeading', 'Runtime logs');
    Object.assign(title.style, {
      margin: '0',
      fontSize: '16px',
      fontWeight: '600',
      color: 'var(--token-text-primary, currentColor)',
      letterSpacing: '0.1px',
    });
    const desc = document.createElement('div');
    desc.textContent = S('shimControlLogsDescription', 'Recent log entries from the Shim backend, useful for diagnosing provider and binding issues.');
    Object.assign(desc.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      fontSize: '12px',
      lineHeight: '1.5',
    });
    left.appendChild(title);
    left.appendChild(desc);
    header.appendChild(left);
    return header;
  }

  function buildLogsFilterRow(panel) {
    const row = document.createElement('div');
    Object.assign(row.style, {
      flex: '0 0 auto',
      padding: '14px 24px 4px',
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      justifyContent: 'space-between',
      flexWrap: 'wrap',
    });

    const segment = document.createElement('div');
    Object.assign(segment.style, {
      display: 'inline-flex',
      padding: '3px',
      borderRadius: '8px',
      background: 'rgba(255,255,255,0.04)',
      border: '1px solid var(--token-border, rgba(255,255,255,0.06))',
      gap: '2px',
    });
    const filters = [
      { key: 'all', label: S('shimControlLogsFilterAll', 'All') },
      { key: 'info', label: S('shimControlLogsFilterInfo', 'Info') },
      { key: 'warning', label: S('shimControlLogsFilterWarning', 'Warn') },
      { key: 'error', label: S('shimControlLogsFilterError', 'Error') },
    ];
    for (const f of filters) {
      segment.appendChild(buildLogsFilterButton(panel, f.key, f.label));
    }

    const actions = document.createElement('div');
    Object.assign(actions.style, {
      display: 'inline-flex',
      alignItems: 'center',
      gap: '8px',
    });
    const count = document.createElement('span');
    count.setAttribute('data-shim-logs-count', '1');
    count.textContent = `${shimControlLogsState.entries.length} ${S('shimControlLogsCount', 'entries')}`;
    Object.assign(count.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      fontSize: '12px',
      fontWeight: '500',
      fontFeatureSettings: '"tnum"',
    });
    actions.appendChild(count);
    actions.appendChild(buildLogsClearButton(panel));

    row.appendChild(segment);
    row.appendChild(actions);
    return row;
  }

  function buildLogsFilterButton(panel, key, label) {
    const active = shimControlLogsState.filter === key;
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.textContent = label;
    Object.assign(btn.style, {
      padding: '5px 12px',
      border: '0',
      borderRadius: '6px',
      background: active ? 'rgba(96,165,250,0.18)' : 'transparent',
      color: active
        ? '#bfdbfe'
        : 'var(--token-text-secondary, rgba(255,255,255,0.62))',
      cursor: active ? 'default' : 'pointer',
      fontSize: '12px',
      fontWeight: '600',
      letterSpacing: '0.2px',
      transition: 'background 140ms ease, color 140ms ease',
    });
    if (!active) {
      btn.addEventListener('mouseenter', () => {
        btn.style.background = 'rgba(255,255,255,0.06)';
        btn.style.color = 'var(--token-text-primary, #f8fafc)';
      });
      btn.addEventListener('mouseleave', () => {
        btn.style.background = 'transparent';
        btn.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.62))';
      });
      btn.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        shimControlLogsState = { ...shimControlLogsState, filter: key };
        renderActiveTab(panel);
      });
    }
    return btn;
  }

  function buildLogsClearButton(panel) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.textContent = S('shimControlLogsClear', 'Clear');
    btn.setAttribute('aria-label', S('shimControlLogsClearAria', 'Clear logs'));
    Object.assign(btn.style, {
      padding: '5px 10px',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      borderRadius: '6px',
      background: 'transparent',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.62))',
      cursor: 'pointer',
      fontSize: '12px',
      fontWeight: '600',
      transition: 'background 140ms ease, color 140ms ease, border-color 140ms ease',
    });
    btn.addEventListener('mouseenter', () => {
      btn.style.background = 'rgba(239,68,68,0.10)';
      btn.style.borderColor = 'rgba(239,68,68,0.32)';
      btn.style.color = '#fca5a5';
    });
    btn.addEventListener('mouseleave', () => {
      btn.style.background = 'transparent';
      btn.style.borderColor = 'var(--token-border, rgba(255,255,255,0.08))';
      btn.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.62))';
    });
    btn.addEventListener('click', async (event) => {
      event.preventDefault();
      event.stopPropagation();
      const res = await callShimRoute('/logs/clear', {}, 1500);
      if (!res.ok) {
        showToast(`${S('shimControlLogsClearFailed', 'Clear failed')}: ${res.message || ''}`, 'error');
        return;
      }
      shimControlLogsState = { ...shimControlLogsState, entries: [] };
      renderActiveTab(panel);
      showToast(S('shimControlLogsCleared', 'Logs cleared'), 'success');
    });
    return btn;
  }

  // 仅刷新列表区, 不重建 chrome 或 page header
  function renderLogsListContent(listWrap) {
    listWrap.innerHTML = '';
    if (shimControlLogsState.loading) {
      listWrap.appendChild(buildControlLoadingPanel());
      return;
    }
    if (shimControlLogsState.error) {
      listWrap.appendChild(buildEmptyState(
        ICON_LOGS,
        S('shimControlLogsLoadFailed', 'Failed to load logs'),
        shimControlLogsState.error,
      ));
      return;
    }
    const visible = shimControlLogsState.entries.filter(matchesLogFilter);
    if (!visible.length) {
      listWrap.appendChild(buildEmptyState(
        ICON_LOGS,
        S('shimControlLogsEmpty', 'No logs yet'),
        S('shimControlLogsDescription', 'Recent log entries from the Shim backend, useful for diagnosing provider and binding issues.'),
      ));
      return;
    }
    const list = document.createElement('div');
    Object.assign(list.style, {
      display: 'flex',
      flexDirection: 'column',
      gap: '6px',
    });
    for (const entry of visible) {
      list.appendChild(buildLogEntryCard(entry));
    }
    listWrap.appendChild(list);
  }

  function matchesLogFilter(entry) {
    const f = shimControlLogsState.filter;
    if (f === 'all') return true;
    if (f === 'info') return entry.level === 'info' || entry.level === 'debug';
    if (f === 'warning') return entry.level === 'warning';
    if (f === 'error') return entry.level === 'error';
    return true;
  }

  function buildLogEntryCard(entry) {
    const card = document.createElement('div');
    Object.assign(card.style, {
      display: 'flex',
      flexDirection: 'column',
      gap: '6px',
      padding: '10px 12px',
      borderRadius: '8px',
      background: 'rgba(255,255,255,0.022)',
      border: '1px solid var(--token-border, rgba(255,255,255,0.05))',
    });
    const top = document.createElement('div');
    Object.assign(top.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      minWidth: '0',
    });
    top.appendChild(buildLogLevelBadge(entry.level));
    const source = document.createElement('span');
    source.textContent = entry.source || '';
    source.title = entry.source || '';
    Object.assign(source.style, {
      flex: '1 1 auto',
      minWidth: '0',
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '12.5px',
      fontWeight: '700',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    const time = document.createElement('span');
    time.textContent = formatLogTime(entry.timestamp);
    Object.assign(time.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      fontSize: '11px',
      fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
      fontFeatureSettings: '"tnum"',
      flex: '0 0 auto',
    });
    top.appendChild(source);
    top.appendChild(time);
    card.appendChild(top);

    const message = document.createElement('div');
    message.textContent = entry.message || '';
    Object.assign(message.style, {
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '13px',
      lineHeight: '1.45',
      wordBreak: 'break-word',
      whiteSpace: 'pre-wrap',
    });
    card.appendChild(message);

    if (entry.details) {
      const details = document.createElement('div');
      details.textContent = entry.details;
      Object.assign(details.style, {
        color: 'var(--token-text-secondary, rgba(255,255,255,0.58))',
        fontSize: '12px',
        lineHeight: '1.5',
        fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
        background: 'rgba(0,0,0,0.18)',
        borderRadius: '6px',
        padding: '6px 8px',
        whiteSpace: 'pre-wrap',
        wordBreak: 'break-word',
        maxHeight: '160px',
        overflowY: 'auto',
      });
      card.appendChild(details);
    }
    return card;
  }

  function buildLogLevelBadge(level) {
    const meta = logLevelMeta(level);
    const badge = document.createElement('span');
    badge.textContent = meta.label;
    Object.assign(badge.style, {
      flex: '0 0 auto',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '2px 8px',
      borderRadius: '999px',
      background: meta.background,
      color: meta.color,
      fontSize: '10px',
      fontWeight: '800',
      letterSpacing: '0.4px',
      border: `1px solid ${meta.border}`,
    });
    return badge;
  }

  function logLevelMeta(level) {
    if (level === 'error') {
      return { label: 'ERROR', color: '#fca5a5', background: 'rgba(239,68,68,0.16)', border: 'rgba(239,68,68,0.36)' };
    }
    if (level === 'warning') {
      return { label: 'WARN', color: '#fcd34d', background: 'rgba(245,158,11,0.16)', border: 'rgba(245,158,11,0.36)' };
    }
    if (level === 'debug') {
      return { label: 'DEBUG', color: 'rgba(255,255,255,0.62)', background: 'rgba(255,255,255,0.06)', border: 'rgba(255,255,255,0.10)' };
    }
    return { label: 'INFO', color: '#93c5fd', background: 'rgba(96,165,250,0.16)', border: 'rgba(96,165,250,0.36)' };
  }

  function formatLogTime(iso) {
    if (!iso) return '';
    const date = new Date(iso);
    if (isNaN(date.getTime())) return iso;
    const pad = (n, w = 2) => String(n).padStart(w, '0');
    return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}.${pad(date.getMilliseconds(), 3)}`;
  }

  function formatLogEntryForCopy(entry) {
    const lines = [`${formatLogTime(entry.timestamp)} ${logLevelMeta(entry.level).label} ${entry.source || ''} - ${entry.message || ''}`];
    if (entry.details) lines.push(entry.details);
    return lines.join('\n');
  }

  async function reloadLogs(panel) {
    shimControlLogsState = { ...shimControlLogsState, loading: true, error: null };
    const listWrap = panel.querySelector('[data-shim-logs-list]');
    if (listWrap) renderLogsListContent(listWrap);

    const res = await callShimRoute('/logs/list', {}, 2000);
    if (!document.body.contains(panel)) return;
    if (!res.ok) {
      shimControlLogsState = {
        ...shimControlLogsState,
        loading: false,
        error: res.message || S('shimControlLogsLoadFailed', 'Failed to load logs'),
      };
    } else {
      const entries = Array.isArray(res.data.entries) ? res.data.entries : [];
      shimControlLogsState = {
        ...shimControlLogsState,
        loading: false,
        error: null,
        entries,
      };
    }
    // 列表区 + 计数都要更新
    const list2 = panel.querySelector('[data-shim-logs-list]');
    if (list2) renderLogsListContent(list2);
    const countEl = panel.querySelector('[data-shim-logs-count]');
    if (countEl) {
      countEl.textContent = `${shimControlLogsState.entries.length} ${S('shimControlLogsCount', 'entries')}`;
    }
  }

  function controlPanelViewModel(snapshot) {
    const providerData = snapshot.provider.data || {};
    const providerLabel = snapshot.provider.ok
      ? (providerData.label || S('shimControlProviderEmpty', 'No active provider'))
      : `${S('shimControlProviderFailed', 'Provider unavailable')}: ${snapshot.provider.message || ''}`;
    const autoData = snapshot.autoSwitch.data || {};
    const labels = autoData.labels || {};
    const strategy = autoData.strategy || 'manual';
    const strategyLabel = labels[`strategy${strategy.charAt(0).toUpperCase()}${strategy.slice(1)}`] || strategy;
    const bridgeValue = snapshot.bridge.ok
      ? S('shimControlBridgeReady', 'Connected')
      : `${S('shimControlBridgeFailed', 'Unavailable')}: ${snapshot.bridge.message || ''}`;
    const autoValue = snapshot.autoSwitch.ok
      ? strategyLabel
      : `${S('shimControlAutoSwitchFailed', 'Unavailable')}: ${snapshot.autoSwitch.message || ''}`;
    return {
      providerLabel,
      strategy,
      strategyLabel,
      bridgeValue,
      autoValue,
      providerName: providerData.name || '',
      providerModel: providerData.model || '',
      providerProtocol: providerData.protocol || '',
      providerWeight: providerData.providerWeight,
      modelWeight: providerData.modelWeight,
      providerTone: snapshot.provider.ok && providerData.label ? 'success' : 'muted',
      autoTone: snapshot.autoSwitch.ok && strategy !== 'manual' ? 'success' : 'muted',
      bridgeTone: snapshot.bridge.ok ? 'success' : 'error',
    };
  }

  function buildPanelHint(text) {
    const hint = document.createElement('div');
    hint.textContent = text || '';
    Object.assign(hint.style, {
      marginTop: '12px',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.42))',
      fontSize: '12px',
      lineHeight: '1.5',
    });
    return hint;
  }

  function buildPanelSection(title) {
    const section = document.createElement('section');
    Object.assign(section.style, {
      padding: '0',
    });
    const heading = document.createElement('div');
    heading.textContent = title;
    Object.assign(heading.style, {
      marginBottom: '12px',
      paddingBottom: '8px',
      borderBottom: '1px solid var(--token-border, rgba(255,255,255,0.06))',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.55))',
      fontSize: '11px',
      fontWeight: '600',
      letterSpacing: '0.6px',
      textTransform: 'uppercase',
    });
    section.appendChild(heading);
    return section;
  }

  // 对话映射表在右列, 自己独立滚动, 内部 max-height 限制让它不会撑爆 popover。
  function buildBindingTable(snapshot) {
    const details = snapshot.claude.details || [];
    const section = buildPanelSection(
      `${S('shimControlBindingsSection', 'Claude bindings')}${details.length ? ` · ${details.length}` : ''}`,
    );
    Object.assign(section.style, {
      display: 'flex',
      flexDirection: 'column',
      minHeight: '0',
      flex: '1 1 auto',
    });

    if (!details.length) {
      section.appendChild(buildEmptyState(
        ICON_BINDING_EMPTY,
        S('shimControlClaudeBindingEmpty', 'No Codex conversations are mapped'),
        S('shimControlClaudeBindingEmptyDescription', 'Bind a Claude session from the sidebar to continue context here.'),
      ));
      return section;
    }

    const list = document.createElement('div');
    Object.assign(list.style, {
      display: 'flex',
      flexDirection: 'column',
      gap: '4px',
      maxHeight: '380px',
      overflowY: 'auto',
      overflowX: 'hidden',
      paddingRight: '4px',
      marginRight: '-4px',
    });

    for (const item of details) {
      list.appendChild(buildBindingRow(item, snapshot.currentThread?.id));
    }

    section.appendChild(list);
    return section;
  }

  // 一行卡片式的映射: codex 标题 / 箭头 / claude 标题 / hover 时出现的解绑按钮。
  // 当前对话所在行用蓝色描边强调。解绑按钮平时隐藏(opacity:0), hover 整行才浮现, 避免视觉噪音。
  function buildBindingRow(item, currentThreadId) {
    const row = document.createElement('div');
    const current = item.codexThreadId && item.codexThreadId === currentThreadId;
    Object.assign(row.style, {
      display: 'grid',
      gridTemplateColumns: 'minmax(0, 1fr) 18px minmax(0, 1fr) 24px',
      alignItems: 'center',
      gap: '10px',
      padding: '10px 12px',
      borderRadius: '8px',
      background: current ? 'rgba(96,165,250,0.10)' : 'rgba(255,255,255,0.018)',
      border: `1px solid ${current ? 'rgba(96,165,250,0.30)' : 'var(--token-border, rgba(255,255,255,0.05))'}`,
      transition: 'background 140ms ease, border-color 140ms ease',
    });
    row.appendChild(buildRelationText(item.source || ''));
    const arrow = document.createElement('span');
    arrow.innerHTML = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    Object.assign(arrow.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: current ? '#60a5fa' : 'var(--token-text-secondary, rgba(255,255,255,0.32))',
    });
    row.appendChild(arrow);
    row.appendChild(buildRelationText(item.target || ''));

    const unbindBtn = buildBindingUnbindButton(item);
    row.appendChild(unbindBtn);

    // hover 整行 → 解绑按钮浮现; 非当前行还顺带换底色
    row.addEventListener('mouseenter', () => {
      if (!current) row.style.background = 'rgba(255,255,255,0.038)';
      unbindBtn.style.opacity = '1';
    });
    row.addEventListener('mouseleave', () => {
      if (!current) row.style.background = 'rgba(255,255,255,0.018)';
      if (unbindBtn.dataset.shimBusy !== '1') unbindBtn.style.opacity = '0';
    });
    return row;
  }

  function buildBindingUnbindButton(item) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.setAttribute('aria-label', S('shimControlBindingUnbindAria', 'Remove this mapping'));
    btn.setAttribute('title', S('shimControlBindingUnbind', 'Unbind'));
    btn.innerHTML = '<svg width="12" height="12" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 4l8 8M12 4l-8 8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>';
    Object.assign(btn.style, {
      width: '22px',
      height: '22px',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: '0',
      borderRadius: '5px',
      background: 'transparent',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      cursor: 'pointer',
      opacity: '0',
      transition: 'opacity 140ms ease, background 140ms ease, color 140ms ease',
    });
    btn.addEventListener('mouseenter', () => {
      btn.style.background = 'rgba(239,68,68,0.16)';
      btn.style.color = '#fca5a5';
    });
    btn.addEventListener('mouseleave', () => {
      btn.style.background = 'transparent';
      btn.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.5))';
    });
    btn.addEventListener('click', async (event) => {
      event.preventDefault();
      event.stopPropagation();
      if (btn.dataset.shimBusy === '1') return;
      btn.dataset.shimBusy = '1';
      btn.style.opacity = '1';
      await unbindMappingFromControlPanel(item);
      btn.dataset.shimBusy = '0';
    });
    return btn;
  }

  // 解绑一条 binding, 直接更新本地 snapshot 并刷新 overview 页, 不需要往返一次 list
  async function unbindMappingFromControlPanel(item) {
    const codexThreadId = item && item.codexThreadId;
    if (!codexThreadId) {
      showToast(S('shimControlBindingUnbindFailed', 'Unbind failed'), 'error');
      return;
    }
    const res = await callShimRoute('/claude-bridge/unbind', { codexThreadId }, 2000);
    if (!res.ok) {
      showToast(`${S('shimControlBindingUnbindFailed', 'Unbind failed')}: ${res.message || ''}`, 'error');
      return;
    }
    // 同步给侧栏 chip(如果当前 codex thread 就是被解绑的 thread, chip 也要变回未绑定)
    if (typeof applyClaudeBridgeStateForThread === 'function') {
      try {
        applyClaudeBridgeStateForThread(codexThreadId, res.data || { bound: false });
      } catch (_) {}
    }
    // 从内存 snapshot 里删掉这一项, 重渲染 overview, 不必再走一次 /claude-bridge/list
    if (shimControlPanelSnapshot && shimControlPanelSnapshot.claude) {
      const claude = shimControlPanelSnapshot.claude;
      const nextDetails = (claude.details || []).filter((d) => d.codexThreadId !== codexThreadId);
      shimControlPanelSnapshot = {
        ...shimControlPanelSnapshot,
        claude: {
          ...claude,
          details: nextDetails,
          count: nextDetails.length,
          tone: nextDetails.length ? claude.tone : 'muted',
        },
      };
      const panel = document.getElementById(POPOVER_ID);
      if (panel && shimControlActiveTab === 'overview') {
        const body = panel.querySelector('[data-shim-control-body]');
        if (body) renderControlPanelSnapshot(body, shimControlPanelSnapshot);
      }
    }
    showToast(S('shimControlBindingUnboundToast', 'Mapping removed'), 'success');
  }

  // 没选中 Codex 对话时整张卡彻底不渲染 — 返回 null, 调用方负责跳过。
  // 选中后用一张突出的卡片显示: thread title + id + 映射状态 + 已映射的 claude 会话名。
  function buildCurrentContextCard(snapshot) {
    const thread = snapshot.currentThread || {};
    const currentId = thread.id || '';
    if (!currentId) return null;

    const currentBinding = (snapshot.claude.details || []).find((item) =>
      item && typeof item === 'object' && item.codexThreadId === currentId);
    const tone = currentBinding ? 'success' : 'info';

    const card = document.createElement('div');
    Object.assign(card.style, {
      display: 'flex',
      flexDirection: 'column',
      gap: '12px',
      padding: '16px 18px',
      borderRadius: '12px',
      background: tone === 'success'
        ? 'linear-gradient(135deg, rgba(96,165,250,0.08), rgba(255,255,255,0.025))'
        : 'rgba(255,255,255,0.032)',
      border: `1px solid ${tone === 'success' ? 'rgba(96,165,250,0.22)' : 'var(--token-border, rgba(255,255,255,0.06))'}`,
    });

    const topRow = document.createElement('div');
    Object.assign(topRow.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '8px',
      minWidth: '0',
    });

    const titleWrap = document.createElement('div');
    Object.assign(titleWrap.style, {
      minWidth: '0',
      display: 'flex',
      flexDirection: 'column',
      gap: '4px',
      flex: '1 1 auto',
    });
    const label = document.createElement('div');
    label.textContent = S('shimControlCurrentThread', 'Current thread');
    Object.assign(label.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      fontSize: '11px',
      fontWeight: '500',
      letterSpacing: '0.4px',
      textTransform: 'uppercase',
    });
    const title = document.createElement('div');
    title.textContent = thread.label || S('shimControlNoCodexThread', 'No active Codex conversation');
    title.title = thread.label || '';
    Object.assign(title.style, {
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '14px',
      fontWeight: '600',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    titleWrap.appendChild(label);
    titleWrap.appendChild(title);

    const badge = document.createElement('span');
    badge.textContent = currentBinding
      ? S('shimControlBoundTo', 'Mapped to').replace(/\s*[:：]?$/, '')
      : S('shimControlReadyToBind', 'Not mapped');
    Object.assign(badge.style, {
      flex: '0 0 auto',
      padding: '4px 10px',
      borderRadius: '999px',
      color: statusToneColor(tone),
      background: statusToneSoftBackground(tone),
      fontSize: '11px',
      fontWeight: '600',
      letterSpacing: '0.2px',
      whiteSpace: 'nowrap',
    });

    topRow.appendChild(titleWrap);
    topRow.appendChild(badge);
    topRow.appendChild(buildThreadActionsOverflow(currentId, thread, !!currentBinding));
    card.appendChild(topRow);

    const idRow = document.createElement('div');
    Object.assign(idRow.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '8px',
      minWidth: '0',
    });
    const idText = document.createElement('span');
    idText.textContent = shortThreadId(currentId);
    idText.title = currentId;
    Object.assign(idText.style, {
      color: 'var(--token-text-secondary, rgba(255,255,255,0.55))',
      fontSize: '12px',
      fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    idRow.appendChild(idText);
    idRow.appendChild(buildCopyIdButton(currentId));
    card.appendChild(idRow);

    if (currentBinding) {
      const mapped = document.createElement('div');
      Object.assign(mapped.style, {
        display: 'flex',
        alignItems: 'center',
        gap: '10px',
        padding: '10px 12px',
        borderRadius: '8px',
        background: 'rgba(0,0,0,0.16)',
        minWidth: '0',
      });
      const arrow = document.createElement('span');
      arrow.innerHTML = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/></svg>';
      Object.assign(arrow.style, {
        color: '#60a5fa',
        flex: '0 0 auto',
        display: 'inline-flex',
      });
      const target = document.createElement('span');
      target.textContent = currentBinding.target || S('shimControlClaudeSession', 'Claude session');
      target.title = target.textContent;
      Object.assign(target.style, {
        color: 'var(--token-text-primary, currentColor)',
        fontSize: '13px',
        fontWeight: '500',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
      });
      mapped.appendChild(arrow);
      mapped.appendChild(target);
      card.appendChild(mapped);
    }

    return card;
  }

  // ========== 当前对话卡: 操作菜单 ==========
  // 之前一行 5 个按钮挤在卡片宽度里, 窄屏会被 wrap 成 2+2+1, 文字也被 ellipsis 吃光。
  // 改成: 卡片标题行右上角一个 `⋯` 按钮, 点击弹出垂直菜单, 菜单宽度固定, 不受卡片宽度影响。
  //
  // 菜单项 (按出现顺序):
  //   导出 Markdown / 导出原始 / 导出 HTML
  //   ─────
  //   导入对话 ▸  (悬停展开二级: .jsonl / .zip)
  //   ─────
  //   解除映射  (仅 hasBinding=true 时显示)
  //   删除对话  (danger 色)

  const THREAD_ACTIONS_MENU_ID = '__shim_thread_actions_menu__';
  const EXPORT_MENU_ID = '__shim_export_menu__';

  const ICON_EXPORT = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8 10V2M4.5 6.5L8 3l3.5 3.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 13h10" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';
  const ICON_EXPORT_MD = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 2.5h7l3 3v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.2"/><path d="M10 2.5V6h3" stroke="currentColor" stroke-width="1.2"/></svg>';
  const ICON_EXPORT_RAW = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 2h6l2 2v10H4z" stroke="currentColor" stroke-width="1.2"/><path d="M6 6h4M6 9h4M6 12h3" stroke="currentColor" stroke-width="1.2"/></svg>';
  const ICON_EXPORT_HTML = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 2.5h7l3 3v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.2"/><path d="M10 2.5V6h3" stroke="currentColor" stroke-width="1.2"/><path d="M5 10l-1.2 1.2L5 12.4M11 10l1.2 1.2L11 12.4M8.5 9.6l-1 3.2" stroke="currentColor" stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  const ICON_UNBIND = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5 8a3 3 0 1 0 0 0M11 8a3 3 0 1 0 0 0" stroke="currentColor" stroke-width="1.3"/><path d="M3 13l10-10" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';
  const ICON_DELETE = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 4h10M6 4V3a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v1M4.5 4l.7 9a1 1 0 0 0 1 .9h3.6a1 1 0 0 0 1-.9l.7-9" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';
  const ICON_IMPORT = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8 2v8M4.5 7.5L8 11l3.5-3.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 13h10" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';

  function buildThreadActionsOverflow(threadId, thread, hasBinding) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.setAttribute('aria-label', S('shimControlThreadActions', 'Conversation actions'));
    btn.setAttribute('title', S('shimControlThreadActions', 'Conversation actions'));
    Object.assign(btn.style, {
      flex: '0 0 auto',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '28px',
      height: '28px',
      borderRadius: '6px',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      background: 'transparent',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.7))',
      cursor: 'pointer',
      transition: 'background 140ms ease, color 140ms ease, border-color 140ms ease',
    });
    btn.innerHTML = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="3.5" cy="8" r="1.1" fill="currentColor"/><circle cx="8" cy="8" r="1.1" fill="currentColor"/><circle cx="12.5" cy="8" r="1.1" fill="currentColor"/></svg>';
    btn.addEventListener('mouseenter', () => {
      btn.style.background = 'rgba(96,165,250,0.10)';
      btn.style.borderColor = 'rgba(96,165,250,0.28)';
      btn.style.color = '#bfdbfe';
    });
    btn.addEventListener('mouseleave', () => {
      btn.style.background = 'transparent';
      btn.style.borderColor = 'var(--token-border, rgba(255,255,255,0.08))';
      btn.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.7))';
    });
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      toggleThreadActionsMenu(btn, threadId, thread, hasBinding);
    });
    return btn;
  }

  function dismissThreadActionsMenu() {
    document.getElementById(THREAD_ACTIONS_MENU_ID)?.remove();
    dismissExportMenu();
    document.removeEventListener('mousedown', onThreadActionsMenuOutside, true);
    document.removeEventListener('keydown', onThreadActionsMenuKey, true);
  }
  function onThreadActionsMenuOutside(e) {
    const menu = document.getElementById(THREAD_ACTIONS_MENU_ID);
    if (!menu || menu.contains(e.target)) return;
    // 子菜单 (导入/导出) 也是浮层, 点它们不能关父菜单
    const importMenu = document.getElementById(IMPORT_MENU_ID);
    if (importMenu && importMenu.contains(e.target)) return;
    const exportMenu = document.getElementById(EXPORT_MENU_ID);
    if (exportMenu && exportMenu.contains(e.target)) return;
    dismissThreadActionsMenu();
  }
  function onThreadActionsMenuKey(e) {
    if (e.key === 'Escape') {
      dismissThreadActionsMenu();
      dismissImportMenu();
      dismissExportMenu();
    }
  }

  function dismissExportMenu() {
    document.getElementById(EXPORT_MENU_ID)?.remove();
  }

  function toggleThreadActionsMenu(anchor, threadId, thread, hasBinding) {
    if (document.getElementById(THREAD_ACTIONS_MENU_ID)) {
      dismissThreadActionsMenu();
      dismissImportMenu();
      return;
    }
    const menu = document.createElement('div');
    menu.id = THREAD_ACTIONS_MENU_ID;
    Object.assign(menu.style, {
      position: 'fixed',
      zIndex: '2147483647',
      width: '220px',
      padding: '4px',
      borderRadius: '10px',
      background: 'var(--token-main-surface-primary, rgba(24,24,26,0.98))',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      boxShadow: '0 16px 40px rgba(0, 0, 0, 0.46)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '12.5px',
    });

    // 导出对话 ▸  (二级菜单: Markdown / 原始 / HTML)
    const exportItem = buildSubmenuMenuItem(ICON_EXPORT, S('shimControlExport', 'Export conversation'));
    exportItem.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      toggleExportSubmenu(exportItem, threadId);
    });
    menu.appendChild(exportItem);

    menu.appendChild(buildMenuDivider());

    // 导入对话 ▸  (二级菜单: .jsonl / .zip, 老逻辑)
    const importItem = buildSubmenuMenuItem(ICON_IMPORT, S('shimControlImport', 'Import'));
    importItem.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      // 子菜单以 importItem 自己作为 anchor 弹出。
      // toggleImportMenu 内部点子项后会 dismissImportMenu() 自己, 这里再额外把父菜单一并关掉,
      // 避免导入开始后父菜单还挂在屏幕上。
      const wasOpen = !!document.getElementById(IMPORT_MENU_ID);
      toggleImportMenu(importItem, threadId);
      if (!wasOpen) {
        const importMenu = document.getElementById(IMPORT_MENU_ID);
        importMenu?.addEventListener('click', () => {
          // 用 mousedown 已经 stopPropagation, click 这里冒上来时菜单可能已经销毁
          setTimeout(() => dismissThreadActionsMenu(), 0);
        }, true);
      }
    });
    menu.appendChild(importItem);

    if (hasBinding) {
      menu.appendChild(buildMenuDivider());
      menu.appendChild(buildThreadMenuItem(ICON_UNBIND, S('shimControlUnbindCurrent', 'Remove mapping'), 'neutral', async () => {
        dismissThreadActionsMenu();
        await unbindMappingFromControlPanel({ codexThreadId: threadId });
      }));
    }

    menu.appendChild(buildMenuDivider());
    menu.appendChild(buildThreadMenuItem(ICON_DELETE, S('shimControlDeleteThread', 'Delete thread'), 'danger', async () => {
      dismissThreadActionsMenu();
      await deleteThreadFromControlPanel(threadId, thread.label || '');
    }));

    document.body.appendChild(menu);
    // 定位: 按钮下方, 右对齐 (按钮在卡片右上角, 菜单往左展开更顺眼)
    const r = anchor.getBoundingClientRect();
    const mr = menu.getBoundingClientRect();
    let left = r.right - mr.width;
    let top = r.bottom + 4;
    if (left < 8) left = 8;
    if (top + mr.height > window.innerHeight - 8) top = r.top - mr.height - 4;
    menu.style.left = `${left}px`;
    menu.style.top = `${Math.max(8, top)}px`;

    document.addEventListener('mousedown', onThreadActionsMenuOutside, true);
    document.addEventListener('keydown', onThreadActionsMenuKey, true);
  }

  function buildMenuDivider() {
    const div = document.createElement('div');
    Object.assign(div.style, {
      height: '1px',
      background: 'var(--token-border, rgba(255,255,255,0.06))',
      margin: '4px 6px',
    });
    return div;
  }

  // 父菜单里"有二级菜单"的项: 复用 buildThreadMenuItem (onClick=null) 再补一个 ▸ caret。
  // 调用方自己绑 click 决定怎么弹子菜单。
  function buildSubmenuMenuItem(iconHtml, label) {
    const item = buildThreadMenuItem(iconHtml, label, 'neutral', null);
    const caret = document.createElement('span');
    caret.textContent = '▸';
    caret.style.cssText = 'margin-left:auto;opacity:0.5;font-size:10px;flex:0 0 auto;';
    item.appendChild(caret);
    return item;
  }

  // 导出二级菜单: Markdown / 原始 / HTML, 跟 import 子菜单同一套布局风格。
  // 点其中一项后两层菜单一起关。
  function toggleExportSubmenu(anchor, threadId) {
    if (document.getElementById(EXPORT_MENU_ID)) {
      dismissExportMenu();
      return;
    }
    const menu = document.createElement('div');
    menu.id = EXPORT_MENU_ID;
    Object.assign(menu.style, {
      position: 'fixed',
      zIndex: '2147483647',
      width: '200px',
      padding: '4px',
      borderRadius: '10px',
      background: 'var(--token-main-surface-primary, rgba(24,24,26,0.98))',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      boxShadow: '0 16px 40px rgba(0, 0, 0, 0.46)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '12.5px',
    });

    const choose = async (format) => {
      dismissThreadActionsMenu();
      await exportThreadById(threadId, format);
    };
    menu.appendChild(buildThreadMenuItem(ICON_EXPORT_MD, S('shimControlExportMarkdown', 'Export as Markdown'), 'neutral', () => choose('markdown')));
    menu.appendChild(buildThreadMenuItem(ICON_EXPORT_RAW, S('shimControlExportRaw', 'Export raw data'), 'neutral', () => choose('raws')));
    menu.appendChild(buildThreadMenuItem(ICON_EXPORT_HTML, S('shimControlExportHtml', 'Export HTML'), 'neutral', () => choose('html')));

    document.body.appendChild(menu);
    // 子菜单贴在 anchor 右边; 横向不够就退回到 anchor 下方右对齐。
    const r = anchor.getBoundingClientRect();
    const mr = menu.getBoundingClientRect();
    let left = r.right + 4;
    let top = r.top;
    if (left + mr.width > window.innerWidth - 8) {
      left = Math.max(8, r.right - mr.width);
      top = r.bottom + 4;
    }
    if (top + mr.height > window.innerHeight - 8) {
      top = Math.max(8, window.innerHeight - mr.height - 8);
    }
    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;
  }

  // 通用菜单项: icon + 文本, danger 项用红色 hover。
  // onClick 传 null 时调用方负责自己绑 click (用于"导入"这种需要弹二级菜单的情况)。
  function buildThreadMenuItem(iconHtml, label, kind, onClick) {
    const item = document.createElement('button');
    item.type = 'button';
    Object.assign(item.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      width: '100%',
      padding: '8px 10px',
      border: '0',
      borderRadius: '6px',
      background: 'transparent',
      color: kind === 'danger'
        ? 'var(--token-text-primary, currentColor)'
        : 'var(--token-text-primary, currentColor)',
      cursor: 'pointer',
      fontSize: '12.5px',
      fontWeight: '500',
      textAlign: 'left',
      transition: 'background 140ms ease, color 140ms ease',
    });
    const icon = document.createElement('span');
    icon.innerHTML = iconHtml;
    Object.assign(icon.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '16px',
      flex: '0 0 auto',
      color: kind === 'danger'
        ? 'var(--token-error, #f87171)'
        : 'var(--token-text-secondary, rgba(255,255,255,0.62))',
    });
    const text = document.createElement('span');
    text.textContent = label;
    Object.assign(text.style, {
      flex: '1 1 auto',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
    });
    item.appendChild(icon);
    item.appendChild(text);
    const hoverBg = kind === 'danger' ? 'rgba(239,68,68,0.14)' : 'rgba(96,165,250,0.10)';
    const hoverColor = kind === 'danger' ? '#fca5a5' : 'var(--token-text-primary, currentColor)';
    item.addEventListener('mouseenter', () => {
      item.style.background = hoverBg;
      if (kind === 'danger') {
        item.style.color = hoverColor;
        icon.style.color = hoverColor;
      }
    });
    item.addEventListener('mouseleave', () => {
      item.style.background = 'transparent';
      item.style.color = 'var(--token-text-primary, currentColor)';
      icon.style.color = kind === 'danger'
        ? 'var(--token-error, #f87171)'
        : 'var(--token-text-secondary, rgba(255,255,255,0.62))';
    });
    if (onClick) {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        onClick();
      });
    }
    return item;
  }

  const IMPORT_MENU_ID = '__shim_import_menu__';

  function dismissImportMenu() {
    document.getElementById(IMPORT_MENU_ID)?.remove();
    document.removeEventListener('mousedown', onImportMenuOutside, true);
    document.removeEventListener('keydown', onImportMenuKey, true);
  }
  function onImportMenuOutside(e) {
    const menu = document.getElementById(IMPORT_MENU_ID);
    if (!menu || menu.contains(e.target)) return;
    dismissImportMenu();
  }
  function onImportMenuKey(e) {
    if (e.key === 'Escape') dismissImportMenu();
  }

  function toggleImportMenu(anchor, threadId) {
    if (document.getElementById(IMPORT_MENU_ID)) {
      dismissImportMenu();
      return;
    }
    // 当前 thread 所在项目的 cwd: 从 codex 侧栏 row 反查
    const targetCwd = cwdForThreadId(threadId);

    const menu = document.createElement('div');
    menu.id = IMPORT_MENU_ID;
    Object.assign(menu.style, {
      position: 'fixed',
      zIndex: '2147483647',
      minWidth: '220px',
      maxWidth: '300px',
      padding: '4px',
      borderRadius: '10px',
      background: 'var(--token-main-surface-primary, rgba(24,24,26,0.98))',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      boxShadow: '0 16px 40px rgba(0, 0, 0, 0.46)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '12.5px',
    });

    menu.appendChild(buildImportMenuItem(S('shimControlImportJsonl', 'Import .jsonl'), async () => {
      dismissImportMenu();
      await runImportFile(targetCwd);
    }));
    menu.appendChild(buildImportMenuItem(S('shimControlImportZip', 'Import zip'), async () => {
      dismissImportMenu();
      await runImportBundle(targetCwd);
    }));

    // hint 行(说明会把导入归到当前项目 + 提示刷新)
    if (targetCwd) {
      const hint = document.createElement('div');
      Object.assign(hint.style, {
        padding: '6px 10px 4px',
        color: 'var(--token-text-secondary, rgba(255,255,255,0.48))',
        fontSize: '10.5px',
        lineHeight: '1.4',
        borderTop: '1px solid var(--token-border, rgba(255,255,255,0.05))',
        marginTop: '4px',
      });
      hint.textContent = `${S('shimControlImportToCurrent', 'Assign to current project')} · ${S('shimControlImportHint', 'Reload Codex to see imported threads in the sidebar')}`;
      menu.appendChild(hint);
    }

    document.body.appendChild(menu);
    // 定位: 在按钮下方
    const r = anchor.getBoundingClientRect();
    const mr = menu.getBoundingClientRect();
    let left = r.left;
    let top = r.bottom + 4;
    if (left + mr.width > window.innerWidth - 8) left = window.innerWidth - mr.width - 8;
    if (top + mr.height > window.innerHeight - 8) top = r.top - mr.height - 4;
    menu.style.left = `${Math.max(8, left)}px`;
    menu.style.top = `${Math.max(8, top)}px`;

    document.addEventListener('mousedown', onImportMenuOutside, true);
    document.addEventListener('keydown', onImportMenuKey, true);
  }

  function buildImportMenuItem(label, onClick) {
    const item = document.createElement('button');
    item.type = 'button';
    Object.assign(item.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '8px',
      width: '100%',
      padding: '8px 10px',
      border: '0',
      borderRadius: '6px',
      background: 'transparent',
      color: 'var(--token-text-primary, currentColor)',
      cursor: 'pointer',
      fontSize: '12.5px',
      fontWeight: '500',
      textAlign: 'left',
      transition: 'background 140ms ease',
    });
    item.textContent = label;
    item.addEventListener('mouseenter', () => { item.style.background = 'rgba(255,255,255,0.06)'; });
    item.addEventListener('mouseleave', () => { item.style.background = 'transparent'; });
    item.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      onClick();
    });
    return item;
  }

  // 从 thread id 反查它在 codex 侧栏所在项目 row 上的 cwd。
  // 任何一步失败就返回 ''(后端会保留 rollout 里的原始 cwd)。
  function cwdForThreadId(threadId) {
    if (!threadId) return '';
    const row = document.querySelector(
      `[data-app-action-sidebar-thread-id$=":${threadId}"], [data-app-action-sidebar-thread-id="${threadId}"]`,
    );
    if (!row) return '';
    const projectRow = row.closest('[data-app-action-sidebar-project-row]');
    if (!projectRow) {
      // codex 不一定把 thread row 嵌在 project row 里, 可能用 list 同级。退而求其次找祖先项目 list:
      const projectList = row.closest('[data-app-action-sidebar-project-list-id]');
      if (projectList) {
        return projectList.getAttribute('data-app-action-sidebar-project-list-id') || '';
      }
      return '';
    }
    return projectRow.getAttribute('data-app-action-sidebar-project-id') || '';
  }

  async function runImportFile(targetCwd) {
    const busyToken = showBusyIndicator(S('shimControlImportBusyFile', 'Importing conversation…'));
    try {
      const res = await window.shim('/session/import', targetCwd ? { targetCwd } : {});
      if (!res || res.code !== 0) {
        showToast(`${S('shimControlImportFailed', 'Import failed')}: ${res?.message || ''}`, 'error');
        return;
      }
      const data = res.data || {};
      if (data.cancelled) return;
      if (data.reason === 'empty-file') {
        showToast(S('shimControlImportBadFile', 'File is invalid or empty'), 'warning');
        return;
      }
      if (!data.ok) {
        showToast(`${S('shimControlImportFailed', 'Import failed')}: ${data.message || data.reason || ''}`, 'error');
        return;
      }
      showToast(`${S('shimControlImportDone', 'Import succeeded')} · ${data.title || ''}`.trim(), 'success');
    } catch (err) {
      showToast(`${S('shimControlImportFailed', 'Import failed')}: ${err?.message || err}`, 'error');
    } finally {
      hideBusyIndicator(busyToken);
    }
  }

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

  // 控制面板调用版的 export, 直接给 id, 不依赖 sidebar DOM row
  async function exportThreadById(id, format) {
    if (!id) {
      showToast(S('deleteSessionIdMissing', 'Session id not found'), 'error');
      return;
    }
    const busyToken = showBusyIndicator(exportBusyLabel(format));
    try {
      const res = await window.shim('/session/export', { id, format });
      if (res?.code !== 0) {
        showToast(`${S('threadExportFailed', 'Export failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
        return;
      }
      if (res.data?.cancelled) return;
      showToast(S('threadExportedToast', 'Exported'), 'success');
    } catch (err) {
      showToast(`${S('threadExportFailed', 'Export failed')}: ${err?.message || err}`, 'error');
    } finally {
      hideBusyIndicator(busyToken);
    }
  }

  function exportBusyLabel(format) {
    if (format === 'markdown') return S('exportBusyMarkdown', 'Exporting Markdown…');
    if (format === 'raws') return S('exportBusyRaws', 'Exporting raw data…');
    if (format === 'html') return S('exportBusyHtml', 'Exporting HTML…');
    return S('exportBusyMarkdown', 'Exporting Markdown…');
  }

  // 控制面板调用版的 delete, 走确认弹窗, 成功后让用户重新选择 (清掉 currentThread)
  async function deleteThreadFromControlPanel(id, title) {
    if (!id) {
      showToast(S('deleteSessionIdMissing', 'Session id not found'), 'error');
      return;
    }
    const ok = await showDeleteConfirm(title || S('deleteDefaultTitle', 'this thread'));
    if (!ok) return;
    try {
      const res = await window.shim('/session/delete', { id });
      if (res?.code !== 0) {
        showToast(`${S('deleteFailed', 'Delete failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
        return;
      }
      // 同步: codex 侧栏 row 也手动移除, 让 UI 立刻反应
      const row = document.querySelector(`[data-app-action-sidebar-thread-id$=":${id}"], [data-app-action-sidebar-thread-id="${id}"]`);
      const container = row && (row.closest('[role="listitem"]') || row.closest('.after\\:block') || row);
      container?.remove();
      // 删除后控制面板 snapshot 里 currentThread 还指着这条, 重拉一次
      const panel = document.getElementById(POPOVER_ID);
      if (panel) {
        const snapshot = await loadControlPanelSnapshot();
        shimControlPanelSnapshot = snapshot;
        if (document.body.contains(panel) && shimControlActiveTab === 'overview') {
          const body = panel.querySelector('[data-shim-control-body]');
          if (body) renderControlPanelSnapshot(body, snapshot);
        }
      }
      showToast(S('deleteSuccess', 'Deleted'), 'success');
    } catch (err) {
      showToast(`${S('deleteFailed', 'Delete failed')}: ${err?.message || err}`, 'error');
    }
  }

  function buildCopyIdButton(currentId) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.setAttribute('aria-label', S('shimControlCopyThreadId', 'Copy ID'));
    btn.setAttribute('title', S('shimControlCopyThreadId', 'Copy ID'));
    btn.innerHTML = '<svg width="13" height="13" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="5" y="5" width="8" height="9" rx="1.4" stroke="currentColor" stroke-width="1.3"/><path d="M11 5V3.4a1.4 1.4 0 0 0-1.4-1.4H4.4A1.4 1.4 0 0 0 3 3.4v6.2A1.4 1.4 0 0 0 4.4 11H5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';
    Object.assign(btn.style, {
      flex: '0 0 auto',
      width: '22px',
      height: '22px',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: '0',
      borderRadius: '5px',
      background: 'transparent',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.5))',
      cursor: 'pointer',
      transition: 'background 140ms ease, color 140ms ease',
    });
    btn.addEventListener('mouseenter', () => {
      btn.style.background = 'rgba(255,255,255,0.06)';
      btn.style.color = 'var(--token-text-primary, #f8fafc)';
    });
    btn.addEventListener('mouseleave', () => {
      btn.style.background = 'transparent';
      btn.style.color = 'var(--token-text-secondary, rgba(255,255,255,0.5))';
    });
    btn.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      copyTextToClipboard(currentId, S('shimControlThreadIdCopied', 'Thread ID copied'));
    });
    return btn;
  }

  function buildRelationText(text) {
    const node = document.createElement('span');
    node.textContent = text || '';
    node.title = text || '';
    Object.assign(node.style, {
      minWidth: '0',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
      color: 'var(--token-text-primary, currentColor)',
      fontSize: '13px',
      fontWeight: '500',
    });
    return node;
  }

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

  function positionPopover(popover, anchor) {
    const popRect = popover.getBoundingClientRect();
    const left = Math.max(20, Math.round((window.innerWidth - popRect.width) / 2));
    const top = Math.max(24, Math.round((window.innerHeight - popRect.height) / 2));
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

  // ========== 持久 Busy 指示器 (导出等长耗时任务用) ==========
  //
  // toast 3 秒自动消失, 不适合表示"正在进行中"。这个 indicator 显式 show/hide,
  // 同时支持多个并发任务 (返回的 token 各自 hide, 全部 hide 后 indicator 才消失)。
  //
  // 视觉要求: 必须"显眼"。所以做了几件事:
  //  - 全屏轻 dim 蒙层 (pointer-events:none, 不挡操作但视觉聚焦)
  //  - 顶部居中大胶囊, 24px spinner + 14px 文本, 蓝色 ambient 光晕
  //  - 卡片底部一条 indeterminate 进度条持续流动 (跟 spinner 双重确认 "在动")
  //  - scale 弹入动效, 让出现有重量感

  const BUSY_CONTAINER_ID = '__shim_busy_container__';
  const BUSY_DIM_ID = '__shim_busy_dim__';
  const BUSY_KEYFRAMES_ID = '__shim_busy_kf__';
  const __shimBusyTasks = new Map(); // token -> { node }
  let __shimBusyNextToken = 1;

  function ensureBusyContainer() {
    if (!document.getElementById(BUSY_KEYFRAMES_ID)) {
      const style = document.createElement('style');
      style.id = BUSY_KEYFRAMES_ID;
      style.textContent = [
        '@keyframes shimBusySpin{to{transform:rotate(360deg)}}',
        '@keyframes shimBusyPulse{0%,100%{box-shadow:0 12px 36px rgba(0,0,0,0.45),0 0 0 1px rgba(96,165,250,0.32),0 0 28px rgba(96,165,250,0.30)}50%{box-shadow:0 12px 36px rgba(0,0,0,0.45),0 0 0 1px rgba(96,165,250,0.48),0 0 44px rgba(96,165,250,0.55)}}',
        '@keyframes shimBusyBarSlide{0%{transform:translateX(-100%)}100%{transform:translateX(220%)}}',
        '@keyframes shimBusyPop{0%{opacity:0;transform:translateY(-10px) scale(0.94)}60%{opacity:1;transform:translateY(0) scale(1.02)}100%{opacity:1;transform:translateY(0) scale(1)}}',
      ].join('\n');
      document.head.appendChild(style);
    }
    let container = document.getElementById(BUSY_CONTAINER_ID);
    if (container) return container;
    container = document.createElement('div');
    container.id = BUSY_CONTAINER_ID;
    Object.assign(container.style, {
      position: 'fixed',
      top: '24px',
      left: '50%',
      transform: 'translateX(-50%)',
      zIndex: '2147483647',
      display: 'flex',
      flexDirection: 'column',
      gap: '10px',
      pointerEvents: 'none',
    });
    document.body.appendChild(container);
    return container;
  }

  function ensureBusyDim() {
    let dim = document.getElementById(BUSY_DIM_ID);
    if (dim) return dim;
    dim = document.createElement('div');
    dim.id = BUSY_DIM_ID;
    Object.assign(dim.style, {
      position: 'fixed',
      inset: '0',
      zIndex: '2147483646', // 比 indicator 低 1
      background: 'radial-gradient(circle at 50% 0%, rgba(0,0,0,0.34) 0%, rgba(0,0,0,0.18) 50%, rgba(0,0,0,0) 100%)',
      pointerEvents: 'none', // 不挡操作
      opacity: '0',
      transition: 'opacity 0.22s ease',
    });
    document.body.appendChild(dim);
    requestAnimationFrame(() => { dim.style.opacity = '1'; });
    return dim;
  }

  function removeBusyDimIfIdle() {
    if (__shimBusyTasks.size > 0) return;
    const dim = document.getElementById(BUSY_DIM_ID);
    if (!dim) return;
    dim.style.opacity = '0';
    setTimeout(() => {
      if (__shimBusyTasks.size === 0) dim.remove();
    }, 220);
  }

  function showBusyIndicator(label) {
    const container = ensureBusyContainer();
    ensureBusyDim();
    const node = document.createElement('div');
    Object.assign(node.style, {
      position: 'relative',
      display: 'inline-flex',
      alignItems: 'center',
      gap: '14px',
      minWidth: '260px',
      maxWidth: '480px',
      padding: '14px 22px 16px',
      borderRadius: '14px',
      background: 'linear-gradient(180deg, rgba(28,28,32,0.96), rgba(20,20,24,0.96))',
      border: '1px solid rgba(96,165,250,0.30)',
      color: '#f8fafc',
      fontSize: '14px',
      fontWeight: '600',
      letterSpacing: '0.2px',
      pointerEvents: 'auto',
      overflow: 'hidden',
      animation: 'shimBusyPop 260ms cubic-bezier(0.2,0.9,0.3,1.2) both, shimBusyPulse 2.2s ease-in-out 260ms infinite',
      backdropFilter: 'blur(10px)',
      WebkitBackdropFilter: 'blur(10px)',
    });

    const spinner = document.createElement('span');
    Object.assign(spinner.style, {
      width: '24px',
      height: '24px',
      borderRadius: '999px',
      border: '2.5px solid rgba(255,255,255,0.12)',
      borderTopColor: '#60a5fa',
      borderRightColor: 'rgba(96,165,250,0.55)',
      animation: 'shimBusySpin 0.8s linear infinite',
      flex: '0 0 auto',
      boxShadow: '0 0 12px rgba(96,165,250,0.4)',
    });

    const text = document.createElement('span');
    text.textContent = label || '';
    Object.assign(text.style, {
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      flex: '1 1 auto',
      minWidth: '0',
    });

    // 卡片底部一条 indeterminate 进度条
    const progressTrack = document.createElement('span');
    Object.assign(progressTrack.style, {
      position: 'absolute',
      left: '0',
      right: '0',
      bottom: '0',
      height: '3px',
      background: 'rgba(255,255,255,0.05)',
      overflow: 'hidden',
    });
    const progressBar = document.createElement('span');
    Object.assign(progressBar.style, {
      position: 'absolute',
      top: '0',
      left: '0',
      width: '45%',
      height: '100%',
      background: 'linear-gradient(90deg, rgba(96,165,250,0), rgba(96,165,250,0.9), rgba(96,165,250,0))',
      animation: 'shimBusyBarSlide 1.5s linear infinite',
    });
    progressTrack.appendChild(progressBar);

    node.appendChild(spinner);
    node.appendChild(text);
    node.appendChild(progressTrack);
    container.appendChild(node);

    const token = __shimBusyNextToken++;
    __shimBusyTasks.set(token, { node });
    return token;
  }

  function hideBusyIndicator(token) {
    const task = __shimBusyTasks.get(token);
    if (!task) return;
    __shimBusyTasks.delete(token);
    task.node.style.transition = 'opacity 0.2s, transform 0.2s';
    task.node.style.opacity = '0';
    task.node.style.transform = 'translateY(-8px) scale(0.96)';
    setTimeout(() => {
      task.node.remove();
      removeBusyDimIfIdle();
    }, 220);
  }

  /// 包一段可能抛错的异步任务, 自动 show/hide indicator, 异常会再抛出。
  async function withBusyIndicator(label, run) {
    const token = showBusyIndicator(label);
    try {
      return await run();
    } finally {
      hideBusyIndicator(token);
    }
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
    const busyToken = showBusyIndicator(exportBusyLabel(format));
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
    } finally {
      hideBusyIndicator(busyToken);
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
      chip.style.background = 'rgba(59, 130, 246, 0.16)';
      chip.style.color = '#93c5fd';
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
      background: '#60a5fa',
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

  // ========== 当前对话预览:左侧消息 minimap ==========

  const THREAD_PREVIEW_ITEM_ATTR = 'data-shim-thread-preview-key';
  const THREAD_PREVIEW_ACTIVE_ATTR = 'data-shim-thread-preview-active';
  const THREAD_PREVIEW_HIGHLIGHT_ATTR = 'data-shim-thread-preview-highlight';
  const shimThreadPreviewState = {
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
      '[' + THREAD_PREVIEW_HIGHLIGHT_ATTR + ']',
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
    document.getElementById(THREAD_PREVIEW_LENS_ID)?.remove();
  }

  function showThreadPreviewLens(anchor, item) {
    hideThreadPreviewLens();
    const rect = anchor.getBoundingClientRect();
    const meta = rolePreviewMeta(item.role);
    const lens = document.createElement('div');
    lens.id = THREAD_PREVIEW_LENS_ID;
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

  function buildThreadPreviewItem(item) {
    const button = document.createElement('button');
    button.type = 'button';
    button.setAttribute(THREAD_PREVIEW_ITEM_ATTR, item.key);
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
      if (button.getAttribute(THREAD_PREVIEW_ACTIVE_ATTR) !== '1') {
        button.style.background = 'rgba(255,255,255,0.075)';
        button.style.opacity = '1';
        button.style.transform = 'translateX(2px)';
      }
      showThreadPreviewLens(button, item);
    });
    button.addEventListener('mouseleave', () => {
      const active = button.getAttribute(THREAD_PREVIEW_ACTIVE_ATTR) === '1';
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

  function activePreviewLabelColor(role) {
    return rolePreviewMeta(role).color || 'var(--token-text-primary, currentColor)';
  }

  function buildThreadPreviewPanel(items) {
    const panel = document.createElement('div');
    panel.id = THREAD_PREVIEW_ID;
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
    target.setAttribute(THREAD_PREVIEW_HIGHLIGHT_ATTR, '1');
    const previousOutline = target.style.outline;
    const previousOutlineOffset = target.style.outlineOffset;
    target.style.outline = '2px solid var(--token-text-secondary, currentColor)';
    target.style.outlineOffset = '4px';
    clearTimeout(shimThreadPreviewState.jumpTimer);
    shimThreadPreviewState.jumpTimer = setTimeout(() => {
      target.style.outline = previousOutline;
      target.style.outlineOffset = previousOutlineOffset;
      target.removeAttribute(THREAD_PREVIEW_HIGHLIGHT_ATTR);
    }, 900);
  }

  function updateThreadPreviewActive() {
    const panel = document.getElementById(THREAD_PREVIEW_ID);
    if (!panel || panel.style.display === 'none') return;
    const turns = visibleTurns();
    if (!turns.length) return;
    const scrollTarget = shimThreadPreviewState.scrollTarget || findScrollTarget(turns[0]);
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

    const buttons = panel.querySelectorAll('[' + THREAD_PREVIEW_ITEM_ATTR + ']');
    for (const button of buttons) {
      const active = button.getAttribute(THREAD_PREVIEW_ITEM_ATTR) === activeKey;
      button.setAttribute(THREAD_PREVIEW_ACTIVE_ATTR, active ? '1' : '0');
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
    if (shimThreadPreviewState.activeFrame) return;
    shimThreadPreviewState.activeFrame = requestAnimationFrame(() => {
      shimThreadPreviewState.activeFrame = 0;
      updateThreadPreviewActive();
    });
  }

  function attachThreadPreviewScrollSync(scrollTarget) {
    if (shimThreadPreviewState.scrollTarget === scrollTarget && shimThreadPreviewState.scrollHandler) {
      return;
    }
    if (shimThreadPreviewState.scrollTarget && shimThreadPreviewState.scrollHandler) {
      shimThreadPreviewState.scrollTarget.removeEventListener?.('scroll', shimThreadPreviewState.scrollHandler);
    }
    shimThreadPreviewState.scrollTarget = scrollTarget;
    shimThreadPreviewState.scrollHandler = scheduleThreadPreviewActiveUpdate;
    scrollTarget.addEventListener?.('scroll', shimThreadPreviewState.scrollHandler, { passive: true });
    if (!shimThreadPreviewState.resizeInstalled) {
      shimThreadPreviewState.resizeInstalled = true;
      window.addEventListener('resize', () => runEnsureAll('thread-preview-resize'), { passive: true });
      window.addEventListener('scroll', scheduleThreadPreviewActiveUpdate, { passive: true });
    }
  }

  function removeThreadPreview() {
    document.getElementById(THREAD_PREVIEW_ID)?.remove();
    hideThreadPreviewLens();
    shimThreadPreviewState.signature = '';
    if (shimThreadPreviewState.scrollTarget && shimThreadPreviewState.scrollHandler) {
      shimThreadPreviewState.scrollTarget.removeEventListener?.('scroll', shimThreadPreviewState.scrollHandler);
    }
    shimThreadPreviewState.scrollTarget = null;
    shimThreadPreviewState.scrollHandler = null;
  }

  function ensureThreadPreview() {
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
    let panel = document.getElementById(THREAD_PREVIEW_ID);
    if (!panel || shimThreadPreviewState.signature !== signature) {
      panel?.remove();
      panel = buildThreadPreviewPanel(items);
      document.body.appendChild(panel);
      shimThreadPreviewState.signature = signature;
    }
    const visible = positionThreadPreview(panel, turns, scrollTarget);
    attachThreadPreviewScrollSync(scrollTarget);
    if (visible) scheduleThreadPreviewActiveUpdate();
  }


  // ========== Codex 插件运行时兼容 ==========

  const shimRuntimePlugins = (() => {
    const version = 'shim-runtime-plugin-layer-v1';
    const arrayGuardVersion = 'shim-runtime-array-visibility-v1';
    const clientBridgeVersion = 'shim-runtime-client-bridge-v1';
    const scanFlag = 'data-shim-plugin-ready';
    const installFlag = 'data-shim-install-ready';
    const logPrefix = '[ShimPlugin]';
    // codex 老版本: nav[role="navigation"] button.h-token-nav-row.w-full
    // codex 新版本: 去掉了 nav 包裹,行高换成 Tailwind 任意值 h-[var(--height-token-row)],
    //              按钮在 div.flex.flex-col.gap-px 里。两种都接受,避免改一边漏一边。
    const navSelector = [
      'nav[role="navigation"] button.h-token-nav-row.w-full',
      'div.flex.flex-col.gap-px > button.w-full[class*="h-[var(--height-token-row)]"]',
    ].join(', ');
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
      // navSelector 现在是逗号分隔的多签名,直接拼字符串会把后缀只作用到最后一段。
      // 这里给每段都补上 svg path 后缀,等价于 (A svg path), (B svg path)。
      const iconSelector = navSelector
        .split(',')
        .map((sel) => sel.trim() + ' svg path[d^="' + pluginIconPathPrefix + '"]')
        .join(', ');
      const byIcon = document.querySelector(iconSelector)?.closest('button');
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
      threadPreview: document.querySelectorAll('#' + THREAD_PREVIEW_ID).length,
      delBtns: document.querySelectorAll('[data-shim-delete-added="1"]').length,
    };
  }

  // ========== Claude 桥:在 codex 侧栏 nav 列表里加一个折叠按钮 ==========
  // 点击展开 → 列出 ~/.claude/projects/ 下所有项目分组,每个项目下又能再折叠列出会话。
  // 点会话目前先 toast(接续逻辑等 codex 写入面调查报告出来再做)。
  const NAV_BTN_ID = '__shim_claude_bridge_nav__';
  const NAV_PANEL_ID = '__shim_claude_bridge_panel__';

  // 找到 codex 自带 nav 按钮所在的列表容器(包含"新对话/搜索"按钮的 .flex.flex-col.gap-px)。
  // 我们把"Claude 桥"按钮追加到该容器末尾,折叠面板紧跟其后。
  //
  // 历史: codex 之前给行用 .h-token-nav-row,后来换成 Tailwind 任意值
  // .h-[var(--height-token-row)],并去掉了外层 nav[role="navigation"]。
  // 这里两个签名都接受,先用旧的找,找不到再退到新的;最后兜底用 gap-px 容器里
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
        applyClaudeBridgeStateForThread(codexThreadId, res.data || { bound: false });
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

  // ========== Claude 桥:composer 旁的绑定状态 chip(按 codex thread 维度) ==========
  // 每个 codex 侧栏对话各自有自己的 Claude 桥状态。dart 侧按 thread id 存。
  // - 进 thread / 切 thread → 拉这个 thread 的状态,刷新 chip
  // - 点会话 row → /claude-bridge/bind { codexThreadId } → 当前 thread 绑上
  // - 点 chip × → /claude-bridge/unbind { codexThreadId } → 只解绑当前 thread
  const CLAUDE_BRIDGE_CHIP_ID = '__shim_claude_bridge_chip__';
  // 本地缓存:每个 thread 最近一次拉到的状态,避免 ensure 频繁打 bridge。
  // key = codexThreadId,value = { bound, sessionId?, title?, jsonlPath? }
  const shimClaudeBridgeStateCache = new Map();
  // 正在拉取的 thread 集合,去重并发
  const shimClaudeBridgeFetching = new Set();
  // 上次 chip 渲染基于的 thread,变化就强制重建
  let shimClaudeBridgeLastRenderedThreadId = null;

  /// 找当前 codex 侧栏 active 那条 thread。
  /// 没 active(比如刚开新对话还没创建 thread)时返回 null。
  function currentCodexThreadId() {
    const active = document.querySelector('[data-app-action-sidebar-thread-active="true"]');
    if (!active) return null;
    const raw = active.getAttribute('data-app-action-sidebar-thread-id') || '';
    // 形如 "local:019ef84a-..." → 取冒号后半段
    return raw.includes(':') ? raw.split(':').slice(1).join(':') : raw;
  }

  function applyClaudeBridgeStateForThread(threadId, state) {
    if (!threadId) return;
    shimClaudeBridgeStateCache.set(threadId, state || { bound: false });
  }

  function fetchClaudeBridgeStateForThread(threadId) {
    if (!threadId) return Promise.resolve();
    if (typeof window.shim !== 'function') return Promise.resolve();
    if (shimClaudeBridgeFetching.has(threadId)) return Promise.resolve();
    shimClaudeBridgeFetching.add(threadId);
    return window.shim('/claude-bridge/state', { codexThreadId: threadId }).then((res) => {
      if (res && res.code === 0 && res.data) {
        applyClaudeBridgeStateForThread(threadId, res.data);
        // 拉的就是当前显示的 thread → 刷 chip
        if (threadId === currentCodexThreadId()) {
          ensureClaudeBridgeChip();
        }
      }
    }).catch(() => {}).finally(() => {
      shimClaudeBridgeFetching.delete(threadId);
    });
  }

  function ensureClaudeBridgeChip() {
    const threadId = currentCodexThreadId();
    if (!threadId) {
      // 没活跃 thread → chip 不显示
      document.getElementById(CLAUDE_BRIDGE_CHIP_ID)?.remove();
      shimClaudeBridgeLastRenderedThreadId = null;
      return;
    }
    // 没缓存就先拉一次,拉到回调里再 ensure
    if (!shimClaudeBridgeStateCache.has(threadId)) {
      fetchClaudeBridgeStateForThread(threadId);
      // 切到新 thread 时立刻移除老 chip,避免显示前一个 thread 的标题
      if (shimClaudeBridgeLastRenderedThreadId !== threadId) {
        document.getElementById(CLAUDE_BRIDGE_CHIP_ID)?.remove();
        shimClaudeBridgeLastRenderedThreadId = threadId;
      }
      return;
    }
    const state = shimClaudeBridgeStateCache.get(threadId);
    const existing = document.getElementById(CLAUDE_BRIDGE_CHIP_ID);
    if (!state || !state.bound) {
      existing?.remove();
      shimClaudeBridgeLastRenderedThreadId = threadId;
      return;
    }
    const anchor = findProviderPickerAnchor();
    if (!anchor) return;
    // 同 thread + 已挂 → 只更标题文字
    if (existing
        && existing.parentElement === anchor.group
        && shimClaudeBridgeLastRenderedThreadId === threadId) {
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
    const pickerBtn = document.getElementById(PROVIDER_PICKER_ID);
    if (pickerBtn && pickerBtn.parentElement === anchor.group) {
      anchor.group.insertBefore(chip, pickerBtn);
    } else {
      anchor.group.insertBefore(chip, anchor.button);
    }
    shimClaudeBridgeLastRenderedThreadId = threadId;
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
      color: '#93c5fd',
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
          applyClaudeBridgeStateForThread(threadId, res.data || { bound: false });
        } else {
          applyClaudeBridgeStateForThread(threadId, { bound: false });
        }
      } catch (_) {
        applyClaudeBridgeStateForThread(threadId, { bound: false });
      }
      ensureClaudeBridgeChip();
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
    removeInjectedBadge();
    const t1 = performance.now();
    ensureClaudeBridge();
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
    ensureThreadPreview();
    const t7 = performance.now();
    ensureCodexPluginFeatures();
    const t8 = performance.now();
    ensureClaudeBridgeChip();
    const t9 = performance.now();

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
        threadPreview: +(t7 - t6).toFixed(1),
        plugin: +(t8 - t7).toFixed(1),
        claudeBridge: +(t9 - t8).toFixed(1),
        total: +(t9 - t0).toFixed(1),
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
    '#' + THREAD_PREVIEW_ID,
    '#' + THREAD_PREVIEW_LENS_ID,
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
    // codex 新版 sidebar 没有 nav[role=navigation] 外壳了, 用 button 行高的 Tailwind
    // 任意值类做兜底, 否则 sidebar 重新挂载时观察者不会触发, Shim 入口和 Claude 桥都重新注入失败。
    'button[class*="h-[var(--height-token-row)]"]',
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

  // ========== Codex 项目级 radix 菜单 hook: 注入"导出为 zip"项 ==========
  //
  // Codex 项目折叠头右侧的"⋯"按钮打开一个 radix dropdown ([data-radix-menu-content]),
  // 默认有"置顶项目/在资源管理器中打开/重命名项目/归档对话/移除"等项。我们在
  // 第一项前面 prepend 一个"导出为"项, hover 弹出 markdown/raw/html ·zip 三个子项。
  //
  // 之所以走 MutationObserver: codex 用 portal 把菜单挂到 body 末尾, 每次开关都重建,
  // 没法一次性挂 listener。我们监听菜单出现, 然后基于 aria-labelledby 反查 trigger 找 cwd。
  installCodexProjectMenuHook();

  function installCodexProjectMenuHook() {
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
    // 箭头朝下 + 横线: 表示 "导入到本项目"
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

  // 项目菜单第一项: "导出为" + 右箭头, hover 弹子菜单(我们自己的浮层, 不嵌套 radix)
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
        // 子菜单要求自己关闭(点完了之类)
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
        // 关闭父 radix 菜单: 找一个空白点击模拟一下(radix 自己有 outside-click 监听)
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

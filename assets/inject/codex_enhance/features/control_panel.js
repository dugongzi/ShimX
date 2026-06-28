// ==Shim==
// @name        Shim codex_enhance — features/control_panel
// @description Shim 控制面板 (侧栏 Shim 入口点开后弹出的浮层): tab 切换的 chrome、
//              Data overview (provider / bridge / auto-switch / claude binding) 视图、
//              Logs 视图、当前对话操作菜单 (导出 / 导入 / 解绑 / 删除)。
//              对外: togglePopover(anchor), refreshOpen() — shim_menu / control_panel 自己刷新用,
//              loadSnapshot — 让外部触发拉数据 (内部还是用 callShimRoute 兜底)。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const __ns = window.__shimCodex;
  const ids = __ns.ids;
  const __i18n = __ns.i18n;
  const S = __i18n.S;

  // ui 工具 alias
  const showToast = (msg, kind) => __ns.ui.toast.show(msg, kind);
  const showBusyIndicator = (label) => __ns.ui.busy.show(label);
  const hideBusyIndicator = (token) => __ns.ui.busy.hide(token);
  const showDeleteConfirm = (title) => __ns.ui.confirm.showDelete(title);
  const statusToneColor = (tone) => __ns.ui.panel.statusToneColor(tone);
  const statusToneSoftBackground = (tone) => __ns.ui.panel.statusToneSoftBackground(tone);
  const statusToneBorder = (tone) => __ns.ui.panel.statusToneBorder(tone);
  const statusToneLabel = (tone) => __ns.ui.panel.statusToneLabel(tone);
  const currentCodexThreadLabel = () => __ns.ui.panel.currentCodexThreadLabel();
  const codexThreadLabelById = (id) => __ns.ui.panel.codexThreadLabelById(id);
  const shortThreadId = (id) => __ns.ui.panel.shortThreadId(id);

  // features 间调用
  const currentCodexThreadId = () => __ns.features.claudeBridge.currentCodexThreadId();
  const applyClaudeBridgeStateForThread = (id, state) =>
    __ns.features.claudeBridge.applyStateForThread(id, state);
  const refreshProviderPickerState = (opts) => __i18n.refreshProviderPickerState(opts);

  // trace (runtime 未就绪时可选链兜底)
  const __t = (tag, data) => __ns.runtime?.trace?.t?.(tag, data);

  // DOM id 常量 (沿用原名, 值改成从 ids 取)
  const POPOVER_ID = ids.popover;
  const MENU_ITEM_ID = ids.menuItem;

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
      id: __ns.features.claudeBridge.currentCodexThreadId() || '',
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
        __ns.features.claudeBridge.applyStateForThread(codexThreadId, {
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
    // 同步给侧栏 chip (如果当前 codex thread 就是被解绑的 thread, chip 也要变回未绑定)
    try {
      __ns.features.claudeBridge.applyStateForThread(codexThreadId, res.data || { bound: false });
    } catch (_) {}
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

  __ns.features.controlPanel = {
    togglePopover,
    refreshOpen: refreshOpenControlPanel,
    loadSnapshot: loadControlPanelSnapshot,
  };
})();

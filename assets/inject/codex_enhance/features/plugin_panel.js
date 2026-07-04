// ==Shim==
// @name        Shim codex_enhance — features/plugin_panel
// @description 侧栏「插件」入口点击后的浮层。目前只是骨架 + 两个动作按钮 + 状态占位,
//              点击按钮弹 toast 占位;后端 bridge 路由接好后,这里再改成真实调用。
//              对外: togglePopover(anchor) — plugin_menu 点击时调。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;
  const S = (k, f) => ns.i18n.S(k, f);

  const PANEL_ID = ids.pluginPanel;
  const MENU_ID = ids.pluginMenuItem;

  function toast(msg, kind) {
    ns.ui?.toast?.show?.(msg, kind || 'info');
  }

  function buildHeader(panel) {
    const header = document.createElement('div');
    Object.assign(header.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      padding: '14px 18px 12px',
      borderBottom: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      flex: '0 0 auto',
    });

    const iconWrap = document.createElement('span');
    Object.assign(iconWrap.style, {
      display: 'inline-flex',
      width: '20px',
      height: '20px',
    });
    iconWrap.innerHTML = ids.pluginIconSvg;

    const title = document.createElement('div');
    title.textContent = S('pluginPanelTitle', 'Unlock plugins');
    Object.assign(title.style, {
      flex: '1 1 auto',
      fontSize: '14px',
      fontWeight: '700',
      color: 'var(--token-foreground, #f8fafc)',
    });

    const closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.setAttribute('aria-label', S('pluginPanelClose', 'Close'));
    closeBtn.innerHTML =
      '<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M4 4L12 12M12 4L4 12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>';
    Object.assign(closeBtn.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '26px',
      height: '26px',
      borderRadius: '6px',
      border: '0',
      background: 'transparent',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.7))',
      cursor: 'pointer',
    });
    closeBtn.addEventListener('mouseenter', () => {
      closeBtn.style.background = 'rgba(255,255,255,0.08)';
    });
    closeBtn.addEventListener('mouseleave', () => {
      closeBtn.style.background = 'transparent';
    });
    closeBtn.addEventListener('click', () => dismissPopover());

    header.appendChild(iconWrap);
    header.appendChild(title);
    header.appendChild(closeBtn);
    panel.appendChild(header);
  }

  // 状态行的 dot / value / count 元素 refresh 时会更新,所以挂在 panel dataset 上
  // 免得 refresh 每次都走 querySelector。
  function buildStatusRow(panel) {
    const row = document.createElement('div');
    Object.assign(row.style, {
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      padding: '10px 18px',
      borderBottom: '1px solid var(--token-border, rgba(255,255,255,0.06))',
      background: 'rgba(255,255,255,0.02)',
      flex: '0 0 auto',
    });

    const label = document.createElement('span');
    label.textContent = S('pluginPanelStatusLabel', 'Status');
    Object.assign(label.style, {
      fontSize: '12px',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.6))',
      fontWeight: '600',
      letterSpacing: '0.3px',
    });

    const dot = document.createElement('span');
    dot.setAttribute('data-shim-plugin-dot', '1');
    Object.assign(dot.style, {
      display: 'inline-block',
      width: '8px',
      height: '8px',
      borderRadius: '50%',
      background: '#9ca3af',
      flex: '0 0 auto',
    });

    const value = document.createElement('span');
    value.setAttribute('data-shim-plugin-status', '1');
    value.textContent = S('pluginPanelStatusIdle', 'Not installed');
    Object.assign(value.style, {
      fontSize: '13px',
      color: 'var(--token-foreground, #f8fafc)',
      fontWeight: '500',
    });

    const count = document.createElement('span');
    count.setAttribute('data-shim-plugin-count', '1');
    Object.assign(count.style, {
      marginLeft: 'auto',
      fontSize: '12px',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.6))',
    });

    row.appendChild(label);
    row.appendChild(dot);
    row.appendChild(value);
    row.appendChild(count);
    panel.appendChild(row);
  }

  // 根据 /plugin/status 返回值刷新状态行。
  //   installed=false           → 灰点 + 未启用
  //   installed=true & !configured → 橙点 + 已下载但未配置
  //   installed=true & configured  → 绿点 + 已安装,右侧展示 「插件数 N」
  function refreshStatus(panel, data) {
    const dot = panel.querySelector('[data-shim-plugin-dot="1"]');
    const value = panel.querySelector('[data-shim-plugin-status="1"]');
    const count = panel.querySelector('[data-shim-plugin-count="1"]');
    if (!dot || !value || !count) return;
    if (!data) {
      dot.style.background = '#ef4444';
      value.textContent = S('pluginPanelStatusFailed', 'Failed to read status');
      count.textContent = '';
      return;
    }
    if (data.installed && data.configured) {
      dot.style.background = '#22c55e';
      value.textContent = S('pluginPanelStatusInstalled', 'Installed');
      const n = Number(data.pluginCount) || 0;
      count.textContent = `${S('pluginPanelStatusPluginCount', 'Plugins')}: ${n}`;
    } else if (data.installed) {
      dot.style.background = '#f59e0b';
      value.textContent = S(
        'pluginPanelStatusPartial',
        'Downloaded but config.toml not written',
      );
      count.textContent = '';
    } else {
      dot.style.background = '#9ca3af';
      value.textContent = S('pluginPanelStatusIdle', 'Not installed');
      count.textContent = '';
    }
  }

  async function loadStatus(panel) {
    try {
      const res = await ns.bridge.call('/plugin/status', {}, 5000);
      if (res && res.ok) {
        refreshStatus(panel, res.data);
      } else {
        refreshStatus(panel, null);
      }
    } catch (_) {
      refreshStatus(panel, null);
    }
  }

  function humanBytes(n) {
    if (!Number.isFinite(n) || n <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    let idx = 0;
    let v = n;
    while (v >= 1024 && idx < units.length - 1) {
      v /= 1024;
      idx++;
    }
    return `${v.toFixed(v >= 10 || idx === 0 ? 0 : 1)} ${units[idx]}`;
  }

  async function runInstallFromGithub(panel) {
    if (panel.dataset.shimBusy === '1') return;
    panel.dataset.shimBusy = '1';
    const baseLabel = S(
      'pluginPanelBusyGithub',
      'Downloading and installing from GitHub…',
    );
    const busyToken = ns.ui?.busy?.show?.(baseLabel);

    // 订阅 /plugin/download-progress 主动推送(Dart 侧 dio onReceiveProgress
    // 经 200ms 节流后广播),refresh busy 卡片文案 + 底部进度条。
    let progressSub = null;
    if (typeof window.__shimOn === 'function' && busyToken != null) {
      progressSub = window.__shimOn(
        '/plugin/download-progress',
        (payload) => {
          if (!payload) return;
          const received = Number(payload.received) || 0;
          const total = Number(payload.total) || 0;
          const percent = Number(payload.percent) || 0;
          const detail = total > 0
            ? `${humanBytes(received)} / ${humanBytes(total)} · ${percent}%`
            : humanBytes(received);
          ns.ui?.busy?.update?.(busyToken, {
            label: `${baseLabel} ${detail}`,
            percent: total > 0 ? percent : null,
          });
        },
      );
    }

    try {
      const res = await ns.bridge.call(
        '/plugin/install-from-github',
        {},
        5 * 60 * 1000,
      );
      if (res && res.ok) {
        refreshStatus(panel, res.data);
        toast(
          S('pluginPanelInstallSuccess', 'Installed. Restart codex to take effect.'),
          'success',
        );
      } else {
        toast(
          `${S('pluginPanelInstallFailed', 'Install failed')}: ${(res && res.message) || ''}`,
          'error',
        );
      }
    } catch (e) {
      toast(
        `${S('pluginPanelInstallFailed', 'Install failed')}: ${(e && e.message) || String(e)}`,
        'error',
      );
    } finally {
      try {
        if (progressSub && typeof progressSub.cancel === 'function') {
          progressSub.cancel();
        } else if (typeof progressSub === 'function') {
          progressSub();
        }
      } catch (_) {}
      if (busyToken != null) ns.ui?.busy?.hide?.(busyToken);
      delete panel.dataset.shimBusy;
    }
  }

  function escapeHtml(text) {
    return String(text ?? '').replace(/[&<>"']/g, (c) => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
    }[c]));
  }

  function buildIntro(panel) {
    const intro = document.createElement('div');
    Object.assign(intro.style, {
      padding: '14px 18px 6px',
      fontSize: '13px',
      lineHeight: '1.55',
      color: 'var(--token-foreground, rgba(255,255,255,0.92))',
    });
    const title = escapeHtml(S('pluginPanelIntroTitle', 'Pick a data source'));
    const desc = escapeHtml(
      S(
        'pluginPanelIntroDesc',
        'The official curated plugin set needs a snapshot. Choose how to get it:',
      ),
    );
    intro.innerHTML =
      `<div style="font-weight:600;margin-bottom:6px;">${title}</div>` +
      `<div style="color:var(--token-text-secondary,rgba(255,255,255,0.6));">${desc}</div>`;
    panel.appendChild(intro);
  }

  function buildActionCard(opts) {
    const card = document.createElement('button');
    card.type = 'button';
    Object.assign(card.style, {
      display: 'flex',
      alignItems: 'flex-start',
      gap: '12px',
      width: '100%',
      padding: '14px 16px',
      borderRadius: '10px',
      border: '1px solid var(--token-border, rgba(255,255,255,0.10))',
      background: 'rgba(255,255,255,0.03)',
      color: 'var(--token-foreground, #f8fafc)',
      cursor: 'pointer',
      textAlign: 'left',
      transition: 'background 0.15s, border-color 0.15s',
    });
    card.addEventListener('mouseenter', () => {
      card.style.background = 'rgba(255,255,255,0.06)';
      card.style.borderColor = 'var(--token-border, rgba(255,255,255,0.18))';
    });
    card.addEventListener('mouseleave', () => {
      card.style.background = 'rgba(255,255,255,0.03)';
      card.style.borderColor = 'var(--token-border, rgba(255,255,255,0.10))';
    });

    const iconWrap = document.createElement('span');
    Object.assign(iconWrap.style, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '28px',
      height: '28px',
      borderRadius: '8px',
      background: 'rgba(0, 144, 253, 0.14)',
      color: '#38bdf8',
      flex: '0 0 auto',
      marginTop: '1px',
    });
    iconWrap.innerHTML = opts.icon;

    const textCol = document.createElement('div');
    Object.assign(textCol.style, {
      display: 'flex',
      flexDirection: 'column',
      gap: '3px',
      minWidth: '0',
      flex: '1 1 auto',
    });

    const title = document.createElement('span');
    title.textContent = opts.title;
    Object.assign(title.style, {
      fontSize: '13.5px',
      fontWeight: '600',
    });

    const desc = document.createElement('span');
    desc.textContent = opts.desc;
    Object.assign(desc.style, {
      fontSize: '12px',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.6))',
      lineHeight: '1.5',
    });

    textCol.appendChild(title);
    textCol.appendChild(desc);
    card.appendChild(iconWrap);
    card.appendChild(textCol);

    card.addEventListener('click', () => opts.onClick?.());
    return card;
  }

  function buildActions(panel) {
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      display: 'flex',
      flexDirection: 'column',
      gap: '10px',
      padding: '10px 18px 14px',
      flex: '0 0 auto',
    });

    // GitHub 拉取
    const iconGithub =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 0C3.58 0 0 3.58 0 8a8 8 0 0 0 5.47 7.59c.4.07.55-.17.55-.38v-1.35c-2.23.48-2.7-1.07-2.7-1.07-.36-.92-.89-1.16-.89-1.16-.73-.5.06-.49.06-.49.8.06 1.23.83 1.23.83.72 1.23 1.88.87 2.34.66.07-.52.28-.87.51-1.07-1.78-.2-3.65-.89-3.65-3.96 0-.88.31-1.59.82-2.15-.08-.2-.36-1.01.08-2.11 0 0 .67-.21 2.2.82a7.6 7.6 0 0 1 4 0c1.53-1.03 2.2-.82 2.2-.82.44 1.1.16 1.91.08 2.11.51.56.82 1.27.82 2.15 0 3.08-1.87 3.76-3.66 3.96.29.25.54.73.54 1.48v2.19c0 .21.15.46.55.38A8 8 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>';
    wrap.appendChild(
      buildActionCard({
        icon: iconGithub,
        title: S('pluginPanelActionGithubTitle', 'Fetch from GitHub'),
        desc: S(
          'pluginPanelActionGithubDesc',
          'Download the latest snapshot from openai/plugins (needs access to github.com)',
        ),
        onClick: () => runInstallFromGithub(panel),
      }),
    );

    // 本地 zip
    const iconFolder =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M1.5 3.5A1.5 1.5 0 0 1 3 2h3l1.5 1.5H13a1.5 1.5 0 0 1 1.5 1.5v7A1.5 1.5 0 0 1 13 13.5H3A1.5 1.5 0 0 1 1.5 12V3.5z" stroke="currentColor" stroke-width="1.3" stroke-linejoin="round"/></svg>';
    wrap.appendChild(
      buildActionCard({
        icon: iconFolder,
        title: S('pluginPanelActionLocalTitle', 'Pick a local zip or folder'),
        desc: S(
          'pluginPanelActionLocalDesc',
          'Use this when you already have a snapshot ready — no network required',
        ),
        onClick: () =>
          toast(
            S('pluginPanelLocalNotYet', 'Local import comes from shim main UI (WIP)'),
            'info',
          ),
      }),
    );

    panel.appendChild(wrap);
  }

  function buildFooter(panel) {
    const foot = document.createElement('div');
    Object.assign(foot.style, {
      padding: '10px 18px 14px',
      fontSize: '12px',
      lineHeight: '1.55',
      color: 'var(--token-text-secondary, rgba(255,255,255,0.55))',
      borderTop: '1px solid var(--token-border, rgba(255,255,255,0.06))',
      flex: '0 0 auto',
    });
    // 文案里带一个高亮的 config.toml 片段。用户可翻译的部分做 %CONFIG% 占位,
    // 翻译里必须保留一次 %CONFIG% 才不会丢关键词。
    const raw = S(
      'pluginPanelFooterHint',
      "This writes codex's %CONFIG%. Restart codex for changes to take effect.",
    );
    const badge =
      '<code style="background:rgba(255,255,255,0.06);padding:1px 5px;border-radius:4px;">config.toml</code>';
    const parts = escapeHtml(raw).split('config.toml');
    const body = parts.length === 1 ? escapeHtml(raw) : parts.join(badge);
    foot.innerHTML = `<span style="color:#f59e0b;">ⓘ</span> ${body}`;
    panel.appendChild(foot);
  }

  function buildPanel() {
    const panel = document.createElement('div');
    panel.id = PANEL_ID;
    panel.className =
      'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
    Object.assign(panel.style, {
      position: 'fixed',
      zIndex: '2147483647',
      width: 'min(460px, calc(100vw - 40px))',
      maxHeight: 'calc(100vh - 80px)',
      borderRadius: '14px',
      border: '1px solid var(--token-border, rgba(255,255,255,0.08))',
      background:
        'var(--token-main-surface-primary, var(--token-sidebar-surface-primary, rgba(20,20,22,0.985)))',
      boxShadow: '0 20px 60px rgba(0, 0, 0, 0.44)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      fontSize: '13px',
      lineHeight: '1.5',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden',
    });

    buildHeader(panel);
    buildStatusRow(panel);
    buildIntro(panel);
    buildActions(panel);
    buildFooter(panel);

    return panel;
  }

  function positionPopover(popover, anchor) {
    // 优先靠 anchor 右侧展开 (侧栏挂菜单项右边),空间不够时居中
    const anchorRect = anchor?.getBoundingClientRect?.();
    const popRect = popover.getBoundingClientRect();
    let left;
    let top;
    if (anchorRect) {
      left = Math.round(anchorRect.right + 12);
      top = Math.round(anchorRect.top);
      if (left + popRect.width > window.innerWidth - 16) {
        left = Math.max(16, Math.round((window.innerWidth - popRect.width) / 2));
      }
      if (top + popRect.height > window.innerHeight - 16) {
        top = Math.max(16, window.innerHeight - popRect.height - 16);
      }
    } else {
      left = Math.max(16, Math.round((window.innerWidth - popRect.width) / 2));
      top = Math.max(16, Math.round((window.innerHeight - popRect.height) / 2));
    }
    popover.style.left = `${left}px`;
    popover.style.top = `${top}px`;
  }

  function onPopoverOutside(event) {
    const popover = document.getElementById(PANEL_ID);
    const item = document.getElementById(MENU_ID);
    if (!popover) return;
    if (popover.contains(event.target)) return;
    if (item && item.contains(event.target)) return;
    dismissPopover();
  }

  function onPopoverKey(event) {
    if (event.key === 'Escape') dismissPopover();
  }

  function dismissPopover() {
    document.getElementById(PANEL_ID)?.remove();
    document.removeEventListener('mousedown', onPopoverOutside, true);
    document.removeEventListener('keydown', onPopoverKey, true);
  }

  function togglePopover(anchor) {
    if (document.getElementById(PANEL_ID)) {
      dismissPopover();
      return;
    }
    const panel = buildPanel();
    document.body.appendChild(panel);
    positionPopover(panel, anchor);
    document.addEventListener('mousedown', onPopoverOutside, true);
    document.addEventListener('keydown', onPopoverKey, true);
    // 打开就异步拉一次真实状态。桥没就绪时静默,refreshStatus 会显示灰点未启用。
    loadStatus(panel);
  }

  ns.features.pluginPanel = { togglePopover, dismissPopover };
})();

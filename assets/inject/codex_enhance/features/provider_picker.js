// ==ShimX==
// @name        ShimX codex_enhance — features/provider_picker
// @description Composer 旁的 "供应商:模型" 按钮 + 下拉, 含 auto-switch footer + provider 标签 badge。
//              下拉: 供应商列表 / 模型子列表 / 测速按钮 / 健康 chip / reasoning effort picker /
//              自动切换配置 (策略 / 范围 / 阈值)。
//              ensure() 由 runtime/scheduler 在 ensureAll 里每轮调一次。
//              ensureBadge() 在最新 turn 头部插 "供应商:xxx" 标签。
//              findAnchor() / pickerId / popoverId 给 features/claude_bridge 用 — chip 要插在
//              picker 按钮旁边, 解绑后也要重定位 chip。
// @layer       features
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;
  const ns = window.__shimxCodex;
  const ids = ns.ids;
  const __i18n = ns.i18n;
  const S = __i18n.S;
  const shimxProviderState = __i18n.state;
  const currentProvider = __i18n.currentProvider;
  const refreshCurrentProvider = __i18n.refreshCurrentProvider;
  const refreshProviderPickerState = __i18n.refreshProviderPickerState;
  const scheduleProviderPickerRefresh = __i18n.scheduleProviderPickerRefresh;
  const showToast = (msg, kind) => ns.ui.toast.show(msg, kind);
  const __t = (tag, data) => ns.runtime?.trace?.t?.(tag, data);

  // 本片专用的 DOM id / 选择器常量, 全部从 ids 派生
  const PROVIDER_BADGE_CLASS = ids.providerBadgeClass;
  const PROVIDER_PICKER_ID = ids.providerPicker;
  const PROVIDER_PICKER_POPOVER_ID = ids.providerPickerPopover;
  const SEND_BUTTON_SVG_D_PREFIX = ids.sendButtonSvgD;
  const CODEX_MODEL_SELECTOR_FLAG = ids.codexModelSelectorFlag;

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
        ? '#059669'
        : protocol === 'chat'
          ? '#2563eb'
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
      shimxProviderState.reasoningEffort || 'high',
    ].join('|');
    if (button.getAttribute('data-shimx-render-key') === renderKey) {
      updateCodexModelSelectorVisibility();
      return;
    }
    button.setAttribute('data-shimx-render-key', renderKey);
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

      if (shouldShowShimXReasoningEffort(selectedModel)) {
        const effort = document.createElement('span');
        effort.textContent = reasoningEffortLabel(
          shimxProviderState.reasoningEffort || 'high',
        );
        Object.assign(effort.style, {
          padding: '2px 5px',
          borderRadius: '999px',
          background: 'rgba(59, 130, 246, 0.16)',
          color: '#2563eb',
          fontSize: '11px',
          fontWeight: '700',
          lineHeight: '1.2',
        });
        button.appendChild(effort);
      }

      const clear = document.createElement('span');
      clear.textContent = '×';
      clear.setAttribute('data-shimx-clear-model', '1');
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
    return !!target?.closest?.('[data-shimx-clear-model="1"]');
  }

  function selectedShimXModel() {
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

  function shouldShowShimXReasoningEffort(model) {
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
    const model = selectedShimXModel();
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

  function ensure() {
    if (document.getElementById(PROVIDER_PICKER_ID)) {
      updateProviderPickerButton();
      return;
    }
    const anchor = findProviderPickerAnchor();
    if (!anchor) {
      __t('ensureProviderPicker: anchor missing');
      return;
    }

    __t('ensureProviderPicker: INSERT button');
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

  // picker 打开 → 测速触发的客户端节流 (60s 内不重复打, 后端也有同样的去重兜底)
  let __shimxLastHealthRefreshAt = 0;
  function triggerHealthRefresh() {
    if (typeof window.shimx !== 'function') return;
    const now = Date.now();
    if (now - __shimxLastHealthRefreshAt < 60 * 1000) return;
    __shimxLastHealthRefreshAt = now;
    // 默认 scope = selected, 只测当前选中的家; 用户量大也只多一次中转
    window.shimx('/provider/health/refresh', {}).then(() => {
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
      outline: '0.5px solid var(--token-border, rgba(127,127,127,0.08))',
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
    // 浏览器不允许嵌套 button。click 事件用 capture 阶段拦截, 阻止冒泡到父级 selectProvider。
    const btn = document.createElement('span');
    btn.setAttribute('role', 'button');
    btn.setAttribute('aria-label', S('probeNow', 'Measure latency'));
    btn.setAttribute('title', S('probeNow', 'Measure latency'));
    btn.setAttribute('data-shimx-probe-btn', '1');
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
      if (btn.dataset.shimxProbing !== '1') btn.style.opacity = '0.7';
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
      if (btn.dataset.shimxProbing === '1') return;
      btn.dataset.shimxProbing = '1';
      btn.style.opacity = '1';
      btn.style.transition = 'transform 0.6s linear';
      let angle = 0;
      const spin = setInterval(() => {
        angle = (angle + 60) % 360;
        btn.style.transform = `rotate(${angle}deg)`;
      }, 100);
      try {
        await window.shimx('/provider/health/refresh', {
          id: provider.id,
          force: true,
        });
        // 拉新的 list, 弹层开着时只刷数据不重建按钮 (避免破坏其它点击),
        // 但 health chip 要更新到本行 → 我们手动只更新这一行的 chip
        await refreshProviderPickerState({ rebuildPopover: false });
        const updated = (shimxProviderState.providers || []).find((p) => p.id === provider.id);
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
        btn.dataset.shimxProbing = '0';
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
      chip.style.color = '#b45309';
    } else {
      chip.style.background = 'rgba(59, 130, 246, 0.16)';
      chip.style.color = '#2563eb';
    }
    return chip;
  }

  function renderProviderPickerPopover(popover) {
    const providers = shimxProviderState.providers;
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
        background: provider.id === shimxProviderState.selectedId
          ? 'var(--token-main-surface-secondary, rgba(127,127,127,0.08))'
          : 'transparent',
        color: 'inherit',
        textAlign: 'left',
      });
      providerRow.addEventListener('click', async (event) => {
        // 点的是测速按钮 → 放行 (让按钮自己的 listener 跑)
        if (event.target.closest && event.target.closest('[data-shimx-probe-btn="1"]')) {
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
        fontWeight: provider.id === shimxProviderState.selectedId ? '700' : '500',
      });
      providerRow.appendChild(name);
      providerRow.appendChild(buildProbeButton(provider));
      providerRow.appendChild(buildHealthChip(provider.health));
      fragment.appendChild(providerRow);

      if (provider.id === shimxProviderState.selectedId) {
        const modelList = document.createElement('div');
        Object.assign(modelList.style, {
          margin: '0 0 4px 14px',
          paddingLeft: '10px',
          borderLeft: '1px solid var(--token-border, rgba(127,127,127,0.10))',
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
              ? 'var(--token-main-surface-tertiary, rgba(127,127,127,0.10))'
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
            if (!shouldShowShimXReasoningEffort(modelName)) {
              dismissProviderPickerPopover();
            }
          }, true);
          modelList.appendChild(modelRow);
        }
        if (shouldShowShimXReasoningEffort(provider.selectedModel)) {
          modelList.appendChild(buildReasoningEffortPicker(provider.id));
        }
        fragment.appendChild(modelList);
      }
    }

    fragment.appendChild(buildAutoSwitchFooter());
    fragment.appendChild(buildToolFilterFooter());
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
      const selected = (shimxProviderState.reasoningEffort || 'high') === value;
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

  let shimxAutoSwitch = null; // {strategy, scope, failureThreshold, fastestMarginMs, cooldownSeconds, probeIntervalSeconds, ...}
  let shimxAutoSwitchExpanded = false;

  function ensureAutoSwitchLoaded() {
    if (shimxAutoSwitch || typeof window.shimx !== 'function') return Promise.resolve();
    return window.shimx('/auto-switch/get', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimxAutoSwitch = res.data;
      }
    }).catch(() => {});
  }

  function saveAutoSwitch(patch) {
    const next = Object.assign({}, shimxAutoSwitch || {}, patch);
    return window.shimx('/auto-switch/set', next).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimxAutoSwitch = res.data;
        updateProviderPickerPopover();
      } else {
        showToast(`${S('saveFailed', 'Save failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      }
    }).catch((err) => {
      showToast(`${S('saveFailed', 'Save failed')}: ${err?.message || err}`, 'error');
    });
  }

  function shimxAutoSwitchLabels() {
    return (shimxAutoSwitch && shimxAutoSwitch.labels) || {};
  }

  function strategyLabel(value) {
    const L = shimxAutoSwitchLabels();
    if (value === 'failover') return L.strategyFailover || 'Failover';
    if (value === 'fastest') return L.strategyFastest || 'Fastest';
    return L.strategyManual || 'Manual';
  }

  function scopeLabel(value) {
    const L = shimxAutoSwitchLabels();
    if (value === 'same-protocol') return L.scopeSameProtocol || 'Same proto';
    if (value === 'any') return L.scopeAny || 'Any';
    return L.scopeSameType || 'Same type';
  }

  function buildAutoSwitchFooter() {
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      marginTop: '8px',
      borderTop: '1px solid var(--token-border, rgba(127,127,127,0.10))',
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
    const L = shimxAutoSwitchLabels();
    const headerLabel = document.createElement('span');
    headerLabel.textContent = '⚙ ' + (L.title || 'Auto switch');
    headerLabel.style.flex = '1';

    const summary = document.createElement('span');
    summary.style.color = 'var(--text-secondary, currentColor)';
    summary.style.fontWeight = '500';
    summary.style.fontSize = '11px';
    if (shimxAutoSwitch) {
      summary.textContent = `${strategyLabel(shimxAutoSwitch.strategy)} · ${scopeLabel(shimxAutoSwitch.scope)}`;
    } else {
      summary.textContent = '…';
    }

    const caret = document.createElement('span');
    caret.textContent = shimxAutoSwitchExpanded ? '▴' : '▾';
    caret.style.fontSize = '10px';
    caret.style.opacity = '0.6';

    header.appendChild(headerLabel);
    header.appendChild(summary);
    header.appendChild(caret);
    header.addEventListener('click', async (event) => {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      shimxAutoSwitchExpanded = !shimxAutoSwitchExpanded;
      if (shimxAutoSwitchExpanded) await ensureAutoSwitchLoaded();
      updateProviderPickerPopover();
    }, true);
    wrap.appendChild(header);

    if (shimxAutoSwitchExpanded && shimxAutoSwitch) {
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
      const selected = shimxAutoSwitch[fieldKey] === value;
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

    const current = Number(shimxAutoSwitch[fieldKey] ?? 0);

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

  // ========== 工具过滤关键词 ==========

  let shimxToolFilter = null; // { keywords: {keyword, enabled}[], labels: {...} }
  let shimxToolFilterExpanded = false;
  let shimxToolFilterPending = ''; // 输入框未提交的值,展开时保留

  function ensureToolFilterLoaded() {
    if (shimxToolFilter || typeof window.shimx !== 'function') return Promise.resolve();
    return window.shimx('/tool-filter/get', {}).then((res) => {
      if (res && res.code === 0 && res.data) {
        shimxToolFilter = res.data;
      }
    }).catch(() => {});
  }

  function shimxToolFilterLabels() {
    return (shimxToolFilter && shimxToolFilter.labels) || {};
  }

  async function toolFilterAdd(keyword) {
    const kw = String(keyword || '').trim();
    if (!kw) {
      const L = shimxToolFilterLabels();
      showToast(L.invalid || 'Keyword cannot be empty', 'error');
      return;
    }
    if (Array.isArray(shimxToolFilter?.keywords) && shimxToolFilter.keywords.some((k) => k.keyword === kw)) {
      const L = shimxToolFilterLabels();
      showToast(L.duplicate || 'Keyword already exists', 'error');
      return;
    }
    try {
      const res = await window.shimx('/tool-filter/add', { keyword: kw });
      if (res && res.code === 0 && res.data) {
        shimxToolFilter = res.data;
        shimxToolFilterPending = '';
        updateProviderPickerPopover();
      } else {
        showToast(`${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      }
    } catch (err) {
      showToast(`${err?.message || err}`, 'error');
    }
  }

  async function toolFilterRemove(keyword) {
    try {
      const res = await window.shimx('/tool-filter/remove', { keyword });
      if (res && res.code === 0 && res.data) {
        shimxToolFilter = res.data;
        updateProviderPickerPopover();
      } else {
        showToast(`${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      }
    } catch (err) {
      showToast(`${err?.message || err}`, 'error');
    }
  }

  async function toolFilterToggle(keyword, enabled) {
    try {
      const res = await window.shimx('/tool-filter/toggle', { keyword, enabled });
      if (res && res.code === 0 && res.data) {
        shimxToolFilter = res.data;
        updateProviderPickerPopover();
      } else {
        showToast(`${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      }
    } catch (err) {
      showToast(`${err?.message || err}`, 'error');
    }
  }

  function buildToolFilterFooter() {
    const wrap = document.createElement('div');
    Object.assign(wrap.style, {
      marginTop: '8px',
      borderTop: '1px solid var(--token-border, rgba(127,127,127,0.10))',
      paddingTop: '8px',
    });

    const L = shimxToolFilterLabels();
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

    const headerLabel = document.createElement('span');
    headerLabel.textContent = '🧰 ' + (L.title || 'Tool filter');
    headerLabel.style.flex = '1';

    const summary = document.createElement('span');
    summary.style.color = 'var(--text-secondary, currentColor)';
    summary.style.fontWeight = '500';
    summary.style.fontSize = '11px';
    const keywords = Array.isArray(shimxToolFilter?.keywords) ? shimxToolFilter.keywords : null;
    if (keywords === null) {
      summary.textContent = '…';
    } else if (!keywords.length) {
      summary.textContent = L.empty || 'No keywords';
    } else {
      const active = keywords.filter((k) => k.enabled).length;
      summary.textContent = active === keywords.length
        ? `${keywords.length}`
        : `${active}/${keywords.length}`;
    }

    const caret = document.createElement('span');
    caret.textContent = shimxToolFilterExpanded ? '▴' : '▾';
    caret.style.fontSize = '10px';
    caret.style.opacity = '0.6';

    header.appendChild(headerLabel);
    header.appendChild(summary);
    header.appendChild(caret);
    header.addEventListener('click', async (event) => {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      shimxToolFilterExpanded = !shimxToolFilterExpanded;
      if (shimxToolFilterExpanded) await ensureToolFilterLoaded();
      updateProviderPickerPopover();
    }, true);
    wrap.appendChild(header);

    if (shimxToolFilterExpanded && shimxToolFilter) {
      const body = document.createElement('div');
      Object.assign(body.style, {
        marginTop: '6px',
        padding: '8px',
        borderRadius: '8px',
        background: 'rgba(127, 127, 127, 0.10)',
      });

      const desc = document.createElement('div');
      desc.textContent = L.description || '';
      Object.assign(desc.style, {
        marginBottom: '8px',
        fontSize: '11px',
        lineHeight: '1.4',
        color: 'var(--text-secondary, currentColor)',
      });
      body.appendChild(desc);

      const addRow = document.createElement('div');
      Object.assign(addRow.style, {
        display: 'flex',
        alignItems: 'center',
        gap: '6px',
        marginBottom: '8px',
      });

      const input = document.createElement('input');
      input.type = 'text';
      input.placeholder = L.placeholder || 'e.g. image_generation';
      input.value = shimxToolFilterPending;
      Object.assign(input.style, {
        flex: '1',
        minWidth: '0',
        height: '28px',
        padding: '0 8px',
        border: '1px solid rgba(127, 127, 127, 0.30)',
        borderRadius: '6px',
        background: 'var(--token-main-surface-primary, rgba(255,255,255,0.04))',
        color: 'inherit',
        fontSize: '12px',
        outline: 'none',
      });
      input.addEventListener('input', (event) => {
        // 空格禁止
        const cleaned = String(event.target.value || '').replace(/\s+/g, '');
        if (cleaned !== event.target.value) event.target.value = cleaned;
        shimxToolFilterPending = cleaned;
      });
      input.addEventListener('keydown', async (event) => {
        if (event.key === 'Enter') {
          event.preventDefault();
          event.stopPropagation();
          await toolFilterAdd(event.target.value);
        }
      });
      // 阻止 popover outside-click 把它当外部点击
      input.addEventListener('pointerdown', (event) => event.stopPropagation(), true);
      input.addEventListener('mousedown', (event) => event.stopPropagation(), true);

      const addBtn = document.createElement('button');
      addBtn.type = 'button';
      addBtn.textContent = '+';
      addBtn.setAttribute('aria-label', L.add || 'Add');
      addBtn.setAttribute('title', L.add || 'Add');
      Object.assign(addBtn.style, {
        width: '28px',
        height: '28px',
        border: '1px solid rgba(59, 130, 246, 0.55)',
        borderRadius: '6px',
        background: 'rgba(59, 130, 246, 0.18)',
        color: '#2563eb',
        fontSize: '16px',
        fontWeight: '700',
        lineHeight: '1',
        cursor: 'pointer',
      });
      addBtn.addEventListener('click', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        await toolFilterAdd(input.value);
      }, true);

      addRow.appendChild(input);
      addRow.appendChild(addBtn);
      body.appendChild(addRow);

      const chips = document.createElement('div');
      Object.assign(chips.style, {
        display: 'flex',
        flexWrap: 'wrap',
        gap: '6px',
      });

      const list = Array.isArray(shimxToolFilter.keywords) ? shimxToolFilter.keywords : [];
      if (!list.length) {
        const empty = document.createElement('div');
        empty.textContent = L.empty || 'No keywords';
        Object.assign(empty.style, {
          padding: '4px 0',
          fontSize: '11px',
          color: 'var(--text-secondary, currentColor)',
        });
        chips.appendChild(empty);
      }
      for (const entry of list) {
        const enabled = entry.enabled !== false;
        const kw = entry.keyword;
        const chip = document.createElement('span');
        Object.assign(chip.style, {
          display: 'inline-flex',
          alignItems: 'center',
          gap: '4px',
          height: '24px',
          padding: '0 6px 0 4px',
          border: '1px solid rgba(127, 127, 127, 0.28)',
          borderRadius: '999px',
          background: enabled ? 'rgba(59, 130, 246, 0.14)' : 'rgba(127, 127, 127, 0.10)',
          fontSize: '11px',
          fontWeight: '600',
          opacity: enabled ? '1' : '0.6',
        });

        // 迷你开关 (16x10 圆角轨道 + 8x8 圆点)
        const toggle = document.createElement('button');
        toggle.type = 'button';
        toggle.setAttribute('aria-label', enabled
          ? (L.enabled || 'Enabled')
          : (L.disabled || 'Disabled'));
        toggle.setAttribute('title', enabled
          ? (L.enabled || 'Enabled')
          : (L.disabled || 'Disabled'));
        Object.assign(toggle.style, {
          position: 'relative',
          width: '18px',
          height: '10px',
          border: '0',
          borderRadius: '999px',
          padding: '0',
          background: enabled ? '#2563eb' : 'rgba(127, 127, 127, 0.45)',
          cursor: 'pointer',
          flex: '0 0 auto',
        });
        const knob = document.createElement('span');
        Object.assign(knob.style, {
          position: 'absolute',
          top: '1px',
          left: enabled ? '9px' : '1px',
          width: '8px',
          height: '8px',
          borderRadius: '999px',
          background: '#fff',
          transition: 'left 0.12s ease',
        });
        toggle.appendChild(knob);
        toggle.addEventListener('click', async (event) => {
          event.preventDefault();
          event.stopPropagation();
          event.stopImmediatePropagation();
          await toolFilterToggle(kw, !enabled);
        }, true);
        chip.appendChild(toggle);

        const text = document.createElement('span');
        text.textContent = kw;
        Object.assign(text.style, {
          textDecoration: enabled ? 'none' : 'line-through',
        });
        chip.appendChild(text);

        const del = document.createElement('button');
        del.type = 'button';
        del.textContent = '×';
        del.setAttribute('aria-label', 'Remove');
        Object.assign(del.style, {
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          width: '16px',
          height: '16px',
          border: '0',
          borderRadius: '999px',
          background: 'transparent',
          color: 'inherit',
          fontSize: '14px',
          fontWeight: '700',
          lineHeight: '1',
          cursor: 'pointer',
        });
        del.addEventListener('click', async (event) => {
          event.preventDefault();
          event.stopPropagation();
          event.stopImmediatePropagation();
          await toolFilterRemove(kw);
        }, true);
        chip.appendChild(del);
        chips.appendChild(chip);
      }
      body.appendChild(chips);
      wrap.appendChild(body);
    }

    return wrap;
  }

  async function selectProvider(id, caller) {
    // caller: 'user-click' / 'auto' / etc. 仅用于 dart 端日志定位是哪段 JS 触发的
    console.log('[ShimXDbg] selectProvider', { id, caller, stack: new Error().stack });
    const res = await window.shimx('/provider/select', { id, __caller: caller || 'js:unknown' });
    if (!res || res.code !== 0) {
      showToast(`${S('switchProviderFailed', 'Switch provider failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      return;
    }
    Object.assign(shimxProviderState, {
      selectedId: res.data.selectedId ?? null,
      reasoningEffort: res.data.reasoningEffort || 'high',
      providers: Array.isArray(res.data.providers) ? res.data.providers : [],
      labels: res.data.labels || shimxProviderState.labels || {},
    });
    updateProviderPickerButton();
    updateProviderPickerPopover();
    updateCodexModelSelectorVisibility();
    refreshCurrentProvider();
  }

  async function selectProviderModel(id, model, caller) {
    console.log('[ShimXDbg] selectProviderModel', { id, model, caller, stack: new Error().stack });
    const res = await window.shimx('/provider/select-model', { id, model, __caller: caller || 'js:unknown' });
    if (!res || res.code !== 0) {
      showToast(`${S('switchModelFailed', 'Switch model failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      return;
    }
    Object.assign(shimxProviderState, {
      selectedId: res.data.selectedId ?? null,
      reasoningEffort: res.data.reasoningEffort || 'high',
      providers: Array.isArray(res.data.providers) ? res.data.providers : [],
      labels: res.data.labels || shimxProviderState.labels || {},
    });
    updateProviderPickerButton();
    updateProviderPickerPopover();
    updateCodexModelSelectorVisibility();
    refreshCurrentProvider();
  }

  async function selectReasoningEffort(id, effort) {
    const res = await window.shimx('/provider/set-reasoning-effort', {
      id,
      effort,
    });
    if (!res || res.code !== 0) {
      showToast(`${S('switchEffortFailed', 'Switch reasoning failed')}: ${res?.message || S('unknownError', 'Unknown error')}`, 'error');
      return;
    }
    Object.assign(shimxProviderState, {
      selectedId: res.data.selectedId ?? null,
      reasoningEffort: res.data.reasoningEffort || 'high',
      providers: Array.isArray(res.data.providers) ? res.data.providers : [],
      labels: res.data.labels || shimxProviderState.labels || {},
    });
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

  function ensureBadge() {
    const label = __i18n.currentProviderLabel;
    const turns = document.querySelectorAll('[data-turn-key]');
    const latest = turns.length ? turns[turns.length - 1] : null;
    const existing = document.querySelectorAll('.' + PROVIDER_BADGE_CLASS);

    if (!label || !latest) {
      if (existing.length) {
        __t('ensureProviderBadge: REMOVE all (no label/turn)', { existing: existing.length });
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
        __t('ensureProviderBadge: REMOVE stale', { stale: stale.length });
        stale.forEach((el) => el.remove());
      }
      return;
    }

    __t('ensureProviderBadge: REPLACE -> insert latest', {
      existing: existing.length,
      label: desiredText,
    });
    existing.forEach((el) => el.remove());
    latest.insertBefore(buildProviderBadge(label), latest.firstChild);
  }

  ns.features.providerPicker = {
    ensure,
    ensureBadge,
    updateButton: updateProviderPickerButton,
    updatePopover: updateProviderPickerPopover,
    updateCodexModelSelectorVisibility,
    findAnchor: findProviderPickerAnchor,
    pickerId: PROVIDER_PICKER_ID,
    popoverId: PROVIDER_PICKER_POPOVER_ID,
    providerBadgeClass: PROVIDER_BADGE_CLASS,
  };
})();

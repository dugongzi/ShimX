// ==Shim==
// @name        Shim codex_enhance — runtime/scheduler
// @description 总调度: trace 工具 + ensureAll 主循环 + MutationObserver 主驱动。
//              ensureAll 按顺序拉一遍 features/*.ensure*(), 由 MutationObserver 在 codex 重渲染
//              侧栏/composer 时触发; 每轮带计时和 DOM 计数。
//              对外: runEnsureAll(source), install()(由 bootstrap 调一次), trace.t(tag, data),
//              countDomBefore — 给外部 (如 features/badge / thread_row 的 ensure log) 用。
// @layer       runtime
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;

  // ---- trace ----

  const SHIM_TRACE = true;
  let ensureCount = 0;
  let observerCount = 0;

  function t(tag, data) {
    if (!SHIM_TRACE) return;
    if (data === undefined) console.log('[ShimTrace]', tag);
    else console.log('[ShimTrace]', tag, data);
  }

  function countDomBefore() {
    return {
      badge: document.querySelectorAll('#' + ids.badge).length,
      menu: document.querySelectorAll('#' + ids.menuItem).length,
      picker: document.querySelectorAll('#' + ids.providerPicker).length,
      providerBadge: document.querySelectorAll('.' + ids.providerBadgeClass).length,
      delBtns: document.querySelectorAll('[data-shim-delete-added="1"]').length,
    };
  }

  ns.runtime.trace = { t, countDomBefore };

  // ---- ensureAll + observer ----

  function ensureAll() {
    ensureCount += 1;
    const seq = ensureCount;
    const before = countDomBefore();
    t('ensureAll #' + seq + ' before', before);

    const t0 = performance.now();
    ns.features.badge.remove();
    const t1 = performance.now();
    ns.features.claudeBridge.ensureNav();
    ns.features.shimMenu.ensure();
    ns.features.pluginMenu?.ensure?.();
    const t2 = performance.now();
    ns.features.threadRow.ensure();
    const t3 = performance.now();
    ns.features.providerPicker.ensure();
    const t4 = performance.now();
    ns.features.providerPicker.updateCodexModelSelectorVisibility();
    const t5 = performance.now();
    ns.features.providerPicker.ensureBadge();
    const t6 = performance.now();
    ns.runtime.plugins.ensureFeatures();
    const t8 = performance.now();
    ns.features.claudeBridge.ensureChip();
    const t9 = performance.now();

    const after = countDomBefore();
    const changed = JSON.stringify(before) !== JSON.stringify(after);
    t('ensureAll #' + seq + ' done', {
      changed,
      after,
      ms: {
        badge: +(t1 - t0).toFixed(1),
        menu: +(t2 - t1).toFixed(1),
        del: +(t3 - t2).toFixed(1),
        picker: +(t4 - t3).toFixed(1),
        codexModel: +(t5 - t4).toFixed(1),
        providerBadge: +(t6 - t5).toFixed(1),
        plugin: +(t8 - t6).toFixed(1),
        claudeBridge: +(t9 - t8).toFixed(1),
        total: +(t9 - t0).toFixed(1),
      },
    });
  }

  let ensureRunning = false;
  function runEnsureAll(source) {
    if (ensureRunning) {
      t('runEnsureAll skip (reentrant)', { source });
      return;
    }
    ensureRunning = true;
    t('runEnsureAll start', { source });
    try {
      ensureAll();
    } finally {
      requestAnimationFrame(() => {
        ensureRunning = false;
      });
    }
  }

  const SELF_NODE_SELECTOR = [
    '#' + ids.badge,
    '#' + ids.menuItem,
    '#' + ids.popover,
    '#' + ids.providerPicker,
    '#' + ids.providerPickerPopover,
    '#' + ids.toastContainer,
    '#' + ids.confirmDialog,
    '.' + ids.providerBadgeClass,
    '[data-shim-delete-added]',
    '[data-shim-nav-handled]',
    '[data-shim-install-ready]',
    '[data-shim-prompt-ready]',
    '[data-shim-clear-model]',
  ].join(', ');

  const WATCH_TARGET_SELECTOR = [
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
    return !!node.matches?.(SELF_NODE_SELECTOR) || !!node.closest?.(SELF_NODE_SELECTOR);
  }

  function nodeTouchesWatchTarget(node) {
    if (node.nodeType !== 1) return false;
    if (isSelfManagedNode(node)) return false;
    return !!node.matches?.(WATCH_TARGET_SELECTOR) ||
      !!node.closest?.(WATCH_TARGET_SELECTOR) ||
      !!node.querySelector?.(WATCH_TARGET_SELECTOR);
  }

  function mutationTouchesWatchTarget(record) {
    const target = record.target;
    if (target instanceof Element && isSelfManagedNode(target)) return false;
    if (target instanceof Element && (
      target.matches?.(WATCH_TARGET_SELECTOR) ||
      target.closest?.(WATCH_TARGET_SELECTOR)
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

  function install() {
    if (!document.documentElement) {
      setTimeout(install, 50);
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
      observerCount += 1;
      const obsSeq = observerCount;
      if (ensureRunning) {
        t('observer #' + obsSeq + ' suppressed (self)', { records: records.length });
        return;
      }
      if (!recordsRequireEnsureAll(records)) {
        t('observer #' + obsSeq + ' filtered (irrelevant)', { records: records.length });
        return;
      }
      pendingRecords.push(...records);
      if (scheduled) return;
      scheduled = true;
      setTimeout(() => {
        scheduled = false;
        const summary = summarizeMutations(pendingRecords);
        pendingRecords = [];
        t('observer batch fired', summary);
        runEnsureAll('observer');
      }, 400);
    });
    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
    t('UI scheduler installed');
  }

  ns.runtime.scheduler = {
    install,
    runEnsureAll,
    ensureAll,
  };
})();

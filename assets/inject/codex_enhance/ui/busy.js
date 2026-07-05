// ==Shim==
// @name        Shim codex_enhance — ui/busy
// @description 持久 Busy 指示器 (导出等长耗时任务用), 跨 feature 复用。
//              支持多个并发任务: showBusyIndicator(label) 返回 token, 各 token 独立
//              hideBusyIndicator(token), 全部 hide 后 indicator 才消失。
//              withBusyIndicator(label, run) 包一段可能抛错的异步任务, 自动 show/hide,
//              异常会再抛出。
// @layer       ui
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ids = window.__shimCodex.ids;

  const busyTasks = new Map(); // token -> { node }
  let nextToken = 1;

  function ensureContainer() {
    if (!document.getElementById(ids.busyKeyframes)) {
      const style = document.createElement('style');
      style.id = ids.busyKeyframes;
      style.textContent = [
        '@keyframes shimBusySpin{to{transform:rotate(360deg)}}',
        '@keyframes shimBusyPulse{0%,100%{box-shadow:0 12px 36px rgba(0,0,0,0.45),0 0 0 1px rgba(96,165,250,0.32),0 0 28px rgba(96,165,250,0.30)}50%{box-shadow:0 12px 36px rgba(0,0,0,0.45),0 0 0 1px rgba(96,165,250,0.48),0 0 44px rgba(96,165,250,0.55)}}',
        '@keyframes shimBusyBarSlide{0%{transform:translateX(-100%)}100%{transform:translateX(220%)}}',
        '@keyframes shimBusyPop{0%{opacity:0;transform:translateY(-10px) scale(0.94)}60%{opacity:1;transform:translateY(0) scale(1.02)}100%{opacity:1;transform:translateY(0) scale(1)}}',
      ].join('\n');
      document.head.appendChild(style);
    }
    let container = document.getElementById(ids.busyContainer);
    if (container) return container;
    container = document.createElement('div');
    container.id = ids.busyContainer;
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

  function ensureDim() {
    let dim = document.getElementById(ids.busyDim);
    if (dim) return dim;
    dim = document.createElement('div');
    dim.id = ids.busyDim;
    Object.assign(dim.style, {
      position: 'fixed',
      inset: '0',
      zIndex: '2147483646', // 比 indicator 低 1
      background: 'radial-gradient(circle at 50% 0%, rgba(0,0,0,0.22) 0%, rgba(0,0,0,0.10) 50%, rgba(0,0,0,0) 100%)',
      pointerEvents: 'none', // 不挡操作
      opacity: '0',
      transition: 'opacity 0.22s ease',
    });
    document.body.appendChild(dim);
    requestAnimationFrame(() => { dim.style.opacity = '1'; });
    return dim;
  }

  function removeDimIfIdle() {
    if (busyTasks.size > 0) return;
    const dim = document.getElementById(ids.busyDim);
    if (!dim) return;
    dim.style.opacity = '0';
    setTimeout(() => {
      if (busyTasks.size === 0) dim.remove();
    }, 220);
  }

  function show(label) {
    const container = ensureContainer();
    ensureDim();
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
      background: 'var(--token-main-surface-primary, var(--token-dropdown-background, rgba(127,127,127,0.06)))',
      border: '1px solid rgba(96,165,250,0.30)',
      color: 'var(--token-text-primary, currentColor)',
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
      border: '2.5px solid rgba(127,127,127,0.22)',
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
      background: 'rgba(127,127,127,0.10)',
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

    const token = nextToken++;
    busyTasks.set(token, { node, text, progressBar });
    return token;
  }

  /// 已 show() 的 busy 卡片:更新文案 / 切换到 determinate 进度条。
  /// - label 可选; percent (0-100) 传了就把底部条切成实际百分比,不再无限滑动。
  ///   percent 传 null 或不传就保留原有滑动动画。
  function update(token, opts) {
    const task = busyTasks.get(token);
    if (!task) return;
    if (opts && typeof opts.label === 'string') {
      task.text.textContent = opts.label;
    }
    if (opts && typeof opts.percent === 'number' && task.progressBar) {
      const clamped = Math.max(0, Math.min(100, opts.percent));
      task.progressBar.style.animation = 'none';
      task.progressBar.style.width = clamped + '%';
    }
  }

  function hide(token) {
    const task = busyTasks.get(token);
    if (!task) return;
    busyTasks.delete(token);
    task.node.style.transition = 'opacity 0.2s, transform 0.2s';
    task.node.style.opacity = '0';
    task.node.style.transform = 'translateY(-8px) scale(0.96)';
    setTimeout(() => {
      task.node.remove();
      removeDimIfIdle();
    }, 220);
  }

  async function withBusy(label, run) {
    const token = show(label);
    try {
      return await run();
    } finally {
      hide(token);
    }
  }

  window.__shimCodex.ui.busy = { show, hide, update, withBusy };
})();

// ==Shim==
// @name        Shim User Script SDK
// @description 面向用户脚本的通用 API,挂到 window.shimApi。
//              建立在 codex_enhance (window.__shimCodex) 之上,但屏蔽内部细节:
//              用户不用碰 __shimCodex.features.*、也不用理会拼片顺序。
//              注入顺序: codex_enhance 全部拼片 → shim_api.js → 用户脚本。
// @layer       sdk
// ==/Shim==

(() => {
  if (window.shimApi) return; // 一次注入 guard

  // ---------- 内部工具 ----------

  function noop() {}

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  // codex_enhance 的命名空间。任何 SDK 调用都从这里派生,如果找不到就用兜底。
  function ns() {
    return window.__shimCodex || null;
  }

  // ---------- ready: 等 window.shim 桥装好 ----------
  //
  // shim Dart 侧通过 CDP Runtime.addBinding 注入 window.shim / window.__shimOn,
  // document_start 时可能还没到位,所以对外提供一个 Promise。
  //
  // 用法:
  //   const ok = await shimApi.ready();
  //   if (!ok) return; // 超时,页面可能不是被 shim 注入的
  const READY_TIMEOUT_MS = 8000;
  const READY_POLL_MS = 100;

  let readyPromise = null;
  function ready(timeoutMs) {
    if (readyPromise) return readyPromise;
    const deadline = Date.now() + (timeoutMs || READY_TIMEOUT_MS);
    readyPromise = (async () => {
      while (Date.now() < deadline) {
        if (typeof window.shim === 'function') return true;
        await sleep(READY_POLL_MS);
      }
      return false;
    })();
    return readyPromise;
  }

  // ---------- bridge.call: 走 shim server RPC ----------
  //
  // 优先复用 codex_enhance 的 bridge.call(内置超时 + 统一 { ok, data } 语义),
  // 找不到时回退到直接调 window.shim。
  async function call(path, payload, timeoutMs) {
    const base = ns();
    if (base && base.bridge && typeof base.bridge.call === 'function') {
      return base.bridge.call(path, payload || {}, timeoutMs || 8000);
    }
    if (typeof window.shim !== 'function') {
      return { ok: false, message: 'bridge not ready' };
    }
    let timer;
    try {
      const timeout = new Promise((resolve) => {
        timer = setTimeout(
          () => resolve({ code: -1, message: 'timeout' }),
          timeoutMs || 8000,
        );
      });
      const res = await Promise.race([window.shim(path, payload || {}), timeout]);
      if (res && res.code === 0) return { ok: true, data: res.data || {} };
      return { ok: false, message: (res && res.message) || 'rpc error' };
    } catch (error) {
      return { ok: false, message: (error && error.message) || String(error) };
    } finally {
      if (timer) clearTimeout(timer);
    }
  }

  // ---------- UI: toast / busy / confirm ----------

  function toast(message, kind) {
    const base = ns();
    if (base && base.ui && base.ui.toast) {
      base.ui.toast.show(String(message), kind || 'info');
      return;
    }
    // 兜底: 极简 toast,不依赖 codex 样式
    const el = document.createElement('div');
    Object.assign(el.style, {
      position: 'fixed',
      top: '20px',
      left: '50%',
      transform: 'translateX(-50%)',
      padding: '10px 16px',
      borderRadius: '12px',
      background: 'rgba(20,20,24,0.92)',
      color: '#f8fafc',
      fontSize: '13px',
      zIndex: '2147483647',
      pointerEvents: 'none',
    });
    el.textContent = String(message);
    document.body.appendChild(el);
    setTimeout(() => el.remove(), 3000);
  }

  function busy(label) {
    const base = ns();
    if (base && base.ui && base.ui.busy) {
      const token = base.ui.busy.show(String(label || ''));
      return { done: () => base.ui.busy.hide(token) };
    }
    return { done: noop };
  }

  async function withBusy(label, run) {
    const base = ns();
    if (base && base.ui && base.ui.busy && base.ui.busy.withBusy) {
      return base.ui.busy.withBusy(String(label || ''), run);
    }
    const b = busy(label);
    try {
      return await run();
    } finally {
      b.done();
    }
  }

  // 通用 confirm。codex_enhance 里的 ui.confirm.showDelete 硬编码了删除文案,
  // 这里手写一个通用版,样式跟 codex 主题保持一致。
  function confirm(options) {
    const opts = options || {};
    const title = opts.title || '';
    const message = opts.message || '';
    const okText = opts.okText || 'OK';
    const cancelText = opts.cancelText || 'Cancel';
    const danger = !!opts.danger;

    return new Promise((resolve) => {
      const oldOverlay = document.getElementById('__shim_api_confirm__');
      if (oldOverlay) oldOverlay.remove();

      const overlay = document.createElement('div');
      overlay.id = '__shim_api_confirm__';
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
        maxWidth: '460px',
        padding: '20px 22px',
        borderRadius: '16px',
        outline: '0.5px solid var(--token-border, rgba(255,255,255,0.08))',
        boxShadow: '0 24px 64px rgba(0, 0, 0, 0.4)',
      });

      if (title) {
        const heading = document.createElement('div');
        heading.textContent = title;
        Object.assign(heading.style, {
          fontSize: '15px',
          fontWeight: '700',
          marginBottom: '8px',
        });
        dialog.appendChild(heading);
      }

      if (message) {
        const desc = document.createElement('div');
        desc.className = 'text-token-description-foreground';
        Object.assign(desc.style, {
          fontSize: '13px',
          lineHeight: '1.5',
          marginBottom: '18px',
          whiteSpace: 'pre-wrap',
        });
        desc.textContent = message;
        dialog.appendChild(desc);
      }

      const actions = document.createElement('div');
      Object.assign(actions.style, {
        display: 'flex',
        justifyContent: 'flex-end',
        gap: '8px',
      });

      const cancelBtn = document.createElement('button');
      cancelBtn.type = 'button';
      cancelBtn.textContent = cancelText;
      cancelBtn.className =
        'border-token-border no-drag cursor-interaction flex items-center gap-1 border whitespace-nowrap select-none focus:outline-none rounded-full text-token-foreground hover:bg-token-list-hover-background px-3 py-1.5 text-sm';

      const okBtn = document.createElement('button');
      okBtn.type = 'button';
      okBtn.textContent = okText;
      okBtn.className =
        'no-drag cursor-interaction flex items-center gap-1 whitespace-nowrap select-none focus:outline-none rounded-full px-3 py-1.5 text-sm font-semibold';
      Object.assign(okBtn.style, {
        background: danger ? '#dc2626' : '#2563eb',
        color: '#fff',
        border: '0',
      });

      actions.appendChild(cancelBtn);
      actions.appendChild(okBtn);
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

  // ---------- DOM 工具 ----------
  //
  // codex 是 React SPA,元素会随路由 / 侧栏折叠反复挂载/卸载。
  // querySelector 直接跑很容易踩到"元素还没渲染"或"刚被卸载"的坑。

  const DEFAULT_WAIT_TIMEOUT_MS = 10000;

  /**
   * 等一个 selector 至少出现一次。用 MutationObserver + 初次同步查询兜底。
   * @param {string} selector CSS 选择器
   * @param {{timeout?: number, root?: ParentNode}} [opts]
   * @returns {Promise<Element|null>} 找到返回 Element,超时返回 null
   */
  function waitFor(selector, opts) {
    const o = opts || {};
    const root = o.root || document;
    const timeout = o.timeout || DEFAULT_WAIT_TIMEOUT_MS;
    return new Promise((resolve) => {
      const existing = root.querySelector(selector);
      if (existing) return resolve(existing);
      let done = false;
      const observer = new MutationObserver(() => {
        const el = root.querySelector(selector);
        if (el && !done) {
          done = true;
          observer.disconnect();
          resolve(el);
        }
      });
      observer.observe(root instanceof Document ? root.documentElement : root, {
        childList: true,
        subtree: true,
      });
      setTimeout(() => {
        if (done) return;
        done = true;
        observer.disconnect();
        resolve(null);
      }, timeout);
    });
  }

  /**
   * 元素每次挂载都触发。react re-mount 场景常用。
   * callback(element) 里可以自由改样式/挂 listener,SDK 内部保证同一元素只回调一次(用 WeakSet)。
   * @param {string} selector
   * @param {(el: Element) => void} callback
   * @param {{root?: ParentNode, once?: boolean}} [opts] once=true 表示第一次触发后就 stop
   * @returns {{stop: () => void}}
   */
  function onMount(selector, callback, opts) {
    const o = opts || {};
    const root = o.root || document;
    const seen = new WeakSet();
    let stopped = false;

    function scan() {
      if (stopped) return;
      const nodes = root.querySelectorAll(selector);
      for (const node of nodes) {
        if (seen.has(node)) continue;
        seen.add(node);
        try {
          callback(node);
        } catch (e) {
          console.error('[shimApi.onMount] callback error:', e);
        }
        if (o.once) {
          stop();
          return;
        }
      }
    }

    const observer = new MutationObserver(() => scan());
    observer.observe(root instanceof Document ? root.documentElement : root, {
      childList: true,
      subtree: true,
    });
    scan(); // 初次同步扫

    function stop() {
      if (stopped) return;
      stopped = true;
      observer.disconnect();
    }

    return { stop };
  }

  /**
   * 通用 MutationObserver 包装,拿到 records 数组。
   * @param {Node} target
   * @param {(records: MutationRecord[]) => void} callback
   * @param {MutationObserverInit} [init]
   * @returns {{stop: () => void}}
   */
  function observe(target, callback, init) {
    const observer = new MutationObserver((records) => {
      try {
        callback(records);
      } catch (e) {
        console.error('[shimApi.observe] callback error:', e);
      }
    });
    observer.observe(target || document.documentElement, init || {
      childList: true,
      subtree: true,
    });
    return { stop: () => observer.disconnect() };
  }

  /**
   * SPA URL 变化钩子。同时 hook history.pushState/replaceState + popstate + hashchange。
   * 页内 SPA 用 pushState 换路由不会触发 popstate,得 patch 才能感知。
   * @param {(url: string) => void} callback
   * @returns {{stop: () => void}}
   */
  const URL_LISTENERS = new Set();
  let urlHookInstalled = false;
  function ensureUrlHook() {
    if (urlHookInstalled) return;
    urlHookInstalled = true;
    const fire = () => {
      const url = location.href;
      for (const cb of URL_LISTENERS) {
        try {
          cb(url);
        } catch (e) {
          console.error('[shimApi.onUrlChange] callback error:', e);
        }
      }
    };
    const origPush = history.pushState;
    const origReplace = history.replaceState;
    history.pushState = function () {
      const ret = origPush.apply(this, arguments);
      fire();
      return ret;
    };
    history.replaceState = function () {
      const ret = origReplace.apply(this, arguments);
      fire();
      return ret;
    };
    window.addEventListener('popstate', fire);
    window.addEventListener('hashchange', fire);
  }
  function onUrlChange(callback) {
    if (typeof callback !== 'function') return { stop: noop };
    ensureUrlHook();
    URL_LISTENERS.add(callback);
    return {
      stop: () => URL_LISTENERS.delete(callback),
    };
  }

  // ---------- 页面生命周期 & shim 事件订阅 ----------

  function onReady(callback) {
    if (typeof callback !== 'function') return;
    if (document.readyState !== 'loading') {
      // 已 ready,微任务里跑,保持一致的异步语义
      Promise.resolve().then(callback);
      return;
    }
    document.addEventListener('DOMContentLoaded', () => callback(), {
      once: true,
    });
  }

  /**
   * 订阅 shim server 主动推送的事件(如 provider 切换、health 变化等)。
   * topic 参考 shim 后端 route 定义。
   * @param {string} topic
   * @param {(payload: any) => void} callback
   * @returns {{stop: () => void}}
   */
  function subscribe(topic, callback) {
    if (typeof window.__shimOn !== 'function' || typeof callback !== 'function') {
      return { stop: noop };
    }
    const sub = window.__shimOn(topic, callback);
    return {
      stop: () => {
        try {
          if (sub && typeof sub.cancel === 'function') sub.cancel();
          else if (sub && typeof sub === 'function') sub();
        } catch (_) {}
      },
    };
  }

  // ---------- 导出 ----------

  window.shimApi = {
    version: '1.0.0',
    ready,
    bridge: { call },
    // UI
    toast,
    busy,
    withBusy,
    confirm,
    // DOM
    waitFor,
    onMount,
    observe,
    onUrlChange,
    // 生命周期
    onReady,
    subscribe,
  };

  if (typeof console !== 'undefined') {
    console.log('[shimApi] ready, version', window.shimApi.version);
  }
})();

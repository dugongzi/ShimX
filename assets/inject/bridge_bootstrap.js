(() => {
  if (window.shimx && window.__shimxCallbacks) return;
  window.__shimxSeq = 0;
  window.__shimxCallbacks = new Map();
  window.__shimxResolve = (id, result) => {
    const cb = window.__shimxCallbacks.get(id);
    if (!cb) return;
    window.__shimxCallbacks.delete(id);
    cb.resolve(result);
  };
  window.__shimxReject = (id, message) => {
    const cb = window.__shimxCallbacks.get(id);
    if (!cb) return;
    window.__shimxCallbacks.delete(id);
    cb.reject(new Error(message));
  };
  window.shimx = (path, payload) => new Promise((resolve, reject) => {
    const id = String(++window.__shimxSeq);
    window.__shimxCallbacks.set(id, { resolve, reject });
    window.__shimxBridge(JSON.stringify({ id, path, payload: payload ?? {} }));
  });

  // Push event 通道:dart 端调 bridge.dispatchEvent(path, payload)
  // JS 端用 window.__shimxOn(path, listener) 订阅;同一 path 可多个 listener。
  window.__shimxListeners = new Map();
  window.__shimxDispatch = (path, payload) => {
    const list = window.__shimxListeners.get(path);
    if (!list) return;
    for (const fn of list) {
      try { fn(payload); } catch (_) {}
    }
  };
  window.__shimxOn = (path, listener) => {
    let list = window.__shimxListeners.get(path);
    if (!list) {
      list = new Set();
      window.__shimxListeners.set(path, list);
    }
    list.add(listener);
    return () => list.delete(listener);
  };
})();

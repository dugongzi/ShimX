(() => {
  if (window.shim && window.__shimCallbacks) return;
  window.__shimSeq = 0;
  window.__shimCallbacks = new Map();
  window.__shimResolve = (id, result) => {
    const cb = window.__shimCallbacks.get(id);
    if (!cb) return;
    window.__shimCallbacks.delete(id);
    cb.resolve(result);
  };
  window.__shimReject = (id, message) => {
    const cb = window.__shimCallbacks.get(id);
    if (!cb) return;
    window.__shimCallbacks.delete(id);
    cb.reject(new Error(message));
  };
  window.shim = (path, payload) => new Promise((resolve, reject) => {
    const id = String(++window.__shimSeq);
    window.__shimCallbacks.set(id, { resolve, reject });
    window.__shimBridge(JSON.stringify({ id, path, payload: payload ?? {} }));
  });

  // Push event 通道:dart 端调 bridge.dispatchEvent(path, payload)
  // JS 端用 window.__shimOn(path, listener) 订阅;同一 path 可多个 listener。
  window.__shimListeners = new Map();
  window.__shimDispatch = (path, payload) => {
    const list = window.__shimListeners.get(path);
    if (!list) return;
    for (const fn of list) {
      try { fn(payload); } catch (_) {}
    }
  };
  window.__shimOn = (path, listener) => {
    let list = window.__shimListeners.get(path);
    if (!list) {
      list = new Set();
      window.__shimListeners.set(path, list);
    }
    list.add(listener);
    return () => list.delete(listener);
  };
})();

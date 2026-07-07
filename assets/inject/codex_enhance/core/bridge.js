// ==ShimX==
// @name        ShimX codex_enhance — core/bridge
// @description shimx 桥 RPC 工具。包 window.shimx 加 timeout, 返回 { ok, data } 或 { ok:false, message }。
// @layer       core
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;

  async function call(path, payload, timeoutMs) {
    if (typeof window.shimx !== 'function') {
      return { ok: false, message: 'bridge not ready' };
    }
    let timer;
    try {
      const timeout = new Promise((resolve) => {
        timer = setTimeout(() => resolve({ code: -1, message: 'timeout' }), timeoutMs);
      });
      const res = await Promise.race([window.shimx(path, payload || {}), timeout]);
      if (res && res.code === 0) return { ok: true, data: res.data || {} };
      return { ok: false, message: res?.message || 'rpc error' };
    } catch (error) {
      return { ok: false, message: error?.message || String(error) };
    } finally {
      if (timer) clearTimeout(timer);
    }
  }

  window.__shimxCodex.bridge = { call };
})();

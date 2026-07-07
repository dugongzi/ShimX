// ==ShimX==
// @name        ShimX codex_enhance — features/network_blocker
// @description 阻断 Statsig 等被墙的请求, 避免主页面 hydration 卡 10 秒。
//              纯副作用模块, 只在加载时 hook 一次 fetch / XHR / sendBeacon,
//              不对外暴露任何 API。
//
//              ab.chatgpt.com / chatgpt.com/ces 在国内不可达, Codex 启动会等到 10s 超时,
//              表现为主页面一直 loading。这里直接让请求立即"成功", 返回看起来合法的空响应,
//              避免触发 SPA 的 error 路径 (会重渲染整个页面)。
// @layer       features
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;
  if (window.__shimxNetBlockerInstalled) return;
  window.__shimxNetBlockerInstalled = true;

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
  window.fetch = function shimxBlockingFetch(input, init) {
    const url = typeof input === 'string' ? input : input?.url;
    if (isBlocked(url)) {
      blockedCount += 1;
      if (blockedCount <= 3) {
        console.log('[ShimXNetBlock] fetch faked', url);
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
  OrigXHR.prototype.open = function shimxBlockingOpen(method, url) {
    this.__shimxBlockedUrl = url;
    this.__shimxIsBlocked = isBlocked(url);
    return origOpen.apply(this, arguments);
  };
  OrigXHR.prototype.setRequestHeader = function (name, value) {
    if (this.__shimxIsBlocked) return; // 不真发, header 也别真写
    return origSetReqHeader.apply(this, arguments);
  };
  OrigXHR.prototype.send = function shimxBlockingSend() {
    if (this.__shimxIsBlocked) {
      blockedCount += 1;
      if (blockedCount <= 3) {
        console.log('[ShimXNetBlock] xhr faked', this.__shimxBlockedUrl);
      }
      const body = fakeStatsigBody(this.__shimxBlockedUrl);
      setTimeout(() => {
        try {
          Object.defineProperty(this, 'readyState', { value: 4, configurable: true });
          Object.defineProperty(this, 'status', { value: 200, configurable: true });
          Object.defineProperty(this, 'statusText', { value: 'OK', configurable: true });
          Object.defineProperty(this, 'responseText', { value: body, configurable: true });
          Object.defineProperty(this, 'response', { value: body, configurable: true });
          Object.defineProperty(this, 'responseURL', { value: this.__shimxBlockedUrl, configurable: true });
          this.dispatchEvent(new Event('readystatechange'));
          this.dispatchEvent(new Event('load'));
          this.dispatchEvent(new Event('loadend'));
        } catch (_) {}
      }, 0);
      return;
    }
    return origSend.apply(this, arguments);
  };

  // sendBeacon 也可能被 Statsig 用, 直接返回 true 装作发了
  const origBeacon = navigator.sendBeacon?.bind(navigator);
  if (origBeacon) {
    navigator.sendBeacon = function shimxBlockingBeacon(url, data) {
      if (isBlocked(url)) {
        blockedCount += 1;
        if (blockedCount <= 3) console.log('[ShimXNetBlock] beacon faked', url);
        return true;
      }
      return origBeacon(url, data);
    };
  }

  console.log('[ShimXNetBlock] installed (fake-success mode), targets:', BLOCKED_HOSTS.join(', '));
})();

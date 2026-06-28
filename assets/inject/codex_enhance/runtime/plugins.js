// ==Shim==
// @name        Shim codex_enhance — runtime/plugins
// @description Codex 插件运行时兼容层。Codex 自己把 OpenAI 官方插件市场标成 "remote", 不能用,
//              这里在 Array.prototype.filter 上插了一个 guard, 让市场 visibility / source 过滤
//              放行 OpenAI 官方家族 (openai-bundled / openai-curated / openai-primary-runtime),
//              并把 list-plugins 的请求/响应规范化, 让安装/导航按钮真的可点。
//
//              对外: ensureFeatures() — 由 runtime/scheduler 在 ensureAll 里每轮调一次,
//              tick(flags) — 直接调底层, 单独控制每个特性是否启用 (window.__SHIM_PLUGIN_FLAGS)。
// @layer       runtime
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;

  // ========== Codex 插件运行时兼容 ==========

  const shimRuntimePlugins = (() => {
    const version = 'shim-runtime-plugin-layer-v1';
    const arrayGuardVersion = 'shim-runtime-array-visibility-v1';
    const clientBridgeVersion = 'shim-runtime-client-bridge-v1';
    const scanFlag = 'data-shim-plugin-ready';
    const installFlag = 'data-shim-install-ready';
    const logPrefix = '[ShimPlugin]';
    // codex 老版本: nav[role="navigation"] button.h-token-nav-row.w-full
    // codex 新版本: 去掉了 nav 包裹,行高换成 Tailwind 任意值 h-[var(--height-token-row)],
    //              按钮在 div.flex.flex-col.gap-px 里。两种都接受,避免改一边漏一边。
    const navSelector = [
      'nav[role="navigation"] button.h-token-nav-row.w-full',
      'div.flex.flex-col.gap-px > button.w-full[class*="h-[var(--height-token-row)]"]',
    ].join(', ');
    const pluginIconPathPrefix = 'M7.94562 14.0277';
    const marketIds = new Set([
      'openai-bundled',
      'openai-curated',
      'openai-primary-runtime',
    ]);
    const moduleCache = new Map();
    const state = {
      navSignature: '',
      installSignature: '',
      promptSignature: '',
      arrayGuardInstalled: false,
      clients: [],
      pluginRecords: new Map(),
      lastPluginListParams: null,
      runtimeHostId: 'local',
    };

    function log(message, data) {
      if (data === undefined) {
        console.info(logPrefix + ' ' + message);
        return;
      }
      let detail;
      try {
        detail = JSON.stringify(data);
      } catch (_) {
        detail = String(data);
      }
      console.info(logPrefix + ' ' + message + ' ' + detail);
    }

    function visibleText(element) {
      return (element?.textContent || '').replace(/\s+/g, ' ').trim();
    }

    function isLoginSurface() {
      // 用具体的登录 DOM 节点判断,避免对整个 body 文本做正则——
      // 否则主界面只要瞬间出现"Codex"字样就会被误判,触发 array guard 反复装卸。
      if (document.querySelector('[data-testid="login-with-chatgpt"], [data-testid="login-with-api-key"]')) {
        return true;
      }
      // nav 都没渲染出来时,大概率还在登录页/启动屏
      if (!document.querySelector(navSelector)) return true;
      return false;
    }

    function isRuntimeSurfaceReady() {
      if (isLoginSurface()) return false;
      return pluginNavButtons().length > 0;
    }

    function canonicalMarketName(value) {
      const raw = String(value || '');
      return raw.startsWith('remote:') ? raw.slice('remote:'.length) : raw;
    }

    function isNativeMarket(value) {
      return marketIds.has(canonicalMarketName(value));
    }

    function marketLabel(value, fallback) {
      const name = canonicalMarketName(value);
      if (name === 'openai-bundled') return 'OpenAI Bundled';
      if (name === 'openai-curated') return 'OpenAI Curated';
      if (name === 'openai-primary-runtime') return 'OpenAI Runtime';
      return fallback || name || '';
    }

    function runtimeMethodName(method, params) {
      const raw = String(method || '');
      if (raw === 'send-cli-request-for-host' && params?.method) return String(params.method);
      return raw;
    }

    function normalizeMarketParams(params) {
      if (!params || typeof params !== 'object') return params;
      let next = params;
      if (Array.isArray(params.marketplaceKinds)) {
        const kinds = params.marketplaceKinds.map((kind) => {
          const value = String(kind || '');
          return value.startsWith('remote:')
            ? 'remote:' + canonicalMarketName(value)
            : canonicalMarketName(value);
        });
        next = { ...next, marketplaceKinds: Array.from(new Set(kinds)) };
      }
      if (typeof params.remoteMarketplaceName === 'string') {
        next = next === params ? { ...params } : { ...next };
        next.remoteMarketplaceName = canonicalMarketName(params.remoteMarketplaceName);
      }
      if (typeof params.marketplacePath === 'string' && params.marketplacePath.startsWith('remote:')) {
        next = next === params ? { ...params } : { ...next };
        next.remoteMarketplaceName = canonicalMarketName(params.marketplacePath);
        delete next.marketplacePath;
      }
      return next;
    }

    function prepareRuntimeParams(method, params) {
      if (!params || typeof params !== 'object') return params;
      const nested = params.method && params.params && typeof params.params === 'object';
      const target = nested ? params.params : params;
      let nextTarget = normalizeMarketParams(target);
      if (method === 'list-plugins' && nextTarget && typeof nextTarget === 'object' &&
          Object.prototype.hasOwnProperty.call(nextTarget, 'marketplaceKinds')) {
        nextTarget = { ...nextTarget };
        delete nextTarget.marketplaceKinds;
      }
      if (nested) {
        let nextParams = nextTarget !== target ? { ...params, params: nextTarget } : params;
        if (typeof nextParams.hostId === 'string' && nextParams.hostId.trim()) {
          state.runtimeHostId = nextParams.hostId.trim();
        } else if (String(params.method || '') === method) {
          nextParams = { ...nextParams, hostId: state.runtimeHostId || 'local' };
        }
        return nextParams;
      }
      return nextTarget;
    }

    function normalizeMarketObject(marketplace) {
      if (!marketplace || typeof marketplace !== 'object') return false;
      if (marketplace.__shimRuntimeMarket === version) return false;
      const name = canonicalMarketName(marketplace.name || marketplace.marketplaceName || marketplace.remoteMarketplaceName);
      if (!marketIds.has(name)) return false;
      const label = marketLabel(name, marketplace.displayName || marketplace.title || marketplace.label || marketplace.name);
      marketplace.name = name;
      marketplace.marketplaceName = name;
      marketplace.remoteMarketplaceName = name;
      marketplace.displayName = label;
      marketplace.title = label;
      marketplace.label = label;
      if (marketplace.interface && typeof marketplace.interface === 'object') {
        marketplace.interface = {
          ...marketplace.interface,
          displayName: label,
          title: label,
          label,
        };
      } else {
        marketplace.interface = { displayName: label, title: label, label };
      }
      if (Array.isArray(marketplace.plugins)) {
        marketplace.plugins.forEach((item) => {
          if (item && typeof item === 'object' && isNativeMarket(item.marketplaceName || name)) {
            item.marketplaceName = name;
          }
        });
      }
      marketplace.__shimRuntimeMarket = version;
      return true;
    }

    function pluginRecordKeys(plugin, marketplace) {
      return [
        plugin?.displayName,
        plugin?.title,
        plugin?.label,
        plugin?.name,
        plugin?.pluginName,
        plugin?.id,
        marketplace?.displayName,
      ].map((value) => String(value || '').replace(/\s+/g, ' ').trim().toLowerCase()).filter(Boolean);
    }

    function rememberPluginRecords(payload) {
      const roots = [payload, payload?.data, payload?.result].filter(Boolean);
      let count = 0;
      for (const root of roots) {
        const marketplaces = Array.isArray(root?.marketplaces) ? root.marketplaces : Array.isArray(root) ? root : [];
        for (const marketplace of marketplaces) {
          const marketName = canonicalMarketName(marketplace?.name || marketplace?.marketplaceName || marketplace?.remoteMarketplaceName);
          const plugins = Array.isArray(marketplace?.plugins) ? marketplace.plugins : [];
          for (const plugin of plugins) {
            if (!plugin || typeof plugin !== 'object') continue;
            const pluginName = plugin.pluginName || plugin.name || plugin.id || plugin.slug;
            if (!pluginName) continue;
            const remoteMarketplaceName = canonicalMarketName(plugin.marketplaceName || marketName);
            const record = {
              pluginName: String(pluginName),
              remoteMarketplaceName,
              marketplacePath: 'remote:' + remoteMarketplaceName,
              title: plugin.displayName || plugin.title || plugin.label || plugin.name || String(pluginName),
              raw: plugin,
            };
            for (const key of pluginRecordKeys(plugin, marketplace)) {
              state.pluginRecords.set(key, record);
            }
            count += 1;
          }
        }
      }
      if (count > 0) log('plugin records cached', { count });
    }

    function normalizeRuntimePayload(method, payload) {
      if (method !== 'list-plugins') return payload;
      let changed = 0;
      const roots = [payload, payload?.data, payload?.result].filter(Boolean);
      for (const root of roots) {
        if (Array.isArray(root?.marketplaces)) {
          root.marketplaces.forEach((marketplace) => {
            if (normalizeMarketObject(marketplace)) changed += 1;
          });
        }
        if (Array.isArray(root)) {
          root.forEach((marketplace) => {
            if (normalizeMarketObject(marketplace)) changed += 1;
          });
        }
      }
      rememberPluginRecords(payload);
      if (changed > 0) log('marketplace payload normalized', { changed });
      return payload;
    }

    function isSourceGate(callback, items) {
      if (!Array.isArray(items) || items.length === 0 || typeof callback !== 'function') return false;
      if (!items.some((item) => isNativeMarket(item?.marketplaceName))) return false;
      let source = '';
      try {
        source = Function.prototype.toString.call(callback);
      } catch (_) {
        return false;
      }
      if (!source.includes('marketplaceName')) return false;
      return items.some((item) => isNativeMarket(item?.marketplaceName) && !callback(item));
    }

    function isVisibilityGate(callback, items) {
      if (!Array.isArray(items) || items.length === 0 || typeof callback !== 'function') return false;
      if (!items.some((item) => isNativeMarket(item?.name))) return false;
      let source = '';
      try {
        source = Function.prototype.toString.call(callback);
      } catch (_) {
        return false;
      }
      if (!source.includes('includes') || !source.includes('name')) return false;
      return items.some((item) => isNativeMarket(item?.name) && !callback(item));
    }

    function installScopedArrayGuard() {
      const baseFilter = Array.prototype.__shimRuntimeArrayFilterSource ||
        Array.prototype.__shimPluginOriginalFilter ||
        Array.prototype.filter;
      if (!Array.prototype.__shimRuntimeArrayFilterSource) {
        Object.defineProperty(Array.prototype, '__shimRuntimeArrayFilterSource', {
          value: baseFilter,
          configurable: true,
          writable: true,
        });
      }
      if (Array.prototype.filter.__shimRuntimeArrayGuard === arrayGuardVersion) {
        state.arrayGuardInstalled = true;
        return;
      }
      const guardedFilter = function shimRuntimeScopedFilter(callback, thisArg) {
        if (isSourceGate(callback, this) || isVisibilityGate(callback, this)) {
          log('runtime marketplace visibility retained', { count: this.length });
          return Array.from(this);
        }
        return baseFilter.call(this, callback, thisArg);
      };
      Object.defineProperty(guardedFilter, '__shimRuntimeArrayGuard', {
        value: arrayGuardVersion,
        configurable: true,
      });
      Array.prototype.filter = guardedFilter;
      state.arrayGuardInstalled = true;
      log('runtime array guard attached');
    }

    function codexAssetUrl(part) {
      const urls = [
        ...Array.from(document.scripts || []).map((script) => script.src),
        ...Array.from(document.querySelectorAll('link[href]') || []).map((link) => link.href),
        ...performance.getEntriesByType('resource').map((entry) => entry.name),
      ].filter(Boolean);
      return urls.find((url) => url.includes('/assets/') && url.includes(part) && url.split('?')[0].endsWith('.js')) || '';
    }

    function importCodexRuntime(part) {
      if (!moduleCache.has(part)) {
        moduleCache.set(part, Promise.resolve().then(async () => {
          const url = codexAssetUrl(part);
          if (!url) throw new Error('Codex asset not found: ' + part);
          return import(url);
        }));
      }
      return moduleCache.get(part);
    }

    function attachRequestMiddleware(client) {
      if (!client || typeof client.sendRequest !== 'function') return false;
      if (client.__shimRuntimeClientBridge === clientBridgeVersion) return true;
      const baseSend = client.__shimRuntimeOriginalSendRequest ||
        client.__shimPluginOriginalSendRequest ||
        client.sendRequest.bind(client);
      client.__shimRuntimeOriginalSendRequest = baseSend;
      client.sendRequest = async function shimRuntimeSendRequest(method, params, options) {
        const resolvedMethod = runtimeMethodName(method, params);
        const nextParams = prepareRuntimeParams(resolvedMethod, params);
        if (resolvedMethod === 'list-plugins') state.lastPluginListParams = nextParams;
        if (resolvedMethod === 'list-plugins' || resolvedMethod === 'install-plugin' || resolvedMethod === 'plugin/install') {
          log('runtime request normalized', {
            method: String(method || ''),
            resolvedMethod,
            changed: nextParams !== params,
          });
        }
        const result = await baseSend(method, nextParams, options);
        return normalizeRuntimePayload(resolvedMethod, result);
      };
      client.__shimRuntimeClientBridge = clientBridgeVersion;
      if (!state.clients.includes(client)) state.clients.push(client);
      return true;
    }

    function attachRuntimeClientBridge() {
      if (window.__shimRuntimeClientBridgeReady === clientBridgeVersion) return;
      importCodexRuntime('app-server-manager-signals-').then((module) => {
        const exports = Object.values(module || {}).filter((value) => value && typeof value === 'object');
        let attached = 0;
        for (const candidate of exports) {
          if (attachRequestMiddleware(candidate)) attached += 1;
          if (typeof candidate.sendRequest !== 'function' && typeof candidate.get === 'function') {
            try {
              if (attachRequestMiddleware(candidate.get())) attached += 1;
            } catch (_) {}
          }
        }
        if (attached > 0) {
          window.__shimRuntimeClientBridgeReady = clientBridgeVersion;
          log('runtime client bridge attached', { exports: Object.keys(module || {}).length, candidates: exports.length, attached });
        } else {
          log('runtime client bridge not found', { exports: Object.keys(module || {}).length, candidates: exports.length });
        }
      }).catch((error) => {
        log('runtime client bridge failed', { error: error?.message || String(error) });
      });
    }

    function pluginNavButtons() {
      // navSelector 现在是逗号分隔的多签名,直接拼字符串会把后缀只作用到最后一段。
      // 这里给每段都补上 svg path 后缀,等价于 (A svg path), (B svg path)。
      const iconSelector = navSelector
        .split(',')
        .map((sel) => sel.trim() + ' svg path[d^="' + pluginIconPathPrefix + '"]')
        .join(', ');
      const byIcon = document.querySelector(iconSelector)?.closest('button');
      const candidates = Array.from(
        document.querySelectorAll(navSelector + ', nav button, aside button, [role="navigation"] button'),
      );
      const matched = candidates.filter((button) => /^(插件|Plugins)(\s|$|[-:：])/.test(visibleText(button)));
      if (byIcon && !matched.includes(byIcon)) matched.unshift(byIcon);
      return matched;
    }

    function patchReactDisabledProps(element) {
      Object.keys(element || {})
        .filter((key) => key.startsWith('__reactProps') || key.startsWith('__reactFiber'))
        .forEach((key) => {
          const ref = element[key];
          const props = ref?.memoizedProps || ref?.pendingProps || ref;
          if (!props || typeof props !== 'object') return;
          if ('disabled' in props) props.disabled = false;
          if ('aria-disabled' in props) props['aria-disabled'] = false;
          if ('data-disabled' in props) props['data-disabled'] = undefined;
          if ('inert' in props) props.inert = false;
        });
    }

    function makeControlInteractive(element) {
      if (!(element instanceof HTMLElement)) return;
      if ('disabled' in element) element.disabled = false;
      element.removeAttribute('disabled');
      element.removeAttribute('aria-disabled');
      element.removeAttribute('data-disabled');
      element.removeAttribute('inert');
      element.removeAttribute('aria-describedby');
      const title = element.getAttribute('title') || '';
      if (/不可用|unavailable/i.test(title)) element.removeAttribute('title');
      element.style.pointerEvents = 'auto';
      element.style.opacity = '';
      element.style.cursor = 'pointer';
      element.tabIndex = 0;
      element.classList.remove('disabled', 'pointer-events-none', 'cursor-not-allowed', 'opacity-40', 'opacity-50');
      patchReactDisabledProps(element);
    }

    function relatedInteractiveNodes(control) {
      const nodes = [control];
      control.querySelectorAll?.('button, [role="button"], [disabled], [aria-disabled], [data-disabled], .cursor-not-allowed, .pointer-events-none')
        .forEach((node) => nodes.push(node));
      let parent = control.parentElement;
      for (let depth = 0; parent && depth < 4; depth += 1, parent = parent.parentElement) {
        if (parent.matches?.('button, [role="button"], [disabled], [aria-disabled], [data-disabled], .cursor-not-allowed, .pointer-events-none, [data-state]')) {
          nodes.push(parent);
        }
      }
      return Array.from(new Set(nodes));
    }

    function forceInteractiveCluster(control) {
      relatedInteractiveNodes(control).forEach(makeControlInteractive);
    }

    function keepControlInteractive(control) {
      if (!(control instanceof HTMLElement)) return;
      if (control.dataset.shimKeepInteractive === '1') return;
      control.dataset.shimKeepInteractive = '1';
      const keep = () => forceInteractiveCluster(control);
      ['pointerover', 'pointerenter', 'pointerdown', 'mousedown', 'mouseup', 'click', 'focus'].forEach((eventName) => {
        control.addEventListener(eventName, keep, true);
      });
    }

    function syncNavigationControls() {
      const buttons = pluginNavButtons();
      const signature = buttons.length + ':' + buttons.map(visibleText).join(' | ');
      if (signature !== state.navSignature) {
        state.navSignature = signature;
        log('navigation controls synced', { count: buttons.length, labels: buttons.map(visibleText).join(' | ') || null });
      }
      for (const button of buttons) {
        // 每个 button 只处理一次——重复 makeControlInteractive 会触发 React reconcile 循环
        if (button.getAttribute('data-shim-nav-handled') === '1') continue;
        makeControlInteractive(button);
        button.style.display = '';
        button.setAttribute(scanFlag, '1');
        button.setAttribute('data-shim-nav-handled', '1');
        button.title = button.title || 'Shim plugin runtime ready';
      }
    }

    function isInstallControlText(text) {
      const label = String(text || '').replace(/\s+/g, ' ').trim();
      return label === '添加' || label === 'Add' || label === '安装' || label === 'Install' || label === '强制安装';
    }

    function normalizeInstallControls() {
      const controls = Array.from(document.querySelectorAll(
        'button:disabled, button[aria-disabled="true"], [role="button"][aria-disabled="true"], button[data-disabled], [role="button"][data-disabled], button.cursor-not-allowed, [role="button"].cursor-not-allowed, button.pointer-events-none, [role="button"].pointer-events-none',
      ));
      const unique = Array.from(new Set(controls.map((node) => node.closest?.('button, [role="button"]') || node)));
      let matched = 0;
      let changed = 0;
      for (const control of unique) {
        if (!(control instanceof HTMLElement)) continue;
        if (!isInstallControlText(control.textContent)) continue;
        matched += 1;
        const blocked = control.hasAttribute('disabled') ||
          control.getAttribute('aria-disabled') === 'true' ||
          control.getAttribute('data-disabled') === 'true' ||
          control.classList.contains('cursor-not-allowed') ||
          control.classList.contains('pointer-events-none');
        forceInteractiveCluster(control);
        keepControlInteractive(control);
        control.setAttribute(installFlag, '1');
        control.title = control.title || 'Shim install control ready';
        if (blocked) changed += 1;
      }
      const signature = matched + ':' + changed;
      if (signature !== state.installSignature) {
        state.installSignature = signature;
        log('install controls normalized', { matched, changed });
      }
    }

    function normalizePromptExampleControls() {
      const controls = Array.from(document.querySelectorAll('button[aria-disabled="true"], [role="button"][aria-disabled="true"]'))
        .filter((control) => control instanceof HTMLElement && String(control.className || '').includes('group/prompt'));
      let changed = 0;
      for (const control of controls) {
        forceInteractiveCluster(control);
        keepControlInteractive(control);
        control.setAttribute('data-shim-prompt-ready', '1');
        control.title = control.title || 'Shim prompt ready';
        changed += 1;
      }
      const signature = controls.length + ':' + changed;
      if (signature !== state.promptSignature) {
        state.promptSignature = signature;
        log('prompt example controls normalized', { matched: controls.length, changed });
      }
    }

    function tick(flags) {
      const f = flags || {};
      const ready = isRuntimeSurfaceReady();
      window.__shimCodex.runtime?.trace?.t?.('plugin tick', { ready, isLogin: isLoginSurface() });
      if (!ready) return;
      if (f.arrayGuard !== false) installScopedArrayGuard();
      if (f.clientBridge !== false) attachRuntimeClientBridge();
      if (f.syncNav !== false) syncNavigationControls();
      if (f.normalizeInstall !== false) normalizeInstallControls();
      if (f.normalizePrompt !== false) normalizePromptExampleControls();
    }

    return { tick };
  })();

  const __SHIM_PLUGIN_FLAGS = {
    arrayGuard: true,
    clientBridge: true,
    syncNav: true,
    normalizeInstall: true,
    normalizePrompt: true,
  };
  window.__SHIM_PLUGIN_FLAGS = __SHIM_PLUGIN_FLAGS;

  function ensureCodexPluginFeatures() {
    shimRuntimePlugins.tick(__SHIM_PLUGIN_FLAGS);
  }

  ns.runtime.plugins = {
    tick: shimRuntimePlugins.tick,
    ensureFeatures: ensureCodexPluginFeatures,
  };
})();

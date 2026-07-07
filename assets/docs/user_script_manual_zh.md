# ShimX 用户脚本手册

在 shimx 的脚本编辑器里,你可以写 JS 脚本注入到 Codex 网页。shimx 预置了一套 API 挂在 `window.shimxApi` 上,涵盖桥调用、DOM 观察、UI 提示等能力。

---

## 快速开始

新建脚本时会自动生成模板:

```js
// ==ShimX==
// @name        My Script
// @description 脚本描述
// @version     1.0.0
// @author
// @layer       user
// ==/ShimX==

(() => {
  if (!window.__shimxCodex) return;

  // 在这里编写你的注入逻辑
  console.log('[MyScript] loaded');
})();
```

推荐的写法(异步版本):

```js
(async () => {
  if (!window.shimxApi) return;

  // 等 shimx 后端桥就绪 (window.shimx 到位), 之后 bridge / subscribe 才可用
  const ready = await shimxApi.ready();
  if (!ready) {
    console.warn('[MyScript] shimx bridge timeout');
    return;
  }

  shimxApi.toast('MyScript 已启动', 'success');
})();
```

脚本在 Codex 页面 **document_start** 时刻注入,`shimx_api.js` 排在所有 codex_enhance 之后、你的脚本之前。`bridge.call` / `subscribe` 依赖 `window.shimx` binding,**必须先 `await shimxApi.ready()`**。

---

## API 总览

| 分类 | API | 用途 |
| --- | --- | --- |
| 生命周期 | `ready(timeoutMs?)` | 等 shimx 后端桥就绪 |
|  | `onReady(cb)` | 等 DOMContentLoaded |
| 后端通信 | `bridge.call(path, payload?, timeoutMs?)` | 调 shimx server RPC |
|  | `subscribe(topic, cb)` | 订阅 shimx server 主动推送 |
| UI 提示 | `toast(msg, kind?)` | 顶部 toast |
|  | `confirm(options)` | 确认对话框 |
|  | `busy(label)` / `withBusy(label, fn)` | 加载遮罩 |
| DOM | `waitFor(selector, opts?)` | 等元素出现 |
|  | `onMount(selector, cb, opts?)` | 元素每次挂载都触发 |
|  | `observe(target, cb, init?)` | MutationObserver 包装 |
|  | `onUrlChange(cb)` | SPA 路由变化 |

---

## 生命周期

### `shimxApi.ready(timeoutMs?): Promise<boolean>`

等 shimx Dart 侧通过 CDP 注入的 `window.shimx` 桥就绪。默认超时 8000 ms。返回 `true` 表示可用,`false` 表示超时(通常意味着页面不是 shimx 注入的,或者 debug 端口断了)。

调用 `bridge.call` 或 `subscribe` 之前 **必须** 调这个。

```js
if (!await shimxApi.ready()) return;
```

### `shimxApi.onReady(callback)`

等 `DOMContentLoaded`。如果调用时 DOM 已 ready,在下一个 microtask 里跑 callback。

```js
shimxApi.onReady(() => {
  console.log('DOM ready');
});
```

---

## 后端通信

### `shimxApi.bridge.call(path, payload?, timeoutMs?): Promise<Response>`

调 shimx 后端 RPC,返回 `{ ok: true, data }` 或 `{ ok: false, message }`。

```js
const res = await shimxApi.bridge.call('/provider/current', {});
if (res.ok) {
  shimxApi.toast('当前供应商: ' + res.data.label);
} else {
  shimxApi.toast('查询失败: ' + res.message, 'error');
}
```

`path` 是 shimx 后端注册的路由,常见的有 `/provider/current`, `/provider/list`,具体可用列表随 shimx 版本变化,可以在 shimx 主界面查看已启用的路由。

### `shimxApi.subscribe(topic, callback): { stop }`

订阅 shimx server 主动推送的事件。返回 `{ stop }` 手动取消。

```js
const sub = shimxApi.subscribe('/provider/auto-switched', (payload) => {
  if (payload.event === 'switched') {
    shimxApi.toast(`供应商切到了 ${payload.to}`, 'success');
  }
});
// 想停时: sub.stop();
```

---

## UI 提示

### `shimxApi.toast(message, kind?)`

顶部 toast,3 秒后自动消失。`kind` 可选 `'info' | 'success' | 'error' | 'warning'`,默认 `'info'`。

```js
shimxApi.toast('保存成功', 'success');
shimxApi.toast('网络出错', 'error');
```

### `shimxApi.confirm(options): Promise<boolean>`

确认对话框。返回 `true` 表示用户点了确认,`false` 表示取消/点蒙层/Esc。

```js
const ok = await shimxApi.confirm({
  title: '删除脚本',
  message: '确定要删除吗?操作不可撤销。',
  okText: '删除',
  cancelText: '取消',
  danger: true, // 确认按钮变红
});
if (ok) {
  // 执行删除
}
```

### `shimxApi.busy(label): { done }` 和 `shimxApi.withBusy(label, fn)`

长耗时任务的加载遮罩。

```js
// 手动控制
const b = shimxApi.busy('导出中...');
try {
  await doExport();
} finally {
  b.done();
}

// 或者用 withBusy 自动包裹
const result = await shimxApi.withBusy('拉取数据', async () => {
  return await shimxApi.bridge.call('/some/endpoint', {});
});
```

多个 busy 可以并发,只有全部 `done()` 后遮罩才消失。

---

## DOM 工具

Codex 是 React SPA,元素会随路由 / 侧栏折叠反复挂载卸载。

### `shimxApi.waitFor(selector, opts?): Promise<Element | null>`

等一个元素首次出现。默认超时 10 秒,超时返回 `null`。

```js
const btn = await shimxApi.waitFor('button[data-testid="submit"]');
if (btn) btn.click();

// 自定义超时和搜索根
const el = await shimxApi.waitFor('.item', { timeout: 3000, root: sidebar });
```

### `shimxApi.onMount(selector, callback, opts?): { stop }`

元素每次挂载都触发一次,同一个元素不会重复回调(内部用 WeakSet 记录)。

```js
// 给所有对话行加个复制按钮
shimxApi.onMount('[data-app-action-sidebar-thread-row]', (row) => {
  const btn = document.createElement('button');
  btn.textContent = '复制';
  btn.onclick = () => copyThread(row);
  row.appendChild(btn);
});

// 只需要触发一次
shimxApi.onMount('nav[role="navigation"]', (nav) => setup(nav), { once: true });
```

### `shimxApi.observe(target, callback, init?): { stop }`

MutationObserver 的直接包装。

```js
const sub = shimxApi.observe(
  document.title,
  (records) => console.log('title changed', records),
  { characterData: true, subtree: true },
);
```

### `shimxApi.onUrlChange(callback): { stop }`

SPA 路由变化通知(hook 了 `pushState` / `replaceState` + `popstate` + `hashchange`)。

```js
shimxApi.onUrlChange((url) => {
  if (url.includes('/settings')) {
    injectSettingsPanel();
  }
});
```

---

## 完整例子

一个在侧栏每条对话上加"复制标题"按钮的脚本:

```js
// ==ShimX==
// @name        Copy Thread Title
// @description 给侧栏每条对话加个「复制标题」按钮
// @version     1.0.0
// @layer       user
// ==/ShimX==

(async () => {
  if (!window.shimxApi) return;
  if (!await shimxApi.ready()) return;

  shimxApi.onMount('[data-app-action-sidebar-thread-row]', (row) => {
    if (row.querySelector('.__my_copy_btn')) return; // 兜底防重
    const btn = document.createElement('button');
    btn.className = '__my_copy_btn';
    btn.textContent = '复制';
    btn.style.marginLeft = '8px';
    btn.onclick = (e) => {
      e.stopPropagation();
      const title = row.getAttribute('data-app-action-sidebar-thread-title')
        || row.textContent.trim();
      navigator.clipboard.writeText(title);
      shimxApi.toast('已复制: ' + title, 'success');
    };
    row.appendChild(btn);
  });

  // 路由切换时提示
  shimxApi.onUrlChange((url) => {
    console.log('[CopyThread] url:', url);
  });
})();
```

---

## 调试建议

- 打开 shimx 编辑器状态栏的「控制台」按钮,可以直接看 Codex 页面的 DevTools console
- 用 `console.log` 输出到浏览器控制台,前缀最好加脚本名方便过滤
- 开发时可以打开「热运行」开关,Ctrl/Cmd+S 保存后自动重跑

## 注意事项

- 不要覆盖 `window.shimxApi`。
- 不要 patch `Array.prototype` / `Object.prototype` 等内置原型,页面里已经有其它代码在改这些原型,叠加会互相干扰。
- 不要 patch `window.fetch` / `XMLHttpRequest`,原因同上。

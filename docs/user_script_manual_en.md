# ShimX User Script Manual

In shimx's script editor you can write JS scripts that get injected into the Codex web app. ShimX installs an SDK at `window.shimxApi` covering bridge calls, DOM observation, and UI helpers.

---

## Quick start

The editor generates this template for a new script:

```js
// ==ShimX==
// @name        My Script
// @description Script description
// @version     1.0.0
// @author
// @layer       user
// ==/ShimX==

(() => {
  if (!window.__shimxCodex) return;

  // Your injection logic here
  console.log('[MyScript] loaded');
})();
```

Recommended pattern (async version):

```js
(async () => {
  if (!window.shimxApi) return;

  // Wait for the shimx backend bridge (window.shimx). Only after this
  // resolves can bridge / subscribe be used.
  const ok = await shimxApi.ready();
  if (!ok) {
    console.warn('[MyScript] shimx bridge timeout');
    return;
  }

  shimxApi.toast('MyScript started', 'success');
})();
```

Scripts are injected at **document_start** on the Codex page. `shimx_api.js` runs after all of `codex_enhance` and before your script. `bridge.call` / `subscribe` depend on the `window.shimx` binding — **always `await shimxApi.ready()` first**.

---

## API at a glance

| Group | API | Purpose |
| --- | --- | --- |
| Lifecycle | `ready(timeoutMs?)` | Wait for the shimx backend bridge |
|  | `onReady(cb)` | Wait for DOMContentLoaded |
| Backend | `bridge.call(path, payload?, timeoutMs?)` | Call a shimx server RPC |
|  | `subscribe(topic, cb)` | Subscribe to shimx server pushes |
| UI | `toast(msg, kind?)` | Top toast |
|  | `confirm(options)` | Confirm dialog |
|  | `busy(label)` / `withBusy(label, fn)` | Loading indicator |
| DOM | `waitFor(selector, opts?)` | Wait for an element |
|  | `onMount(selector, cb, opts?)` | Fires each time an element mounts |
|  | `observe(target, cb, init?)` | MutationObserver wrapper |
|  | `onUrlChange(cb)` | SPA route changes |

---

## Lifecycle

### `shimxApi.ready(timeoutMs?): Promise<boolean>`

Waits for the `window.shimx` binding that shimx's Dart side installs via CDP. Default timeout 8000 ms. Returns `true` if the bridge is available, `false` on timeout (usually means the page isn't a shimx-injected one, or the debug port dropped).

**Always call this** before `bridge.call` or `subscribe`.

```js
if (!await shimxApi.ready()) return;
```

### `shimxApi.onReady(callback)`

Waits for `DOMContentLoaded`. If the DOM is already ready when called, the callback runs on the next microtask.

```js
shimxApi.onReady(() => {
  console.log('DOM ready');
});
```

---

## Backend communication

### `shimxApi.bridge.call(path, payload?, timeoutMs?): Promise<Response>`

Calls a shimx backend RPC. Returns `{ ok: true, data }` or `{ ok: false, message }`.

```js
const res = await shimxApi.bridge.call('/provider/current', {});
if (res.ok) {
  shimxApi.toast('Current provider: ' + res.data.label);
} else {
  shimxApi.toast('Query failed: ' + res.message, 'error');
}
```

`path` is a route registered by the shimx backend. Common ones are `/provider/current`, `/provider/list`. The exact set depends on the shimx version — check the shimx home page to see which routes are enabled.

### `shimxApi.subscribe(topic, callback): { stop }`

Subscribes to events pushed from the shimx server. Returns `{ stop }` for manual cancellation.

```js
const sub = shimxApi.subscribe('/provider/auto-switched', (payload) => {
  if (payload.event === 'switched') {
    shimxApi.toast(`Provider switched to ${payload.to}`, 'success');
  }
});
// Later: sub.stop();
```

---

## UI helpers

### `shimxApi.toast(message, kind?)`

Top-of-page toast, auto-dismisses after 3 s. `kind` is one of `'info' | 'success' | 'error' | 'warning'`, default `'info'`.

```js
shimxApi.toast('Saved', 'success');
shimxApi.toast('Network error', 'error');
```

### `shimxApi.confirm(options): Promise<boolean>`

Confirm dialog. Resolves to `true` on confirm, `false` on cancel / overlay click / Esc.

```js
const ok = await shimxApi.confirm({
  title: 'Delete script',
  message: 'Really delete? This cannot be undone.',
  okText: 'Delete',
  cancelText: 'Cancel',
  danger: true, // makes the confirm button red
});
if (ok) {
  // perform delete
}
```

### `shimxApi.busy(label): { done }` and `shimxApi.withBusy(label, fn)`

Loading overlay for long-running tasks.

```js
// Manual control
const b = shimxApi.busy('Exporting...');
try {
  await doExport();
} finally {
  b.done();
}

// Or auto-wrap
const result = await shimxApi.withBusy('Fetching data', async () => {
  return await shimxApi.bridge.call('/some/endpoint', {});
});
```

Multiple busies can be shown concurrently — the overlay only clears once every `done()` has been called.

---

## DOM helpers

Codex is a React SPA and elements mount / unmount as you navigate or collapse the sidebar.

### `shimxApi.waitFor(selector, opts?): Promise<Element | null>`

Waits for the first appearance of an element. Default timeout 10 s. Returns `null` on timeout.

```js
const btn = await shimxApi.waitFor('button[data-testid="submit"]');
if (btn) btn.click();

// Custom timeout and search root
const el = await shimxApi.waitFor('.item', { timeout: 3000, root: sidebar });
```

### `shimxApi.onMount(selector, callback, opts?): { stop }`

Fires once per mount. The same element instance won't be reprocessed (tracked with a WeakSet).

```js
// Add a copy button to every thread row
shimxApi.onMount('[data-app-action-sidebar-thread-row]', (row) => {
  const btn = document.createElement('button');
  btn.textContent = 'Copy';
  btn.onclick = () => copyThread(row);
  row.appendChild(btn);
});

// Only fire once
shimxApi.onMount('nav[role="navigation"]', (nav) => setup(nav), { once: true });
```

### `shimxApi.observe(target, callback, init?): { stop }`

Thin wrapper around `MutationObserver`.

```js
const sub = shimxApi.observe(
  document.title,
  (records) => console.log('title changed', records),
  { characterData: true, subtree: true },
);
```

### `shimxApi.onUrlChange(callback): { stop }`

Notifies on SPA route changes (hooks `pushState` / `replaceState` + `popstate` + `hashchange`).

```js
shimxApi.onUrlChange((url) => {
  if (url.includes('/settings')) {
    injectSettingsPanel();
  }
});
```

---

## Complete example

Add a "Copy title" button to every thread in the sidebar:

```js
// ==ShimX==
// @name        Copy Thread Title
// @description Add a "Copy" button to every thread row
// @version     1.0.0
// @layer       user
// ==/ShimX==

(async () => {
  if (!window.shimxApi) return;
  if (!await shimxApi.ready()) return;

  shimxApi.onMount('[data-app-action-sidebar-thread-row]', (row) => {
    if (row.querySelector('.__my_copy_btn')) return;
    const btn = document.createElement('button');
    btn.className = '__my_copy_btn';
    btn.textContent = 'Copy';
    btn.style.marginLeft = '8px';
    btn.onclick = (e) => {
      e.stopPropagation();
      const title = row.getAttribute('data-app-action-sidebar-thread-title')
        || row.textContent.trim();
      navigator.clipboard.writeText(title);
      shimxApi.toast('Copied: ' + title, 'success');
    };
    row.appendChild(btn);
  });

  shimxApi.onUrlChange((url) => {
    console.log('[CopyThread] url:', url);
  });
})();
```

---

## Debugging tips

- Click the "Console" button in the script editor status bar to open the Codex page's DevTools.
- `console.log` goes to the browser console — prefix messages with your script name for easier filtering.
- While iterating, turn on the "Hot run" switch — Ctrl/Cmd+S will save and re-run automatically.

## Caveats

- Do not overwrite `window.shimxApi`.
- Do not patch `Array.prototype` / `Object.prototype` or other built-in prototypes — other code on the page already patches these, and stacking will interfere.
- Do not patch `window.fetch` / `XMLHttpRequest` for the same reason.

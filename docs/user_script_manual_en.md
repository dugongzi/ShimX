# Shim User Script Manual

In shim's script editor you can write JS scripts that get injected into the Codex web app. Shim installs an SDK at `window.shimApi` covering bridge calls, DOM observation, and UI helpers.

---

## Quick start

The editor generates this template for a new script:

```js
// ==Shim==
// @name        My Script
// @description Script description
// @version     1.0.0
// @author
// @layer       user
// ==/Shim==

(() => {
  if (!window.__shimCodex) return;

  // Your injection logic here
  console.log('[MyScript] loaded');
})();
```

Recommended pattern (async version):

```js
(async () => {
  if (!window.shimApi) return;

  // Wait for the shim backend bridge (window.shim). Only after this
  // resolves can bridge / subscribe be used.
  const ok = await shimApi.ready();
  if (!ok) {
    console.warn('[MyScript] shim bridge timeout');
    return;
  }

  shimApi.toast('MyScript started', 'success');
})();
```

Scripts are injected at **document_start** on the Codex page. `shim_api.js` runs after all of `codex_enhance` and before your script. `bridge.call` / `subscribe` depend on the `window.shim` binding — **always `await shimApi.ready()` first**.

---

## API at a glance

| Group | API | Purpose |
| --- | --- | --- |
| Lifecycle | `ready(timeoutMs?)` | Wait for the shim backend bridge |
|  | `onReady(cb)` | Wait for DOMContentLoaded |
| Backend | `bridge.call(path, payload?, timeoutMs?)` | Call a shim server RPC |
|  | `subscribe(topic, cb)` | Subscribe to shim server pushes |
| UI | `toast(msg, kind?)` | Top toast |
|  | `confirm(options)` | Confirm dialog |
|  | `busy(label)` / `withBusy(label, fn)` | Loading indicator |
| DOM | `waitFor(selector, opts?)` | Wait for an element |
|  | `onMount(selector, cb, opts?)` | Fires each time an element mounts |
|  | `observe(target, cb, init?)` | MutationObserver wrapper |
|  | `onUrlChange(cb)` | SPA route changes |

---

## Lifecycle

### `shimApi.ready(timeoutMs?): Promise<boolean>`

Waits for the `window.shim` binding that shim's Dart side installs via CDP. Default timeout 8000 ms. Returns `true` if the bridge is available, `false` on timeout (usually means the page isn't a shim-injected one, or the debug port dropped).

**Always call this** before `bridge.call` or `subscribe`.

```js
if (!await shimApi.ready()) return;
```

### `shimApi.onReady(callback)`

Waits for `DOMContentLoaded`. If the DOM is already ready when called, the callback runs on the next microtask.

```js
shimApi.onReady(() => {
  console.log('DOM ready');
});
```

---

## Backend communication

### `shimApi.bridge.call(path, payload?, timeoutMs?): Promise<Response>`

Calls a shim backend RPC. Returns `{ ok: true, data }` or `{ ok: false, message }`.

```js
const res = await shimApi.bridge.call('/provider/current', {});
if (res.ok) {
  shimApi.toast('Current provider: ' + res.data.label);
} else {
  shimApi.toast('Query failed: ' + res.message, 'error');
}
```

`path` is a route registered by the shim backend. Common ones are `/provider/current`, `/provider/list`. The exact set depends on the shim version — check the shim home page to see which routes are enabled.

### `shimApi.subscribe(topic, callback): { stop }`

Subscribes to events pushed from the shim server. Returns `{ stop }` for manual cancellation.

```js
const sub = shimApi.subscribe('/provider/auto-switched', (payload) => {
  if (payload.event === 'switched') {
    shimApi.toast(`Provider switched to ${payload.to}`, 'success');
  }
});
// Later: sub.stop();
```

---

## UI helpers

### `shimApi.toast(message, kind?)`

Top-of-page toast, auto-dismisses after 3 s. `kind` is one of `'info' | 'success' | 'error' | 'warning'`, default `'info'`.

```js
shimApi.toast('Saved', 'success');
shimApi.toast('Network error', 'error');
```

### `shimApi.confirm(options): Promise<boolean>`

Confirm dialog. Resolves to `true` on confirm, `false` on cancel / overlay click / Esc.

```js
const ok = await shimApi.confirm({
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

### `shimApi.busy(label): { done }` and `shimApi.withBusy(label, fn)`

Loading overlay for long-running tasks.

```js
// Manual control
const b = shimApi.busy('Exporting...');
try {
  await doExport();
} finally {
  b.done();
}

// Or auto-wrap
const result = await shimApi.withBusy('Fetching data', async () => {
  return await shimApi.bridge.call('/some/endpoint', {});
});
```

Multiple busies can be shown concurrently — the overlay only clears once every `done()` has been called.

---

## DOM helpers

Codex is a React SPA and elements mount / unmount as you navigate or collapse the sidebar.

### `shimApi.waitFor(selector, opts?): Promise<Element | null>`

Waits for the first appearance of an element. Default timeout 10 s. Returns `null` on timeout.

```js
const btn = await shimApi.waitFor('button[data-testid="submit"]');
if (btn) btn.click();

// Custom timeout and search root
const el = await shimApi.waitFor('.item', { timeout: 3000, root: sidebar });
```

### `shimApi.onMount(selector, callback, opts?): { stop }`

Fires once per mount. The same element instance won't be reprocessed (tracked with a WeakSet).

```js
// Add a copy button to every thread row
shimApi.onMount('[data-app-action-sidebar-thread-row]', (row) => {
  const btn = document.createElement('button');
  btn.textContent = 'Copy';
  btn.onclick = () => copyThread(row);
  row.appendChild(btn);
});

// Only fire once
shimApi.onMount('nav[role="navigation"]', (nav) => setup(nav), { once: true });
```

### `shimApi.observe(target, callback, init?): { stop }`

Thin wrapper around `MutationObserver`.

```js
const sub = shimApi.observe(
  document.title,
  (records) => console.log('title changed', records),
  { characterData: true, subtree: true },
);
```

### `shimApi.onUrlChange(callback): { stop }`

Notifies on SPA route changes (hooks `pushState` / `replaceState` + `popstate` + `hashchange`).

```js
shimApi.onUrlChange((url) => {
  if (url.includes('/settings')) {
    injectSettingsPanel();
  }
});
```

---

## Complete example

Add a "Copy title" button to every thread in the sidebar:

```js
// ==Shim==
// @name        Copy Thread Title
// @description Add a "Copy" button to every thread row
// @version     1.0.0
// @layer       user
// ==/Shim==

(async () => {
  if (!window.shimApi) return;
  if (!await shimApi.ready()) return;

  shimApi.onMount('[data-app-action-sidebar-thread-row]', (row) => {
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
      shimApi.toast('Copied: ' + title, 'success');
    };
    row.appendChild(btn);
  });

  shimApi.onUrlChange((url) => {
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

- Do not overwrite `window.shimApi`.
- Do not patch `Array.prototype` / `Object.prototype` or other built-in prototypes — other code on the page already patches these, and stacking will interfere.
- Do not patch `window.fetch` / `XMLHttpRequest` for the same reason.

// ==Shim==
// @name        Shim codex_enhance — features/shim_menu
// @description 侧栏 Shim 入口菜单项。挂在 Claude bridge 按钮 / 面板下方一行,
//              点击打开 features/control_panel 的浮层。
//              对外: ensure() — 由 runtime/scheduler 在 ensureAll 里每轮调一次。
// @layer       features
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ns = window.__shimCodex;
  const ids = ns.ids;

  function findInsertAnchor() {
    // 优先挂在 Claude bridge 折叠面板下面 (展开时), 否则挂在按钮下面
    const panel = document.getElementById(ids.navPanel);
    if (panel) return panel;
    return document.getElementById(ids.navBtn);
  }

  function buildItem() {
    const item = document.createElement('button');
    item.id = ids.menuItem;
    item.type = 'button';
    item.className =
      'focus-visible:outline-token-border relative h-token-nav-row px-row-x py-row-y cursor-interaction shrink-0 items-center overflow-hidden rounded-lg text-left text-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50 gap-2 flex w-full hover:bg-token-list-hover-background';

    const row = document.createElement('div');
    row.className = 'flex min-w-0 items-center text-base gap-2 flex-1 text-token-foreground';

    const iconWrap = document.createElement('span');
    iconWrap.style.display = 'inline-flex';
    iconWrap.style.color = '#1296db';
    iconWrap.innerHTML = ids.shimIconSvg;

    const label = document.createElement('span');
    label.className = 'flex-1 min-w-0 truncate';
    label.textContent = 'Shim';

    const statusDot = document.createElement('span');
    statusDot.setAttribute('aria-hidden', 'true');
    Object.assign(statusDot.style, {
      width: '8px',
      height: '8px',
      borderRadius: '999px',
      background: '#60a5fa',
      boxShadow: '0 0 8px rgba(96, 165, 250, 0.48)',
      flex: '0 0 auto',
    });

    row.appendChild(iconWrap);
    row.appendChild(label);
    row.appendChild(statusDot);
    item.appendChild(row);

    item.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      ns.features.controlPanel.togglePopover(item);
    });
    item.addEventListener('mouseenter', () => {
      item.setAttribute('data-highlighted', '');
    });
    item.addEventListener('mouseleave', () => {
      item.removeAttribute('data-highlighted');
    });

    return item;
  }

  function ensure() {
    const navList = ns.features.claudeBridge.findNavList();
    if (!navList) return;
    const anchor = findInsertAnchor();
    if (!anchor || anchor.parentElement !== navList) return;

    const existing = document.getElementById(ids.menuItem);
    if (existing && existing.parentElement === navList && existing.previousElementSibling === anchor) {
      return;
    }
    ns.runtime?.trace?.t?.('ensureShimMenuItem: INSERT into nav');
    existing?.remove();
    const item = buildItem();
    anchor.insertAdjacentElement('afterend', item);
  }

  ns.features.shimMenu = { ensure };
})();

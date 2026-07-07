// ==ShimX==
// @name        ShimX codex_enhance — core/constants
// @description 所有跨分片共享的 DOM id / SVG / 选择器常量, 挂在 window.__shimxCodex.ids 下。
// @layer       core
// ==/ShimX==

(() => {
  if (!window.__shimxCodexEnhanceLoaded) return;

  Object.assign(window.__shimxCodex.ids, {
    badge: '__shimx_injected_badge__',
    menuItem: '__shimx_menu_item__',
    popover: '__shimx_popover__',
    providerPicker: '__shimx_provider_picker__',
    providerPickerPopover: '__shimx_provider_picker_popover__',
    toastContainer: '__shimx_toast_container__',
    confirmDialog: '__shimx_confirm_dialog__',
    threadMenu: '__shimx_thread_menu__',
    threadActionsMenu: '__shimx_thread_actions_menu__',
    exportMenu: '__shimx_export_menu__',
    importMenu: '__shimx_import_menu__',
    busyContainer: '__shimx_busy_container__',
    busyDim: '__shimx_busy_dim__',
    busyKeyframes: '__shimx_busy_kf__',
    navBtn: '__shimx_claude_bridge_nav__',
    navPanel: '__shimx_claude_bridge_panel__',
    claudeBridgeChip: '__shimx_claude_bridge_chip__',
    pluginMenuItem: '__shimx_plugin_menu_item__',
    pluginPanel: '__shimx_plugin_panel__',
    polishButton: '__shimx_polish_button__',
    polishPopover: '__shimx_polish_popover__',

    providerBadgeClass: '__shimx_provider_badge__',
    deleteButtonFlag: 'data-shimx-delete-added',
    codexModelSelectorFlag: 'data-shimx-hidden-codex-model-selector',

    badgeAnchorSvgD: 'M16.835 8.66301C16.835 7.71885',
    sendButtonSvgD: 'M9.33467 16.6663V4.93978',

    shimxIconSvg: `
      <svg viewBox="0 0 1210 1024" width="20" height="20" xmlns="http://www.w3.org/2000/svg" class="icon-xs shrink-0 opacity-75 group-focus:opacity-100 group-hover:opacity-100">
        <path d="M929.170154 428.766111a24.122983 24.122983 0 0 1 24.205717 24.169078v108.663343a29.35416 29.35416 0 0 0 29.237151 29.350614h214.831653c14.863823 0 17.889538 21.483756 3.44175 25.411276L768.803729 740.837852a23.561571 23.561571 0 0 1-29.311611-15.998467 20.064271 20.064271 0 0 1-0.945536-6.694393v-113.582493a10.712921 10.712921 0 0 0-10.55218-10.590002H254.267944a10.657371 10.657371 0 0 1-10.55218-10.438716V455.959722a32.661172 32.661172 0 0 0-31.960294-32.787638l-201.635518-3.517393c-11.838109-0.491679-14.031752-17.137837-2.609679-20.57486l441.769711-127.540966a10.503721 10.503721 0 0 1 12.821466 7.37518 11.305063 11.305063 0 0 1 0.340393 2.685321v123.111131a24.320364 24.320364 0 0 0 24.169078 24.093435zM443.152911 135.94548c15.393324-2.609679 18.910717 17.549145 18.910717 17.549145s1.248107 47.769653 0 67.474619c-1.361572 19.667146-19.326753 18.910717-19.326752 18.910717H267.429803s-15.885002-5.711036-18.003003-26.3249c-2.685322-20.57486 21.89861-32.073757 21.89861-32.073757s156.54646-42.928509 171.714037-45.538188z m296.791882-55.674333s-2.269286-23.260182 23.756588-33.284043C789.526329 37.342638 928.489368 1.411094 928.489368 1.411094s25.833221-10.098323 27.573007 23.756588c1.77288 33.700079 0 311.543423 0 311.543423s0.907714 22.730682-23.638396 24.509471c-24.622935 1.77288-162.632165 0-162.632165 0s-29.842293 2.685322-29.842293-21.028717z m3.933429 722.785327c1.248107-19.704967 19.326753-18.910717 18.910717-19.364574h175.23143s15.393324 5.711036 18.003003 26.3249c2.685322 20.57486-21.974253 32.030027-21.974253 32.030027s-156.432996 42.928509-171.751858 45.503912c-15.393324 3.139179-18.419038-17.095288-18.419039-17.095288s-1.248107-47.656188 0-67.361155z m-278.259379 140.699279s2.571857 23.260182-23.756588 33.284044c-25.871043 9.57355-164.791532 45.538188-164.791532 45.538188s-25.908864 10.136144-27.563552-23.715221c-1.77288-33.700079 0-311.543423 0-311.543423s-0.907714-22.730682 23.638396-24.509471 162.632165 0 162.632165 0 26.665293-2.685322 29.842293 21.028717c2.987893 23.185721 0 39.830697 0 39.830698z" fill="currentColor"></path>
      </svg>
    `,

    pluginIconSvg: `
      <svg viewBox="0 0 1032 1024" width="20" height="20" xmlns="http://www.w3.org/2000/svg" class="icon-xs shrink-0 opacity-75 group-focus:opacity-100 group-hover:opacity-100">
        <path d="M512 512m-512 0a512 512 0 1 0 1024 0 512 512 0 1 0-1024 0Z" fill="#0090FD"></path>
        <path d="M686.08 372.736c-8.192 8.192-22.528 8.192-30.72 0-8.192-8.192-8.192-22.528 0-30.72l79.872-79.872c8.192-8.192 22.528-8.192 30.72 0 8.192 8.192 8.192 22.528 0 30.72l-79.872 79.872z m-83.968 40.96c-10.24 0-18.432-6.144-20.48-14.336-20.48-12.288-43.008-20.48-69.632-20.48-28.672 0-55.296 10.24-77.824 24.576l-32.768-32.768c30.72-24.576 67.584-36.864 110.592-36.864 40.96 0 79.872 14.336 110.592 36.864l-4.096 4.096c4.096 4.096 6.144 8.192 6.144 14.336 0 14.336-10.24 24.576-22.528 24.576z m-190.464 12.288c0 10.24-6.144 18.432-14.336 20.48-12.288 20.48-20.48 43.008-20.48 69.632 0 28.672 10.24 55.296 24.576 77.824l-32.768 32.768c-24.576-30.72-36.864-67.584-36.864-110.592 0-40.96 14.336-79.872 36.864-110.592l4.096 4.096c4.096-4.096 8.192-6.144 14.336-6.144 14.336 0 24.576 10.24 24.576 22.528z m-73.728-53.248l-79.872-79.872c-8.192-8.192-8.192-22.528 0-30.72 8.192-8.192 22.528-8.192 30.72 0l79.872 79.872c8.192 8.192 8.192 22.528 0 30.72-8.192 8.192-22.528 8.192-30.72 0z m0 284.672c8.192-8.192 22.528-8.192 30.72 0 8.192 8.192 8.192 22.528 0 30.72l-79.872 79.872c-8.192 8.192-22.528 8.192-30.72 0s-8.192-22.528 0-30.72l79.872-79.872z m83.968-40.96c10.24 0 18.432 6.144 20.48 14.336 20.48 12.288 43.008 20.48 69.632 20.48 28.672 0 55.296-10.24 77.824-24.576l32.768 32.768c-30.72 24.576-67.584 36.864-110.592 36.864-40.96 0-79.872-14.336-110.592-36.864l4.096-4.096c-4.096-4.096-6.144-8.192-6.144-14.336 0-14.336 10.24-24.576 22.528-24.576z m190.464-12.288c0-10.24 6.144-18.432 14.336-20.48 12.288-20.48 20.48-43.008 20.48-69.632 0-28.672-10.24-55.296-24.576-77.824l32.768-32.768c24.576 30.72 36.864 67.584 36.864 110.592 0 40.96-14.336 79.872-36.864 110.592l-4.096-4.096c-4.096 4.096-8.192 6.144-14.336 6.144-14.336 0-24.576-10.24-24.576-22.528z m73.728 53.248l79.872 79.872c8.192 8.192 8.192 22.528 0 30.72-8.192 8.192-22.528 8.192-30.72 0l-79.872-79.872c-8.192-8.192-8.192-22.528 0-30.72 8.192-8.192 22.528-8.192 30.72 0z" fill="#FFFFFF"></path>
      </svg>
    `,

    // ensureAll 后由 runtime/scheduler 用来识别"我们自己的 DOM" 和"值得观察的 DOM"
    selfNodeSelectors: [
      '#__shimx_injected_badge__',
      '#__shimx_menu_item__',
      '#__shimx_plugin_menu_item__',
      '#__shimx_plugin_panel__',
      '#__shimx_polish_button__',
      '#__shimx_polish_popover__',
      '#__shimx_popover__',
      '#__shimx_provider_picker__',
      '#__shimx_provider_picker_popover__',
      '#__shimx_toast_container__',
      '#__shimx_confirm_dialog__',
      '.__shimx_provider_badge__',
      '[data-shimx-delete-added]',
      '[data-shimx-nav-handled]',
      '[data-shimx-install-ready]',
      '[data-shimx-prompt-ready]',
      '[data-shimx-clear-model]',
    ].join(', '),

    watchTargetSelectors: [
      '[data-app-action-sidebar-thread-row]',
      '[data-app-action-sidebar-thread-id]',
      'button[aria-label="归档对话"]',
      'nav[role="navigation"]',
      'button[class*="h-[var(--height-token-row)]"]',
      '[data-codex-intelligence-trigger]',
      '[data-turn-key]',
      '[role="menu"]',
      '[role="menuitem"]',
      '.composer-footer',
      'button[aria-disabled="true"]',
      'button.cursor-not-allowed',
      'button[disabled]',
    ].join(', '),
  });
})();

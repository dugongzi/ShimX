// ==Shim==
// @name        Shim codex_enhance — ui/confirm
// @description 删除确认对话框 (用 Codex 主题), 跨 feature 复用。
//              showDelete(title) → Promise<bool>, true 表示用户确认, false 表示取消。
//              Enter 确认 / Escape 取消 / 点蒙层取消, 关弹窗时自动清 keydown 监听。
// @layer       ui
// ==/Shim==

(() => {
  if (!window.__shimCodexEnhanceLoaded) return;
  const ids = window.__shimCodex.ids;
  const S = (k, f) => window.__shimCodex.i18n.S(k, f);

  function showDelete(title) {
    return new Promise((resolve) => {
      document.getElementById(ids.confirmDialog)?.remove();

      const overlay = document.createElement('div');
      overlay.id = ids.confirmDialog;
      Object.assign(overlay.style, {
        position: 'fixed',
        inset: '0',
        zIndex: '2147483647',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'rgba(0, 0, 0, 0.4)',
        backdropFilter: 'blur(2px)',
      });

      const dialog = document.createElement('div');
      dialog.setAttribute('role', 'dialog');
      dialog.setAttribute('aria-modal', 'true');
      dialog.className =
        'bg-token-dropdown-background/95 text-token-foreground ring-token-border shadow-xl-spread backdrop-blur-sm';
      Object.assign(dialog.style, {
        minWidth: '320px',
        maxWidth: '420px',
        padding: '20px 22px',
        borderRadius: '16px',
        outline: '0.5px solid var(--token-border, rgba(127,127,127,0.18))',
        boxShadow: '0 24px 64px rgba(0, 0, 0, 0.4)',
      });

      const heading = document.createElement('div');
      heading.textContent = S('deleteHeading', 'Delete thread');
      Object.assign(heading.style, {
        fontSize: '15px',
        fontWeight: '700',
        marginBottom: '8px',
      });

      const desc = document.createElement('div');
      desc.className = 'text-token-description-foreground';
      desc.style.fontSize = '13px';
      desc.style.lineHeight = '1.5';
      desc.style.marginBottom = '18px';
      desc.textContent =
        S('deleteConfirmPrefix', 'Delete "') + title +
        S('deleteConfirmSuffix', '"? This cannot be undone.');

      const actions = document.createElement('div');
      Object.assign(actions.style, {
        display: 'flex',
        justifyContent: 'flex-end',
        gap: '8px',
      });

      const cancelBtn = document.createElement('button');
      cancelBtn.type = 'button';
      cancelBtn.textContent = S('cancel', 'Cancel');
      cancelBtn.className =
        'border-token-border no-drag cursor-interaction flex items-center gap-1 border whitespace-nowrap select-none focus:outline-none rounded-full text-token-foreground hover:bg-token-list-hover-background px-3 py-1.5 text-sm';

      const okBtn = document.createElement('button');
      okBtn.type = 'button';
      okBtn.textContent = S('deleteOk', 'Delete');
      okBtn.className =
        'no-drag cursor-interaction flex items-center gap-1 whitespace-nowrap select-none focus:outline-none rounded-full px-3 py-1.5 text-sm font-semibold';
      Object.assign(okBtn.style, {
        background: '#dc2626',
        color: '#fff',
        border: '0',
      });
      okBtn.addEventListener('mouseenter', () => {
        okBtn.style.background = '#b91c1c';
      });
      okBtn.addEventListener('mouseleave', () => {
        okBtn.style.background = '#dc2626';
      });

      actions.appendChild(cancelBtn);
      actions.appendChild(okBtn);
      dialog.appendChild(heading);
      dialog.appendChild(desc);
      dialog.appendChild(actions);
      overlay.appendChild(dialog);
      document.body.appendChild(overlay);

      const cleanup = (result) => {
        document.removeEventListener('keydown', onKey, true);
        overlay.remove();
        resolve(result);
      };
      const onKey = (e) => {
        if (e.key === 'Escape') cleanup(false);
        if (e.key === 'Enter') cleanup(true);
      };

      overlay.addEventListener('mousedown', (e) => {
        if (e.target === overlay) cleanup(false);
      });
      cancelBtn.addEventListener('click', () => cleanup(false));
      okBtn.addEventListener('click', () => cleanup(true));
      document.addEventListener('keydown', onKey, true);

      setTimeout(() => okBtn.focus(), 0);
    });
  }

  window.__shimCodex.ui.confirm = { showDelete };
})();

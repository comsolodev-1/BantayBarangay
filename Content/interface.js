(() => {
    const form = document.querySelector('form');
    if (!form) return;
    for (const input of form.querySelectorAll('input[type=password]')) {
        const wrap = document.createElement('span');
        wrap.className = 'password-wrap';
        input.before(wrap);
        const eye = document.createElement('button');
        eye.type = 'button';
        wrap.append(input, eye);
        // The icon shows the field's current state: open eye = password visible, slashed eye = hidden.
        const drawEye = () => {
            const visible = input.type === 'text';
            eye.innerHTML = '<svg aria-hidden="true" viewBox="0 0 24 24" width="20" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12Q12 -2 22 12Q12 26 2 12Z"/><circle cx="12" cy="12" r="3"/>' + (visible ? '' : '<path d="M4 4L20 20"/>') + '</svg>';
            eye.title = visible ? 'Password is visible. Click to hide.' : 'Password is hidden. Click to show.';
            eye.setAttribute('aria-label', visible ? 'Hide password' : 'Show password');
            eye.setAttribute('aria-pressed', String(visible));
        };
        drawEye();
        eye.onclick = () => {
            input.type = input.type === 'password' ? 'text' : 'password';
            drawEye();
        };
    }
    const audience = form.querySelector('[id$=ddlVisibility]');
    if (audience) {
        const list = form.querySelector('.audience-list');
        const updateAudience = () => {
            const specific = audience.value === 'Specific Barangay';
            list.hidden = !specific;
            const picker = list.closest('.target-picker');
            if (picker) {
                picker.hidden = !specific;
                if (!specific) picker.open = false;
                const count = list.querySelectorAll(':checked').length;
                picker.querySelector('summary').textContent = count ? count + ' selected' : 'Select barangays';
            }
            form.querySelector('.audience-required')?.toggleAttribute('hidden', !specific);
            list.querySelectorAll('input').forEach(input => input.disabled = !specific);
            form.querySelector('.all-targets').hidden = specific;
        };
        if (list) {
            audience.addEventListener('change', updateAudience);
            list.addEventListener('change', updateAudience);
            updateAudience();
        }
    }
    if (form.querySelector('[id$=txtUsername]')) {
        const lockSeconds = parseInt(form.dataset.lockSeconds, 10);
        if (lockSeconds > 0) {
            const locked = form.querySelectorAll('[id$=txtUsername],[id$=txtPassword],[id$=btnLogin]');
            locked.forEach(control => control.disabled = true);
            const notice = form.querySelector('[role=status]');
            const text = notice && (notice.querySelector('span') || notice);
            const endsAt = Date.now() + lockSeconds * 1000;
            if (notice) notice.setAttribute('aria-live', 'off');
            const tick = () => {
                const left = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000));
                if (left === 0) {
                    clearInterval(timer);
                    locked.forEach(control => control.disabled = false);
                    if (notice) notice.remove();
                    form.querySelector('[id$=txtUsername]').focus();
                    return;
                }
                if (text) text.textContent = 'Too many failed attempts. Please try again in ' + Math.floor(left / 60) + ':' + String(left % 60).padStart(2, '0') + '.';
            };
            const timer = setInterval(tick, 1000);
            tick();
        }
        window.addEventListener('pageshow', event => {
            if (event.persisted || new URLSearchParams(location.search).has('signedout')) {
                form.querySelector('[id$=txtUsername]').value = '';
                form.querySelector('[id$=txtPassword]').value = '';
            }
        });
    }
    for (const box of form.querySelectorAll('input[data-live]')) {
        const saved = 'live:' + location.pathname + ':' + box.name;
        let timer;
        const apply = () => {
            clearTimeout(timer);
            try { sessionStorage.setItem(saved, JSON.stringify({ value: box.value, start: box.selectionStart, end: box.selectionEnd, at: Date.now() })); } catch (e) { }
            __doPostBack(box.name, '');
        };
        box.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(apply, 350); });
        box.addEventListener('change', () => clearTimeout(timer));
        let last = null;
        try { last = JSON.parse(sessionStorage.getItem(saved)); sessionStorage.removeItem(saved); } catch (e) { }
        if (last && Date.now() - last.at < 10000) {
            box.focus();
            const lost = box.value !== last.value;
            if (lost) box.value = last.value;
            box.setSelectionRange(last.start, last.end);
            if (lost) timer = setTimeout(apply, 350);
        }
    }
    if (typeof HTMLDialogElement === 'undefined') return;
    const portraitDialog = form.querySelector('[data-portrait-dialog]');
    if (portraitDialog) {
        const photo = portraitDialog.querySelector('img');
        let portraitLink;
        for (const link of form.querySelectorAll('[data-portrait-name]')) {
            link.addEventListener('click', event => {
                if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
                event.preventDefault();
                portraitLink = link;
                photo.src = link.href;
                portraitDialog.querySelector('[data-official-name]').textContent = link.dataset.portraitName;
                portraitDialog.querySelector('[data-official-position]').textContent = link.dataset.portraitPosition;
                portraitDialog.showModal();
            });
        }
        portraitDialog.querySelector('[data-dialog-close]').addEventListener('click', () => portraitDialog.close());
        portraitDialog.addEventListener('close', () => portraitLink?.focus());
    }
    const zone = form.querySelector('.dropzone');
    if (zone) {
        zone.addEventListener('dragover', event => event.preventDefault());
        zone.addEventListener('drop', event => {
            event.preventDefault();
            if (event.dataTransfer.files.length === 1) zone.querySelector('input').files = event.dataTransfer.files;
        });
    }
    for (const panel of form.querySelectorAll('.workflow')) {
        const title = panel.querySelector('[role=heading]');
        if (!title) continue;
        const dialog = document.createElement('dialog');
        dialog.className = 'workflow-dialog';
        dialog.setAttribute('aria-label', title.textContent.trim());

        const header = document.createElement('header');
        header.className = 'modal-title';
        const oldTitleRow = title.closest('p');
        const titleSlot = document.createElement('span');
        titleSlot.textContent = title.textContent.trim();
        header.append(titleSlot);
        (oldTitleRow || title).remove();

        const dismiss = panel.querySelector('input[value=Cancel],input[value=Close]');
        const close = document.createElement('button');
        close.type = 'button';
        close.textContent = '\u00d7';
        close.setAttribute('aria-label', 'Close dialog');
        close.addEventListener('click', () => dismiss ? dismiss.click() : dialog.close());
        panel.querySelector('[data-dialog-close]')?.addEventListener('click', () => dialog.close());
        header.append(close);
        dialog.addEventListener('cancel', event => {
            event.preventDefault();
            close.click();
        });

        const notice = form.querySelector('[role=status]');
        if (notice && !panel.contains(notice)) panel.prepend(notice);
        dialog.append(header, panel);
        form.append(dialog);
        dialog.showModal();
    }
    for (const action of form.querySelectorAll('[data-confirm]')) {
        let confirmed = false;
        action.addEventListener('click', e => {
            if (confirmed) return;
            e.preventDefault();
            e.stopImmediatePropagation();
            const dialog = document.createElement('dialog');
            dialog.className = 'confirm-box';
            dialog.setAttribute('aria-label', 'Confirm action');
            const prompt = document.createElement('h2');
            prompt.textContent = action.dataset.confirm;
            const cancel = document.createElement('button');
            const accept = document.createElement('button');
            cancel.type = accept.type = 'button';
            cancel.textContent = 'Cancel';
            accept.textContent = action.value || action.textContent.trim() || 'Confirm';
            cancel.onclick = () => dialog.close();
            accept.onclick = () => {
                dialog.close();
                confirmed = true;
                try { action.click(); } finally { confirmed = false; }
            };
            dialog.onclose = () => dialog.remove();
            dialog.append(prompt);
            if (action.dataset.description) {
                const description = document.createElement('p');
                description.textContent = action.dataset.description;
                if (action.id.endsWith('btnConfirmSubmit')) {
                    const file = form.querySelector('[id$=fuReport]').files[0];
                    if (file) description.textContent += ' File: ' + file.name;
                }
                dialog.append(description);
            }
            const buttons = document.createElement('footer');
            buttons.append(cancel, accept);
            dialog.append(buttons);
            form.append(dialog);
            dialog.showModal();
            cancel.focus();
        }, true);
    }
    const choices = form.querySelector('[id$=cblBarangays]');
    if (choices) for (const [suffix, checked] of [['btnAll',true], ['btnNone',false]]) {
        form.querySelector('[id$=' + suffix + ']').onclick = e => {
            e.preventDefault();
            choices.querySelectorAll('input').forEach(input => input.checked = checked);
        };
    }
})();

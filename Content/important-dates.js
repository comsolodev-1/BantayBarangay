(() => {
    const panel = document.querySelector('.important-date-form');
    if (!panel || typeof HTMLDialogElement === 'undefined') return;

    const form = panel.closest('form');
    const title = panel.querySelector('[id$=txtTitle]');
    const date = panel.querySelector('[id$=txtDate]');
    const reminder = panel.querySelector('[id$=txtReminder]');
    const startValue = panel.querySelector('[id$=txtStart]');
    const endValue = panel.querySelector('[id$=txtEnd]');
    const save = panel.querySelector('[id$=btnSave]');
    const dialog = panel.querySelector('[data-calendar-error]');
    const message = dialog.querySelector('p');

    // Use the database's wall clock for calendar dates, independent of the browser's time zone.
    const clock = Date.parse(`${panel.dataset.calendarNow}Z`);
    const loadedAt = performance.now();
    const minutesPerDay = 24 * 60;
    const twoDigits = number => String(number).padStart(2, '0');
    const minutes = value => 60 * Number(value.slice(0, 2)) + Number(value.slice(3));

    const makeTimePicker = field => {
        const select = document.createElement('select');
        select.id = field.id + 'Options';
        select.className = field.className;
        select.add(new Option('No time selected', ''));
        for (let hour = 0; hour < 24; hour++) {
            const group = document.createElement('optgroup');
            const displayHour = hour % 12 || 12;
            const period = hour < 12 ? 'AM' : 'PM';
            group.label = `${displayHour} ${period}`;
            for (let minute = 0; minute < 60; minute++) {
                group.append(new Option(`${displayHour}:${twoDigits(minute)} ${period}`, `${twoDigits(hour)}:${twoDigits(minute)}`));
            }
            select.append(group);
        }
        select.value = field.value;
        field.labels[0].htmlFor = select.id;
        field.type = 'hidden';
        field.after(select);
        select.addEventListener('change', () => { field.value = select.value; });
        return select;
    };

    const start = makeTimePicker(startValue);
    const end = makeTimePicker(endValue);

    const refreshChoices = () => {
        const now = new Date(clock + performance.now() - loadedAt);
        let firstMinute = 0;
        if (Number.isFinite(clock)) {
            const today = now.toISOString().slice(0, 10);
            if (date.min !== today) date.min = reminder.min = today;
            if (date.value === today) {
                firstMinute = Math.ceil((now - Date.parse(`${today}T00:00:00Z`)) / 60000);
            }
        }

        const firstEnd = startValue.value ? Math.max(firstMinute, minutes(startValue.value) + 1) : minutesPerDay;
        const endDisabled = !startValue.value && !endValue.value;
        if (end.disabled !== endDisabled) {
            end.disabled = endDisabled;
            end.options[0].textContent = endDisabled ? 'Choose a start time first' : 'No time selected';
        }
        for (const [picker, minimum] of [[start, firstMinute], [end, firstEnd]]) {
            if (picker.dataset.firstMinute === String(minimum)) continue;
            picker.dataset.firstMinute = minimum;
            for (let minute = 0; minute < minutesPerDay; minute++) {
                picker.options[minute + 1].disabled = minute < minimum;
            }
        }
        return firstMinute;
    };

    const dateError = (field, label) => {
        const year = Number(field.value.split('-')[0]);
        if (field.validity.badInput || (field.value && (year < 1000 || year > 9999))) {
            return [field, `Choose a valid ${label} date.`];
        }
        if (field.validity.rangeUnderflow) return [field, `The ${label} date must be today or later.`];
    };

    const timeError = firstMinute => {
        for (const [field, picker, label] of [[startValue, start, 'start'], [endValue, end, 'end']]) {
            if (field.value && minutes(field.value) < firstMinute) {
                return [picker, `The ${label} time has already passed. Choose a later time.`];
            }
        }
        if (!endValue.value) return;
        if (!startValue.value) return [start, 'Choose a start time before setting an end time.'];
        if (endValue.value <= startValue.value) return [end, 'The end time must be later than the start time.'];
    };

    let invalidField;
    const showError = ([field, text]) => {
        invalidField = field;
        message.textContent = text;
        if (!dialog.open) dialog.showModal();
    };
    dialog.querySelector('button').addEventListener('click', () => dialog.close());
    dialog.addEventListener('close', () => invalidField.focus());

    date.addEventListener('input', refreshChoices);
    for (const field of [date, reminder, start, end]) {
        field.addEventListener('focus', refreshChoices);
        field.addEventListener('pointerdown', refreshChoices);
        field.addEventListener('change', () => {
            const firstMinute = refreshChoices();
            const error = field === reminder ? dateError(reminder, 'reminder') : dateError(date, 'event') || timeError(firstMinute);
            if (error) showError(error);
        });
    }

    // Check before the shared confirmation prompt and again if time passes while it is open.
    const validateSave = event => {
        const firstMinute = refreshChoices();
        const error = (!title.value.trim() && [title, 'Enter a title for the event.']) ||
            dateError(date, 'event') || (!date.value && [date, 'Choose a valid event date.']) ||
            timeError(firstMinute) || dateError(reminder, 'reminder');
        if (!error) return;
        event.preventDefault();
        event.stopImmediatePropagation();
        showError(error);
    };
    form.addEventListener('click', event => { if (event.target === save) validateSave(event); }, true);
    form.addEventListener('submit', event => { if (event.submitter === save) validateSave(event); });
    refreshChoices();
    if (Number.isFinite(clock)) setInterval(refreshChoices, 1000);
})();

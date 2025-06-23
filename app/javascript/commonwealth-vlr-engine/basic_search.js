/* basic search full-text toggle */

const basicSearchPopover = new bootstrap.Popover('#fulltext_info', {
    html: true
});

const searchFieldAlert = (e) => {
    const search_field_selector = '#search_field';

    if (!e.target.matches(search_field_selector)) return;

    let selectedOption = e.value;
    let checkbox = document.getElementById('fulltext_checkbox');
    let checkboxLabel = document.getElementById('fulltext_checkbox_label');
    let infoIcon = document.getElementById('fulltext_info');
    let infoIconContent = infoIcon.dataset.bsContent;

    if (selectedOption !== "all_fields") {
        let was_checked = checkbox.checked;
        if (was_checked == true) {
            infoIcon.dataset.bsContent = 'The full-text option only works with the "All Fields" search.';
            basicSearchPopover.show();
        }

        checkboxLabel.style.color = "lightgray";
        checkbox.checked = false;
        checkbox.disabled = true;

        if (was_checked == true) {
            setTimeout(() => {
                basicSearchPopover.hide();
            }, 2000)
            infoIcon.dataset.bsContent = infoIconContent
        }
    } else {
        checkboxLabel.style.color = "unset";
        checkbox.disabled = false;
    }
}

document.addEventListener("change", searchFieldAlert);
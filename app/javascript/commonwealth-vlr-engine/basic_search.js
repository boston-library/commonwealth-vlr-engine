/* basic search full-text toggle */

const basicSearchBehavior = (() => {
    const basicSearch = {}

    basicSearch.popoverSelector = '#fulltext_info';

    basicSearch.setupSearchFieldAlert = function(options) {
        document.addEventListener("turbo:load", basicSearch.initPopover);
        document.addEventListener("change", basicSearch.searchFieldAlert);
    }

    basicSearch.initPopover = function(e) {
        let bs_popover_el = document.querySelector(basicSearch.popoverSelector);
        if (!bs_popover_el) return;

        basicSearch.basicSearchPopover = new bootstrap.Popover(basicSearch.popoverSelector, {
            html: true
        });
    }

    basicSearch.searchFieldAlert = function(e) {
        const search_field_selector = '#search_field';

        if (!e.target.matches(search_field_selector)) return;

        let selectedOption = e.target.value;
        let checkbox = document.getElementById('fulltext_checkbox');
        let checkboxLabel = document.getElementById('fulltext_checkbox_label');
        let infoIcon = document.getElementById('fulltext_info');
        // let infoIconTitle = infoIcon.dataset.bsTitle;
        let infoIconContent = infoIcon.dataset.bsContent;

        if (selectedOption !== "all_fields") {
            let was_checked = checkbox.checked;
            if (was_checked === true) {
                basicSearch.basicSearchPopover.setContent({
                    // '.popover-header': infoIconTitle,
                    '.popover-body': 'The full-text option only works with the "All Fields" search.'
                })
                basicSearch.basicSearchPopover.show();
            }

            checkboxLabel.style.color = "#77767b";
            checkbox.checked = false;
            checkbox.disabled = true;

            if (was_checked === true) {
                setTimeout(() => {
                    basicSearch.basicSearchPopover.hide();
                    basicSearch.basicSearchPopover.setContent({
                        // '.popover-header': infoIconTitle,
                        '.popover-body': infoIconContent
                    })
                }, 2000)
            }
        } else {
            checkboxLabel.style.color = "unset";
            checkbox.disabled = false;
        }
    }

    basicSearch.setupSearchFieldAlert()

    return basicSearch;
})()

export default basicSearchBehavior

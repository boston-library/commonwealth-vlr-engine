/* basic search full-text toggle */
$(function () {
    $('#fulltext_info').popover({
        trigger: 'focus'
    });
})

$('#search_field').change(function () {
    let selectedOption = $(this).val();
    let checkbox = $('#fulltext_checkbox');
    let infoIcon = $('#fulltext_info');
    let infoIconContent = infoIcon.data('content');
    if (selectedOption !== "all_fields") {
        let was_checked = checkbox.prop('checked');
        if (was_checked == true) {
            infoIcon.attr('data-content', 'The full-text option only works with the "All Fields" search.');
            infoIcon.popover('show');
        }
        $('#fulltext_checkbox_label').css("color", "lightgray");
        checkbox.prop({'checked': false, 'disabled': true});
        if (was_checked == true) {
            setTimeout(() => {
                infoIcon.popover('hide');
            }, 2000)
            infoIcon.attr('data-content', infoIconContent);
        }
    } else {
        $('#fulltext_checkbox_label').css("color", "unset");
        checkbox.prop({'disabled': false});
    }
}).change();

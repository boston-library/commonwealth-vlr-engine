/* basic search full-text toggle */
$(function () {
    $('#fulltext_info').popover({
        trigger: 'focus'
    });
})

$('#search_field').change(function () {
    selectedOption = $(this).val();
    checkbox = $('#fulltext_checkbox');
    if (selectedOption !== "all_fields") {
        was_checked = checkbox.prop('checked');
        if (was_checked == true) {
            $('#fulltext_info').popover('show');
        }
        $('#fulltext_checkbox_label').css("color", "lightgray");
        checkbox.prop({'checked': false, 'disabled': true});
        if (was_checked == true) {
            setTimeout(() => {
                $('#fulltext_info').popover('hide');
            }, 2000)
        }
    } else {
        $('#fulltext_checkbox_label').css("color", "unset");
        checkbox.prop({'disabled': false});
    }
}).change();

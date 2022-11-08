/* basic search full-text toggle */
$(function () {
    $('#fulltext_info').popover({
        trigger: 'focus'
    });
})

$('#search_field').change(function () {
    selectedOption = $(this).val();
    if (selectedOption !== "all_fields") {
        $('#fulltext_checkbox_label').css("color", "lightgray");
        $('#fulltext_checkbox').prop({'checked': false, 'disabled': true});
    } else {
        $('#fulltext_checkbox_label').css("color", "unset");
        $('#fulltext_checkbox').prop({'disabled': false});
    }
}).change();

// item actions for folders and bookmarks

$(document).ready ( function () {
    // remove duplicate buttons from form
    $('#cite_btn,#email_btn').remove();
    //  add click event for any checkbox in doc list
    $(':checkbox[name="selected[]"]').click( function () {
        addCheckedToURL();
    });

    // select/unselect all
    $('#selectAllItems').click( function () {
        $(':checkbox[name="selected[]"]').prop('checked', this.checked);
        addCheckedToURL();
    });
});


// when any checkbox is selected, append the ids of all checked items to url
function addCheckedToURL () {
    var checkboxValues = $('[name="selected[]"]:checked').serialize();
    checkboxValues = checkboxValues.replace(/selected/g,"id");
    $('#citeLink,#emailLink,#copyLink').attr('href', function(index,previousValue) {
        return previousValue.replace(/\?.*/,"?" + checkboxValues);
    });
}
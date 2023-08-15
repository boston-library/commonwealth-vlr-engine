// hide the download button by default
// gets shown via recaptcha callback function enableDownloadButton()
$(document).ready ( function () {
    $('#trigger_download_submit').hide();
});

/* close the modal when the download button is clicked; track events */
$('#trigger_download_submit').on('click', function () {
    // need this here, adding data-dismiss='modal' to link doesn't work
    $('#blacklight-modal').modal('hide');
});

// when recaptcha returns success, show the download button
function enableDownloadButton () {
    $('#download_recaptcha').delay(700).hide('slow');
    $('#trigger_download_submit').delay(700).show('slow');
}

// get a new recaptcha if it expires, hide the download button
function refreshRecaptcha () {
    $('#trigger_download_submit').hide();
    $('#download_recaptcha').show('slow');
    grecaptcha.reset();
}

/* close the modal when the download button is clicked; track events */
$('.trigger_download').on('click', function () {
    // need this here, adding data-dismiss='modal' to link doesn't work
    $('#blacklight-modal').modal('hide');

    try{
        var category = 'downloads#show';
        var action = 'trigger_download';
        var label = $(this).attr('class').split(' ').pop();
        var pid = $(this).attr('href').split('/').pop().match(/^[a-z-:0-9]*/);
        BlacklightGoogleAnalytics.track_event(category, action, label);
        BlacklightGoogleAnalytics.track_event('downloads#items', pid, label);
    } catch(err) {
        BlacklightGoogleAnalytics.console_log_error(err, [category, action, label]);
    }
});

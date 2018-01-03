/* we add autofocus attribute to search form input here
   otherwise twitter-typeahead-rails causes issues
   where keyboard doesn't come up on mobile devices */
$(document).ready(function() {
    $('#hero_search_form').find('#q').attr('autofocus','autofocus');
});
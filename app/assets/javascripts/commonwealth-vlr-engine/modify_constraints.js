/* for institutions#index */
/* change target of #appliedParams links to 'institutions/' */
/* this is a hack until I can figure out how to control search_action_path */
/* see https://groups.google.com/d/msg/blacklight-development/j9U-5IcVbGE/43bj1aGWsXgJ */
$(document).ready(function() {

  $('#appliedParams').find('a').attr('href', function(index,previousValue) {
    return previousValue.replace(/search/,'institutions');
  });

});
/* scripts used by multiple views */

// replace text of more/less toggle links
function toggleText (e, text1, text2) {
    $(e).text(function(i, text){
        return text === text1 ? text2 : text1;
    })
}

$(document).ready(function() {
    $('.no-js').removeClass('no-js').addClass('js');
});

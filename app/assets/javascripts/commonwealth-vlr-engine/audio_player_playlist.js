/* audio playlist */

init_playlist();

function init_playlist(){
    var current = 0;
    var audio = $('audio');
    var playlist = $('#audio_playlist');
    var tracks = playlist.find('li a');
    len = tracks.length; // - 1;
    playlist.find('a').click(function(e) {
        e.preventDefault();
        link = $(this);
        current = link.parent().index();
        play_track(link, audio[0]);
    });
    audio[0].addEventListener('ended', function(e) {
        current++;
        // console.log('current = ' + current);
        if (current == len) {
            // console.log('current == len');
            // current = 0;
            // link = playlist.find('a')[0];
            // stop playing, this SHOULD BE the end
        } else {
            // console.log('current != len, in the else block');
            link = playlist.find('a')[current];
            play_track($(link), audio[0]);
        }

    });
}

function play_track(link, player){
    console.log('about to play ' + link.text());
    player.src = link.attr('href');
    par = link.parent();
    par.addClass('active').siblings().removeClass('active');
    $('#audio_title').text(link.text());
    player.load();
    player.play();
}

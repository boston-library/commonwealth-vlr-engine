const audioPlayerPlaylist = (() => {
    const audioPlayer = {}

    audioPlayer.setupPlayer = function(options) {
        document.addEventListener("turbo:load", audioPlayer.init_playlist);
    }

    audioPlayer.init_playlist = function(e) {
        const playlist = document.getElementById('audio_playlist');
        if (!playlist) return;

        let current = 0;
        let audio = document.querySelector('audio');
        let track_links = playlist.querySelectorAll('li a');
        let len = track_links.length;

        track_links.forEach(el => {
            el.addEventListener('click', function(e) {
                e.preventDefault();
                current = Array.from(track_links).indexOf(el)
                audioPlayer.play_track(el, audio);
            });
        });

        audio.addEventListener('ended', function(e) {
            current++;
            if (current !== len) {
                audioPlayer.play_track(track_links[current], audio);
            }
        });
    }

    audioPlayer.play_track = function(track_link, player) {
        console.log('about to play ' + track_link.textContent);
        player.src = track_link.getAttribute('href');
        let par = track_link.parentNode;
        par.classList.add('active')
        Array.from(par.parentNode.children).forEach(el => {
            if (el !== par) {
                el.classList.remove('active')
            }
        });
        document.getElementById('audio_title').textContent = track_link.textContent;
        player.load();
        player.play();
    }

    audioPlayer.setupPlayer()

    return audioPlayer;
})()

export default audioPlayerPlaylist

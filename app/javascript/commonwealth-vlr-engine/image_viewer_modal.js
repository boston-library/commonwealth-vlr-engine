import OpenSeadragon from 'openseadragon'

const initImageViewerModal = (e) => {
    const img_viewer_modal_selector = '#img_viewer_modal';
    if (!e.target.matches(img_viewer_modal_selector)) return;

    console.log('OH YEAH');

    const OSd_viewer = {};
    const img_viewer_osd = document.getElementById('img_viewer_osd');
    img_viewer_osd.style.height = `${window.innerHeight - 60}px`;

    OSd_viewer.viewer = new OpenSeadragon({
        id: "img_viewer_osd",
        prefixUrl: '',
        navImages: JSON.parse(img_viewer_osd.dataset.navimages),
        tileSources: [img_viewer_osd.dataset.tilesource],
        autoHideControls: false,
        immediateRender: navigator.userAgent.match(/mobile/i),
        showNavigator: true,
        navigatorPosition: 'TOP_RIGHT',
        showRotationControl: true,
        navigationControlAnchor: OpenSeadragon.ControlAnchor.BOTTOM_RIGHT,
        showFullPageControl: false
    });

    // TODO: remove the viewer after closing the modal
    // img_viewer_modal.addEventListener('hidden.bs.modal', function () {
    //     img_viewer_osd.removeChild(img_viewer_osd.querySelector('.openseadragon-container'));
    //     if (OSd_viewer.viewer) {
    //         OSd_viewer.viewer.destroy();
    //         OSd_viewer.viewer = null;
    //     }
    // });
}

document.addEventListener("show.bs.modal", initImageViewerModal);


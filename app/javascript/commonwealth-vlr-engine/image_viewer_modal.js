import OpenSeadragon from 'openseadragon'

const imageViewerModal = (() => {
    const imageViewer = {}

    imageViewer.modalSelector = '#img_viewer_modal';

    imageViewer.viewerSelector = 'img_viewer_osd';

    imageViewer.setupModal = function(options) {
        document.addEventListener("show.bs.modal", imageViewer.createViewer);
        document.addEventListener("hidden.bs.modal", imageViewer.destroyViewer);
    }

    imageViewer.createViewer = function(e) {
        if (!e.target.matches(imageViewer.modalSelector)) return;

        const img_viewer_osd = document.getElementById(imageViewer.viewerSelector);
        img_viewer_osd.style.height = `${window.innerHeight - 60}px`;

        imageViewer.viewer = new OpenSeadragon({
            id: imageViewer.viewerSelector,
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
    }

    imageViewer.destroyViewer = function(e) {
        const img_viewer_osd = document.getElementById(imageViewer.viewerSelector);

        if (!img_viewer_osd) return;

        img_viewer_osd.removeChild(img_viewer_osd.querySelector('.openseadragon-container'));
        if (imageViewer.viewer) {
            imageViewer.viewer.destroy();
            imageViewer.viewer = null;
        }
    }

    imageViewer.setupModal()

    return imageViewer;
})()

export default imageViewerModal

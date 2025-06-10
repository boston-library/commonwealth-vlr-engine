import OpenSeadragon from 'openseadragon'

const multiImageViewer = (() => {
    const imageViewer = {}

    imageViewer.viewerSelector = 'multi_img_viewer_osd';

    imageViewer.setupViewer = function(options) {
        document.addEventListener("turbo:load", imageViewer.createViewer);
    }

    imageViewer.createViewer = function(e) {
        const img_viewer_osd = document.getElementById(imageViewer.viewerSelector);
        if (!img_viewer_osd) return;

        imageViewer.viewer = new OpenSeadragon({
            id: imageViewer.viewerSelector,
            prefixUrl: '',
            navImages: JSON.parse(img_viewer_osd.dataset.navimages),
            tileSources: JSON.parse(img_viewer_osd.dataset.tilesources),
            autoHideControls: false,
            immediateRender: navigator.userAgent.match(/mobile/i),
            showNavigator: true,
            navigatorPosition: 'TOP_RIGHT',
            showRotationControl: true,
            navigationControlAnchor: OpenSeadragon.ControlAnchor.BOTTOM_RIGHT,
            showFullPageControl: true,
            sequenceMode: true,
            sequenceControlAnchor: OpenSeadragon.ControlAnchor.BOTTOM_RIGHT,
            showReferenceStrip: true,
            referenceStripScroll: 'vertical',
            referenceStripSizeRatio: 0.15,
            crossOriginPolicy: 'Anonymous'
        });
    }

    imageViewer.setupViewer()

    return imageViewer;
})()

export default multiImageViewer

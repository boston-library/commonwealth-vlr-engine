import * as UV from "universalviewer"

const bookViewer = (() => {
    const bViewer = {}

    bViewer.viewerSelector = 'uv';

    bViewer.setupViewer = function(options) {
        document.addEventListener("turbo:load", bViewer.createViewer);
    }

    bViewer.createViewer = function(e) {
        const uv_viewer_el = document.getElementById(bViewer.viewerSelector);
        if (!uv_viewer_el) return;

        var urlAdapter = new UV.IIIFURLAdapter();

        const data = urlAdapter.getInitialData({
            manifest: uv_viewer_el.dataset.manifest,
            highlight: urlAdapter.get('h',''),
        });

        const uv = UV.init(uv_viewer_el, data);
        urlAdapter.bindTo(uv);

        uv.on("configure", function ({ config, cb }) {
            cb(JSON.parse(uv_viewer_el.dataset.uvconfig));
        });
    }

    bViewer.setupViewer()

    return bViewer;
})()

export default bookViewer

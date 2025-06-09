// interactive behavior for download links on downloads#show
const downloadsModal = (() => {
    const downloads = {}

    downloads.setupModal = function(options) {
        document.addEventListener("show.blacklight.blacklight-modal", downloads.hideDownloadLink);
    }

    downloads.hideDownloadLink = function() {
        const trigger_download = document.getElementById("trigger_download_submit")
        if (!trigger_download) return;

        trigger_download.style.display = "none";
    }

    downloads.setupModal()

    return downloads;
})()

export default downloadsModal

// when recaptcha returns success, show the download button
// called via callback arg in #recaptcha_tags helper
window.enableDownloadButton = function () {
    document.getElementById("download_recaptcha").style.display = "none";
    document.getElementById("trigger_download_submit").style.display = "inline-block";
}

// get a new recaptcha if it expires, hide the download button
// called via expired_callback arg in #recaptcha_tags helper
window.refreshRecaptcha = function () {
    document.getElementById("trigger_download_submit").style.display = "none";
    document.getElementById("download_recaptcha").style.display = "block";
    grecaptcha.reset();
}

// interactive behavior for download links on downlaods#show

const hideDownloadLink = () => {
    const trigger_download = document.getElementById("trigger_download_submit")
    if (!trigger_download) return;
    trigger_download.style.display = "none";
}

const blacklightModal = document.getElementById('blacklight-modal');
blacklightModal.addEventListener('show.blacklight.blacklight-modal', hideDownloadLink)

// when recaptcha returns success, show the download button
window.enableDownloadButton = function () {
    console.log('enableDownloadButton fired');
    document.getElementById("download_recaptcha").style.display = "none";
    document.getElementById("trigger_download_submit").style.display = "inline-block";
}

// get a new recaptcha if it expires, hide the download button
window.refreshRecaptcha = function () {
    console.log('refreshRecaptcha fired');
    document.getElementById("trigger_download_submit").style.display = "none";
    document.getElementById("download_recaptcha").style.display = "block";
    grecaptcha.reset();
}

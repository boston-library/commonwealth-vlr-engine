import Modal from 'blacklight/modal'

const ocrSearchModal = (() => {
    const ocrSearch = {}

    ocrSearch.formSelector = 'ocr_search_form';
    ocrSearch.transitionSelectors = '#ocr_search_details .page-links a, #ocr_pagination a, #sort-dropdown a, #ocr_search_suggest a';
    ocrSearch.pageLinkSelector = '.ocr_page_link a';

    ocrSearch.init = function(options) {
        document.addEventListener("loaded.blacklight.blacklight-modal", ocrSearch.setupModal);
    }

    ocrSearch.setupModal = function(options) {
        const ocrSearchForm = document.getElementById(ocrSearch.formSelector);
        if (!ocrSearchForm) return;

        const transitionLinks = document.querySelectorAll(ocrSearch.transitionSelectors);
        transitionLinks.forEach(el => {
            el.addEventListener("click", ocrSearch.addModalTransition);

            /* pagination links should preserve the modal rather than reloading the page */
            el.dataset.blacklightModal = 'preserve'
        });

        ocrSearchForm.addEventListener("submit", ocrSearch.modalAjaxFormSubmit);

        const pageLinks = document.querySelectorAll(ocrSearch.pageLinkSelector);
        pageLinks.forEach(el => el.addEventListener('click', ocrSearch.updateViewer));
    }

    /* show modal transition div for results, next page, etc. */
    ocrSearch.addModalTransition = function() {
        const modal_transition = document.getElementById('modal-transition');
        modal_transition.classList.toggle('hidden');
    }

    ocrSearch.modalAjaxFormSubmit = function(e) {
        ocrSearch.addModalTransition; // TODO: figure out why this doesn't fire
        e.preventDefault();
        const form = e.target
        fetch(form.action, {
            body: new FormData(form),
            headers: { "X-Requested-With": "XMLHttpRequest" }, // ensure rails request.xhr? returns true
            method: form.method,
        })
            .then(response => {
                if (!response.ok) {
                    throw new TypeError("Request failed");
                }
                return response.text();
            })
            .then(data => Modal.receiveAjax(data))
            .catch(error => Modal.onFailure(error))
    }

    /* close the modal and fire a custom event so we can trigger an update to the UV viewer */
    ocrSearch.updateViewer = function(e) {
        const pageLink = e.target
        const pageLinkParams = new URLSearchParams(pageLink.href.split('#?').at(-1));
        const pageLinkClickPayload = {
            canvasIndex: pageLinkParams.get("cv"),
            highlight: pageLinkParams.get("h")
        }
        const pageLinkClick = new CustomEvent('ocrsearch.pagelinkclick', { detail: pageLinkClickPayload, bubbles: true, cancelable: true });
        Modal.hide();
        pageLink.dispatchEvent(pageLinkClick)
    }

    ocrSearch.init();

    return ocrSearch;
})()

export default ocrSearchModal
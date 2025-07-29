const ocrSearchModal = (() => {
    const ocrSearch = {}

    ocrSearch.formSelector = 'ocr_search_form';
    ocrSearch.transitionSelectors = '#ocr_search_details .page-links a, #ocr_pagination a, #sort-dropdown a, #ocr_search_suggest a';

    ocrSearch.init = function(options) {
        document.addEventListener("show.blacklight.blacklight-modal", ocrSearch.setupModal);
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

        ocrSearchForm.addEventListener("submit", ocrSearch.addModalTransition);
    }

    /* show modal transition div for results, next page, etc. */
    ocrSearch.addModalTransition = function() {
        const modal_transition = document.getElementById('modal-transition');
        modal_transition.classList.toggle('hidden');
    }

    ocrSearch.init();

    return ocrSearch;
})()

export default ocrSearchModal
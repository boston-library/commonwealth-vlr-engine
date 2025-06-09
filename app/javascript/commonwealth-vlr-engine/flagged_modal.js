const flaggedContentModal = (() => {
    const flagged = {}

    flagged.setupModal = function(options) {
        document.addEventListener("turbo:load", flagged.triggerModal);
    }

    flagged.triggerModal = function(e) {
        const flagged_warning_div = document.getElementById('flagged_warning_modal');
        if (!flagged_warning_div) return;

        const flaggedModal = new bootstrap.Modal(flagged_warning_div, {
            backdrop: true
        })
        flaggedModal.show();
        document.querySelector(".modal-backdrop").style.opacity = ".95";
    }

    flagged.setupModal()

    return flagged;
})()

export default flaggedContentModal

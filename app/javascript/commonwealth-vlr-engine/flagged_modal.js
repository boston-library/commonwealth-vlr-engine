const initFlaggedModal = () => {
    const flaggedModal = new bootstrap.Modal(document.getElementById('flagged_warning_modal'), {
        backdrop: true
    })
    flaggedModal.show();
    document.querySelector(".modal-backdrop").style.opacity = ".95";
}

document.addEventListener("DOMContentLoaded", initFlaggedModal);

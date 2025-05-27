const initFlaggedModal = () => {
    const flagged_warning = document.getElementById('flagged_warning_modal');
    if (!flagged_warning) return;

    const flaggedModal = new bootstrap.Modal(flagged_warning, {
        backdrop: true
    })
    flaggedModal.show();
    document.querySelector(".modal-backdrop").style.opacity = ".95";
}

document.addEventListener("DOMContentLoaded", initFlaggedModal);

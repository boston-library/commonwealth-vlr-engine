// used in conjunction with Bootstrap toggle,
// replaces text of toggle link/button with value of data-toggle-text attribute
const toggleText = (e) => {
    const toggle_text_selector = 'toggle_text';
    if (!e.target.classList.contains(toggle_text_selector)) return;

    const toggleLink = e.target;
    const linkText = toggleLink.textContent;
    toggleLink.textContent = toggleLink.dataset.toggleText
    toggleLink.dataset.toggleText = linkText
}

document.addEventListener("click", toggleText);

/* pagination links should preserve the modal rather than reloading the page */
var top_pagination_selector = '#ocr_search_details .page_links a';
var bottom_pagination_selector = '#ocr_pagination #pagination_links a';
$(top_pagination_selector + ", " + bottom_pagination_selector).on("click", Blacklight.ajaxModal.modalAjaxLinkClick);

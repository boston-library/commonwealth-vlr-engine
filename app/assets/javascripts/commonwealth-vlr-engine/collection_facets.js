$(document).ready(function() {
    /* remove the institution and collection facets from the sidebar */
    var facet_div = $('#facets');
    facet_div.find('div.blacklight-physical_location_ssim').remove();
    facet_div.find('div.blacklight-collection_name_ssim').remove();

    /* change the id of the series thumbnails facet so that collapse of */
    /* series sidebar facet works in tablet/phone view */
    $('#series_wrapper').find('#facet-related_item_series_ssim').attr('id','facet-related_item_series_ssim_thumb-list');

});

$(document).ready(function() {
    var facet_div = $('#facets');
    /* use to auto-expand individual facets
    var facets_to_open = ['topic_facet', 'resource_decade_facet'];
    $.each(facets_to_open, function(index, value){
        facet_div.find('div.collapse-toggle').removeClass('collapsed');
        facet_div.find('div.facet-content').show();
    });
    */
    /* auto-expand all facets */
    facet_div.find('div.collapse-toggle').removeClass('collapsed');
    facet_div.find('div.facet-content').addClass('in');
});
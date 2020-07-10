# need to override RangeLimitHelper#add_range_missing, this seems to be only way that works

RangeLimitHelper.module_eval do

  def add_range_missing(solr_field, my_params = params)
    my_params = Marshal.load(Marshal.dump(my_params))
    my_params["range"] ||= {}
    my_params["range"][solr_field] ||= {}
    my_params["range"][solr_field]["missing"] = "true"

    # Need to ensure there's a search_field to trick Blacklight
    # into displaying results, not placeholder page. Kind of hacky,
    # but works for now.
    my_params["search_field"] ||= "dummy_range"
    my_params = my_params.permit! unless my_params.is_a?(Hash)
    search_catalog_path(my_params.except('controller', 'action'))
  end

end

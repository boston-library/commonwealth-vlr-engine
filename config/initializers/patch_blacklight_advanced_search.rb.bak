# frozen_string_literal: true

# have to override some methods from BlacklightAdvancedSearch::QueryParser
# to provide date limiter
require BlacklightAdvancedSearch::Engine.root.join(CommonwealthVlrEngine::Engine.root,
                                                   'config', 'initializers', 'patch_blacklight_advanced_search')

class BlacklightAdvancedSearch::QueryParser
  # LOCAL OVERRIDE of BlacklightAdvancedSearch::QueryParser#process_query
  def process_query(config)
    queries = keyword_queries.map do |clause|
      field = clause[:field]
      query = clause[:query]

      ParsingNesting::Tree.parse(query, config.advanced_search[:query_parser]).to_query(local_param_hash(field, config))
    end.join(" #{keyword_op} ")

    return queries if search_state.params[:date_start].blank? && search_state.params[:date_end].blank?

    queries.blank? ? add_date_range_to_queries : [queries, add_date_range_to_queries].join(' AND ')
  end

  # LOCAL ADDITION format date input for Solr
  def add_date_range_to_queries
    date_start_param = search_state.params[:date_start]
    date_end_param = search_state.params[:date_end]
    range_start = date_start_param.blank? || date_start_param.match(/[\D]+/) ? '*' : date_start_param + '-01-01T00:00:00.000Z'
    range_end = date_end_param.blank? || date_end_param.match(/[\D]+/) ? '*' : date_end_param + '-12-31T23:59:59.999Z'
    "(date_start_dtsi:[#{range_start} TO #{range_end}] OR (date_start_dtsi:[* TO #{range_end}] AND date_end_dtsi:[#{range_start} TO *]))"
  end

  # LOCAL ADDITION change params to be what's expected by gem
  # def prepare_params(params)
  #   if params[:search_index]
  #     params[:search_index].each_with_index do |field, index|
  #       if params[field.to_sym] # check if field is set
  #         unless params[:query][index].empty?
  #           if params[:op] == 'OR'
  #             params[field.to_sym] = params[field.to_sym] + ' OR ' + params[:query][index]
  #           else
  #             params[field.to_sym] = params[field.to_sym] + ' AND ' + params[:query][index]
  #           end
  #         else
  #           params[field.to_sym] = params[field.to_sym]
  #         end
  #       else
  #         params[field.to_sym] = params[:query][index]
  #       end
  #     end
  #     params.delete(:search_index)
  #     params.delete(:query)
  #   end
  #   params
  # end

  # LOCAL OVERRIDE of BlacklightAdvancedSearch::QueryParser#initialize
  # def initialize(params, config)
  #   if params.respond_to?(:permit!)
  #     santitized_params = params.permit!
  #   else
  #     santitized_params = params
  #   end
  #   @params = HashWithIndifferentAccess.new(prepare_params(santitized_params))
  #   @config = config
  # end
end

# module BlacklightAdvancedSearch::RenderConstraintsOverride
#   # LOCAL OVERRIDE, checking for mlt and geographic searches
#   def query_has_constraints?(localized_params = params)
#     if is_advanced_search? localized_params
#       true
#     else
#       !(localized_params[:q].blank? && localized_params[:f].blank? && localized_params[:f_inclusive].blank? && localized_params[:mlt_id].blank? && localized_params[:coordinates].blank?)
#     end
#   end
# end

# -*- encoding : utf-8 -*-
#
# Filters added to this controller apply to all controllers in the hosting application
# as this module is mixed-in to the application controller in the hosting app on installation.
module CommonwealthVlrEngine
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :create_img_sequence # extra head content
    end

    def create_img_sequence(image_files, current_img_pid)
      page_sequence = {}
      page_sequence[:current] = current_img_pid
      page_sequence[:index] = image_files.index(current_img_pid) + 1
      page_sequence[:total] = image_files.length
      page_sequence[:prev] = page_sequence[:index]-2 > -1 ? image_files[page_sequence[:index]-2] : nil
      page_sequence[:next] = image_files[page_sequence[:index]].presence
      page_sequence
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    # override of Blacklight::Controller#render_bookmarks_control?
    # return false, we use our own
    def render_bookmarks_control?
      false
    end

    # override of Blacklight::Controller#search_action_path
    # for proper constraints and facet links in collections and institution views
    # gets a bit tricky for collections#facet, since this has multiple contexts (collections#index and collections#show)
    def search_action_path *args
      if args.first.is_a? Hash
        args.first[:only_path] = true if args.first[:only_path].nil?
      end

      if params[:controller] == 'institutions' && params[:action] == 'index'
        institutions_url(*args)
      elsif params[:controller] == 'collections'
        if params[:action] == 'index'
          collections_url(*args)
        elsif params[:action] == 'facet'
          if request.query_parameters['f'] &&
             request.query_parameters['f'][blacklight_config.collection_field]
            search_action_url(*args)
          else
            collections_url(*args)
          end
        else
          search_action_url(*args)
        end
      else
        search_action_url(*args)
      end
    end

    def determine_layout
      'commonwealth-vlr-engine'
    end
  end
end

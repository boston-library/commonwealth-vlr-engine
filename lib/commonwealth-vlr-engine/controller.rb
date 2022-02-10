# -*- encoding : utf-8 -*-
#
# Filters added to this controller apply to all controllers in the hosting application
# as this module is mixed-in to the application controller in the hosting app on installation.
module CommonwealthVlrEngine
  module Controller

    extend ActiveSupport::Concern

    included do

      after_filter :store_location

      # extra head content
      helper_method :create_img_sequence

    end

    # redirect after login to previous non-login page
    # TODO figure out why it doesn't work for Polaris or Facebook logins
    def store_location
      # store last url - this is needed for post-login redirect to whatever the user last visited.
      if (request.path != "/users/sign_in" &&
          request.path != "/users/sign_up" &&
          request.path != "/users/password" &&
          request.path != "/users/password/new" &&
          request.path != "/users/password/edit" &&
          request.path != "/users/confirmation" &&
          request.path != "/users/sign_out" &&
          !request.fullpath.match(/\/users\/auth\//) &&
              !request.xhr?) # don't store ajax calls
        session[:previous_url] = request.fullpath
      end
    end

    def after_sign_in_path_for(resource)
      session[:previous_url] || root_path
    end

    # @param image_files [Array] array of SolrDocument from @object_files[:image]
    # @param current_img_pid [String]
    # @return [Hash]
    def create_img_sequence(image_files, current_img_pid)
      current_img_file = image_files.find { |i| i[:id] == current_img_pid }
      img_pids = image_files.map { |i| i[:id] }
      current_index = img_pids.index(current_img_pid) + 1
      {
        current: current_img_pid,
        current_key: current_img_file[:storage_key_base_ss],
        index: img_pids.index(current_img_pid) + 1,
        total: image_files.length,
        prev: current_index - 2 > -1 ? img_pids[current_index - 2] : nil,
        next: img_pids[current_index].presence
      }
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    # override of Blacklight::Controller#search_action_path
    # for proper constraints and facet links in collections and institution views
    # gets a bit tricky for collections#facet, since this has multiple contexts (collections#index and collections#show)
    def search_action_path *args
      if args.first.is_a? Hash
        args.first[:only_path] = true
        # Rails 4.2 deprecated url helpers accepting string keys for 'controller' or 'action'
        args[0] = args.first.except(:controller, :action)
      end

      if params[:controller] == 'institutions' && params[:action] == 'index'
        institutions_url *args
      elsif params[:controller] == 'collections'
        if params[:action] == 'index'
          collections_url *args
        elsif params[:action] == 'facet'
          if request.query_parameters['f'] && request.query_parameters['f'][blacklight_config.collection_field]
            search_action_url *args
          else
            collections_url *args
          end
        else
          search_action_url *args
        end
      else
        search_action_url *args
      end
    end

  end
end
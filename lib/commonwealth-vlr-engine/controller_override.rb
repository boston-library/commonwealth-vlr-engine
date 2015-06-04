module CommonwealthVlrEngine
  module ControllerOverride
    extend ActiveSupport::Concern
    included do

      if self.respond_to? :search_params_logic
        search_params_logic << :exclude_unwanted_models
      end

      if self.blacklight_config.search_builder_class
        self.blacklight_config.search_builder_class.send(:include,
                                                         CommonwealthVlrEngine::CommonwealthSearchBuilder
        ) unless
            self.blacklight_config.search_builder_class.include?(
                CommonwealthVlrEngine::CommonwealthSearchBuilder
            )
      end

    end

    # displays the MODS XML record. copied from blacklight_marc gem
    def librarian_view
      @response, @document = fetch(params[:id])

      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end


  end

end
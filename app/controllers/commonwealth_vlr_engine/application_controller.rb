module CommonwealthVlrEngine
  class ApplicationController < ActionController::Base
    helper Openseadragon::OpenseadragonHelper

    # Adds Hydra behaviors into the application controller
    include Hydra::Controller::ControllerBehavior

    layout 'commonwealth-vlr-engine'

  end
end

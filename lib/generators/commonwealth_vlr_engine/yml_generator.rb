require 'rails/generators'

module CommonwealthVlrEngine
  class YmlGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc "YmlGenerator Commonwealth VLR Engine"

    def yml_copy
      unless IO.read("config/vlr.yml").present?
        copy_file "blacklight.yml", "blacklight.yml"
        copy_file "fedora.yml", "fedora.yml"
        copy_file "iiif_server.yml", "iiif_server.yml"
        copy_file "omniauth-facebook.yml", "omniauth-facebook.yml"
        copy_file "omniauth-polaris.yml", "omniauth-polaris.yml"
        copy_file "vlr.yml", "vlr.yml"
      end



    end

  end
end
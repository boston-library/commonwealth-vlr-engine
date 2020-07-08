require 'rails/generators'

module CommonwealthVlrEngine
  class UserGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "UserGenerator Commonwealth VLR Engine"

    def omniauth
      return if IO.read("app/models/user.rb").include?('Bpluser')

      marker = 'include Blacklight::User'
      insert_into_file "app/models/user.rb", after: marker do
        "\n\n  # Connects this user object to the BPL omniauth service" \
        "\n  include Bpluser::Concerns::Users" \
        "\n  self.table_name = 'users'\n"
      end
    end

    def add_trackable_to_devise
      marker = 'devise :'
      insert_into_file 'app/models/user.rb', after: marker do
        'trackable, :'
      end
    end
  end
end

class User < ActiveRecord::Base
  require 'base64'
  require 'cgi'
  require 'openssl'
  require 'rest_client'
  require 'devise'

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Connects this user object to the BPL omniauth service
  include Bpluser::User

  # Include our custom validations
  include Bpluser::Validatable

  self.table_name = "users"

end

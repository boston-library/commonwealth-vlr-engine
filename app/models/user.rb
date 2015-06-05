class User < ActiveRecord::Base
  require 'base64'
  require 'cgi'
  require 'openssl'
  require 'rest_client'
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Institution-management behaviors.
  #include Bpl::InstitutionManagement::UserInstitutions

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Connects this user object to the BPL omniauth service
  include Bpluser::User
  self.table_name = "users"

end

class Users::RegistrationsController < Devise::RegistrationsController
  include Bpluser::Users::RegistrationsController
end
class Users::SessionsController < Devise::SessionsController
  include Bpluser::Users::SessionsController
end
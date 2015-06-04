class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  #https://github.com/plataformatec/devise/issues/2432

  # this is the only spot where we allow CSRF, our openid / oauth redirect
  # will not have a CSRF token, however the payload is all validated so its safe
  skip_before_filter :verify_authenticity_token

  include Bpluser::Users::OmniauthCallbacksController
end
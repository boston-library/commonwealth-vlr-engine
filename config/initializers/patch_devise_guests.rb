require DeviseGuests::Engine.root.join(CommonwealthVlrEngine::Engine.root, 'config','initializers','patch_devise_guests')

DeviseGuests::Controllers::Helpers.module_eval do
  def guest_uid_authentication_key key
    key &&= nil unless key.to_s.match(/^guest/)
    key ||= "guest_#{guest_user_unique_suffix}@example.com"
  end
end

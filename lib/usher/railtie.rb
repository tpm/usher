module Usher
  class Engine < ::Rails::Railtie
    initializer 'monkey_patches' do |app|
      ActiveSupport::MessageVerifier.send(:include, MonkeyPatches::MessageVerifier)
      ActionDispatch::Cookies::SignedCookieJar.send(:include, MonkeyPatches::SignedCookieJar)
    end
  end if defined?(Rails)
end

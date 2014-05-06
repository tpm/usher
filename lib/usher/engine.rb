module Usher
  class Engine < ::Rails::Engine
    isolate_namespace Usher

    initializer 'monkey_patches' do |app|
      ActiveSupport::MessageVerifier.send(:include, Railties::MessageVerifier)
      ActionDispatch::Cookies::SignedCookieJar.send(:include, Railties::SignedCookieJar)
    end
  end
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "usher/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "usher"
  s.version     = Usher::VERSION
  s.authors     = ["Matthew Wozniak"]
  s.email       = ["matt@talkingpointsmemo.com"]
  s.homepage    = "https://github.com/tpm/usher"
  s.summary     = "MessagePack-based serialization for Rails sessions"
  s.description = "Serialize your rails sessions with MessagePack!"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "activesupport", ">= 3.2"
  s.add_dependency "msgpack", "~> 0.5.8"
  s.add_dependency "facets", "~> 3.0.0"
end

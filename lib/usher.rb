require 'base64'
require 'msgpack'
require 'facets/hash/recurse'
require 'facets/hash/stringify_keys'

require 'usher/blob'
require 'usher/corrupt_blob'
require 'usher/flags'
require 'usher/mutable_flags'
require 'usher/unpacker'
require 'usher/packer'
require 'usher/monkey_patches'
require 'usher/railtie'

module Usher
  PRIMITIVES  = [ Hash, Array, String, Fixnum, Float, TrueClass, FalseClass, NilClass ]
  NOFLAGS     = Flags.new(0).freeze

  def self.load(data)
    Unpacker.new(data).unpack
  end

  def self.dump(object)
    Packer.new(object).pack
  end
end

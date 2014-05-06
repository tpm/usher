# encoding: UTF-8

module Usher
  class Blob
    def corrupt?
      CorruptBlob === self
    end

    # we write out ~CLASS|DATA format so object is inspectable from outside Ruby
    def to_msgpack(pk = nil)
      return MessagePack.pack(self, pk) unless pk.class == MessagePack::Packer
      pk.write("~#{@object.class.name}|#{Base64.urlsafe_encode64(Marshal.dump(@object))}")
      pk
    end

    def initialize(object)
      @object = object
    end

    # Unmarshal the DATA part of ~CLASS|DATA
    def self.load(data)
      Marshal.load(Base64.urlsafe_decode64(data.split(?|, 2)[1]))
    rescue
      CorruptBlob.new(data)
    end
  end # Blob
end # Usher
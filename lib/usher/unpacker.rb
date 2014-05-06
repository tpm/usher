# encoding: UTF-8

module Usher
  class Unpacker
    def unpack
      unpack_object(MessagePack.load(@data))
    end

    def unpack_object(object, flags = NOFLAGS)
      case object
      when Hash
        unpack_hash(object)
      when Array
        unpack_array(object)
      when String
        flags.blob? ? unpack_blob(object) : unpack_primitive(object)
      else
        unpack_primitive(object)
      end
    end

    def unpack_hash(hash)
      meta = packed_meta(nil => hash.delete(nil))

      Hash[
        hash.map { |key, val|
          [
            meta[key].symbol? ? key.to_s : key.to_s,  # hash key
            unpack_object(val, meta[key])             # hash value
          ]
        }
      ]
    end

    def unpack_array(ary)
      meta = packed_meta(ary.pop)
      ary.each_with_index.map { |elem, idx| unpack_object(elem, meta[idx]) }
    end

    def unpack_blob(data)
      Blob.load(data)
    end

    def unpack_primitive(obj)
      obj
    end

    def packed_meta(nilhash)
      flags = Hash === nilhash && nilhash[nil]
      flags = Hash === flags ? flags : {}
      Hash.new { |h, k| h[k] = Flags.new(flags[k]) }
    end

    def initialize(data)
      @data = data
    end
  end # Unpacker
end # Usher
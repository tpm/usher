# encoding: UTF-8

module Usher
  class Packer
    def pack
      packed = pack_object(@root)

      packed.to_msgpack
    end

    def pack_object(obj)
      if PRIMITIVES.include?(obj.class)
        pobj = case obj
        when Hash
          pack_hash(obj)
        when Array
          pack_array(obj)
        else
          pack_primitive(obj)
        end
      else
        pobj = pack_blob(obj)
      end

      yield(pobj) if block_given?

      pobj
    end

    def pack_hash(hash)
      meta = Hash.new { |h, k| h[k] = MutableFlags.new }

      Hash[
        hash.map { |key, val|
          pack_pair(key, val, meta)
        }.sort_by { |key, _| key } << [ nil, normalize_meta(meta) ]
      ]
    end

    def pack_pair(key, val, meta)
      pkey = key.to_s
      pval = pack_object(val)

      meta[pkey].symbol! if Symbol === key
      meta[pkey].blob!   if Blob   === pval
      
      [ pkey, pval ]
    end

    def pack_array(ary)
      meta = Hash.new { |h, k| h[k] = MutableFlags.new }

      ary.each_with_index.map { |elem, idx|
        pack_object(elem) { |pelem| meta[idx].blob! if Blob === pelem }
      }.map { |pelem, _| pelem } << { nil => normalize_meta(meta) }
    end

    def pack_blob(obj)
      Blob.new(obj)
    end

    def pack_primitive(obj)
      obj
    end

    # remove meta pairs with empty flags
    def normalize_meta(meta)
      Hash[
        meta.
          delete_if { |_, flags| flags.empty? }.
          map { |key, flags| [ key, flags.to_i ] }
      ]
    end

    def initialize(root)
      @root = root
    end
  end # Packer
end # Usher
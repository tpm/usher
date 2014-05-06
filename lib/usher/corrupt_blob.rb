# encoding: UTF-8

module Usher
  # Se we can handle serialization errors at the Ruby level without exceptions
  class CorruptBlob < Blob
    def initialize(data)
      @data = data
    end
  end # CorruptBlob
end # Usher
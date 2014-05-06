# encoding: UTF-8

module Usher
  class MutableFlags < Flags
    def blob!
      @value |= BLOB
    end

    def symbol!
      @value |= SYMBOL
    end

    def initialize
      @value = 0
    end
  end # MutableFlags
end # Usher
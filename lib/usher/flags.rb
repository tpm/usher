# encoding: UTF-8

module Usher
  class Flags
    BLOB   = 0b0001
    SYMBOL = 0b0010

    def blob?
      flag?(Flags::BLOB)
    end

    def symbol?
      flag?(Flags::SYMBOL)
    end

    def flag?(flag)
      !(@value & flag).zero?
    end

    def to_i
      @value
    end

    def empty?
      @value.zero?
    end

    def initialize(val)
      @value = (val || 0).to_i
    end
  end # Flags
end # Usher
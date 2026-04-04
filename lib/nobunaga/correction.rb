# frozen_string_literal: true

module Nobunaga
  # Byte-offset range replacement applied to UTF-8 source (end_byte exclusive).
  class Correction
    attr_reader :begin_byte, :end_byte, :replacement

    def initialize(begin_byte, end_byte, replacement = "")
      @begin_byte = begin_byte
      @end_byte = end_byte
      @replacement = replacement
      raise ArgumentError, "begin_byte must be <= end_byte" if begin_byte > end_byte
    end

    def empty?
      replacement.empty? && begin_byte == end_byte
    end
  end
end

# frozen_string_literal: true

module Nobunaga
  module Autocorrect
    module_function

    # Apply corrections from high byte offsets first so indices stay valid.
    def apply(source, corrections)
      list = corrections.reject(&:empty?).sort_by { |c| -c.begin_byte }
      out = source.dup.force_encoding(Encoding::UTF_8)
      list.each do |c|
        out = out.byteslice(0, c.begin_byte) + c.replacement + out.byteslice(c.end_byte..-1)
      end
      out
    end

    def conflicting?(corrections)
      sorted = corrections.sort_by(&:begin_byte)
      sorted.each_cons(2) do |a, b|
        return true if a.end_byte > b.begin_byte
      end
      false
    end
  end
end

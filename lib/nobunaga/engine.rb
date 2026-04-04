# frozen_string_literal: true

module Nobunaga
  # Pure-Ruby engine placeholder; later swap for native extension + Prism.
  module Engine
    module_function

    RULE_TRAILING_WS = "Layout/TrailingWhitespace"

    def inspect_source(path, source)
      offenses = []
      offenses.concat(trailing_whitespace_offenses(path, source))
      offenses
    end

    def trailing_whitespace_offenses(path, source)
      return [] if source.empty?

      offenses = []
      offset = 0
      source.each_line do |line|
        if (m = line.match(/\A(.*?)((?:[ \t]+))(\r?\n)\z/))
          body, ws, nl = m.captures
          ws_start = offset + body.bytesize
          ws_end = ws_start + ws.bytesize
          line_no = line_number_at_byte(source, ws_start)
          col = column_at_byte(source, ws_start)
          offenses << Offense.new(
            path: path,
            line: line_no,
            column: col,
            message: "Trailing whitespace detected.",
            rule_id: RULE_TRAILING_WS,
            corrections: [Correction.new(ws_start, ws_end, "")]
          )
        elsif (m = line.match(/\A(.*?)((?:[ \t]+))\z/))
          body, ws = m.captures
          next if ws.empty?

          ws_start = offset + body.bytesize
          ws_end = ws_start + ws.bytesize
          line_no = line_number_at_byte(source, ws_start)
          col = column_at_byte(source, ws_start)
          offenses << Offense.new(
            path: path,
            line: line_no,
            column: col,
            message: "Trailing whitespace detected.",
            rule_id: RULE_TRAILING_WS,
            corrections: [Correction.new(ws_start, ws_end, "")]
          )
        end
        offset += line.bytesize
      end
      offenses
    end

    def line_number_at_byte(source, byte_index)
      source.byteslice(0, byte_index).count("\n") + 1
    end

    def column_at_byte(source, byte_index)
      prefix = source.byteslice(0, byte_index)
      line_start = (prefix.rindex("\n") || -1) + 1
      source.byteslice(line_start, byte_index - line_start).length + 1
    end
  end
end

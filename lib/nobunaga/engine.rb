# frozen_string_literal: true

module Nobunaga
  # Combines native (Prism + AST rules) and Ruby-only rules (e.g. layout).
  module Engine
    module_function

    RULE_TRAILING_WS = "Layout/TrailingWhitespace"

    def inspect_source(path, source)
      offenses = []
      offenses.concat(native_offenses(path, source))
      offenses.concat(trailing_whitespace_offenses(path, source))
      offenses
    end

    def native_offenses(path, source)
      rows = Native.inspect_source(path, source)
      return [] if rows.nil? || rows.empty?

      rows.map do |row|
        h = row.is_a?(Hash) ? row : row.to_h
        corrections = h[:corrections] || h["corrections"] || []
        corr_objs = Array(corrections).map do |c|
          next unless c

          ch = c.is_a?(Hash) ? c : c.to_h
          Correction.new(
            Integer(ch[:begin_byte] || ch["begin_byte"]),
            Integer(ch[:end_byte] || ch["end_byte"]),
            (ch[:replacement] || ch["replacement"]).to_s
          )
        end.compact
        Offense.new(
          path: (h[:path] || h["path"]).to_s,
          line: Integer(h[:line] || h["line"]),
          column: Integer(h[:column] || h["column"]),
          message: (h[:message] || h["message"]).to_s,
          rule_id: (h[:rule_id] || h["rule_id"]).to_s,
          corrections: corr_objs
        )
      end
    end

    def trailing_whitespace_offenses(path, source)
      return [] if source.empty?

      offenses = []
      offset = 0
      source.each_line do |line|
        if (m = line.match(/\A(.*?)((?:[ \t]+))(\r?\n)\z/))
          body, ws, _nl = m.captures
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

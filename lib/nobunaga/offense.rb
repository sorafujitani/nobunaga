# frozen_string_literal: true

module Nobunaga
  class Offense
    attr_reader :path, :line, :column, :message, :rule_id, :corrections

    def initialize(path:, line:, column:, message:, rule_id:, corrections: [])
      @path = path
      @line = line
      @column = column
      @message = message
      @rule_id = rule_id
      @corrections = corrections.freeze
      freeze
    end

    def autocorrectable?
      corrections.any?
    end
  end
end

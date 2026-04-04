# frozen_string_literal: true

module Nobunaga
  begin
    require "nobunaga/nobunaga"
  rescue LoadError
    module Native
      module_function

      def inspect_source(_path, _source)
        []
      end
    end
  end
end

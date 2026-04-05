# frozen_string_literal: true

require "minitest/autorun"
require "nobunaga"

class NativeParseErrorTest < Minitest::Test
  def test_prism_syntax_offense_on_invalid_ruby
    skip "native extension not loaded" unless extension_loaded?

    src = "def broken\n"
    offenses = Nobunaga::Engine.inspect_source("(fragment)", src)
    syn = offenses.find { |o| o.rule_id == "Syntax/PrismParseError" }
    refute_nil syn, "expected a Prism parse error diagnostic"
  end

  def extension_loaded?
    require "nobunaga/nobunaga"
    true
  rescue LoadError
    false
  end
end

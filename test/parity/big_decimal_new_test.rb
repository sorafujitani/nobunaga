# frozen_string_literal: true

require "minitest/autorun"
require "json"
require "open3"
require "pathname"
require "nobunaga"

class BigDecimalNewParityTest < Minitest::Test
  FIXTURE = Pathname.new(__dir__).join("../fixtures/parity/big_decimal_new_offense.rb").expand_path

  def test_nobunaga_reports_same_line_as_rubocop
    skip "native extension not loaded" unless extension_loaded?

    source = File.read(FIXTURE, encoding: Encoding::UTF_8)
    nob = Nobunaga::Engine.inspect_source(FIXTURE.to_s, source)
    big = nob.find { |o| o.rule_id == "Lint/BigDecimalNew" }
    refute_nil big, "expected Lint/BigDecimalNew offense"

    rubo_line = rubocop_offense_line(FIXTURE.to_s)
    refute_nil rubo_line, "RuboCop should report an offense for fixture"

    assert_equal rubo_line, big.line, "line should match RuboCop for KGI parity"
  end

  def extension_loaded?
    require "nobunaga/nobunaga"
    true
  rescue LoadError
    false
  end

  def rubocop_offense_line(path)
    rubocop = Gem.bin_path("rubocop", "rubocop")
    cmd = [Gem.ruby, "-S", rubocop, "--only", "Lint/BigDecimalNew", "-f", "json", path]
    out, _err, status = Open3.capture3(*cmd)
    return nil unless status.success? || out.include?("offenses")

    data = JSON.parse(out)
    abs = File.expand_path(path)
    file = data.fetch("files", []).find { |f| [f["path"], File.expand_path(f["path"].to_s)].include?(abs) }
    return nil unless file

    off = file.fetch("offenses", []).find { |o| o["cop_name"] == "Lint/BigDecimalNew" }
    return nil unless off

    Integer(off.dig("location", "start_line"))
  rescue JSON::ParserError, Gem::GemNotFoundException
    nil
  end
end

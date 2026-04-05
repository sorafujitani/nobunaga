# frozen_string_literal: true

require "minitest/autorun"
require "json"
require "open3"
require "pathname"
require "nobunaga"

class DebuggerParityTest < Minitest::Test
  FIXTURE = Pathname.new(__dir__).join("../fixtures/parity/debugger_offense.rb").expand_path

  def test_nobunaga_same_line_as_rubocop_for_debugger
    skip "native extension not loaded" unless extension_loaded?

    source = File.read(FIXTURE, encoding: Encoding::UTF_8)
    nob = Nobunaga::Engine.inspect_source(FIXTURE.to_s, source)
    dbg = nob.find { |o| o.rule_id == "Lint/Debugger" }
    refute_nil dbg, "expected Lint/Debugger offense"

    rubo_line = rubocop_offense_line(FIXTURE.to_s, "Lint/Debugger")
    refute_nil rubo_line, "RuboCop should report Lint/Debugger for fixture"

    assert_equal rubo_line, dbg.line
  end

  def extension_loaded?
    require "nobunaga/nobunaga"
    true
  rescue LoadError
    false
  end

  def rubocop_offense_line(path, cop_name)
    rubocop = Gem.bin_path("rubocop", "rubocop")
    cmd = [Gem.ruby, "-S", rubocop, "--only", cop_name, "-f", "json", path]
    out, _err, status = Open3.capture3(*cmd)
    return nil unless status.success? || out.include?("offenses")

    data = JSON.parse(out)
    abs = File.expand_path(path)
    file = data.fetch("files", []).find { |f| [f["path"], File.expand_path(f["path"].to_s)].include?(abs) }
    return nil unless file

    off = file.fetch("offenses", []).find { |o| o["cop_name"] == cop_name }
    return nil unless off

    Integer(off.dig("location", "start_line"))
  rescue JSON::ParserError, Gem::GemNotFoundException
    nil
  end
end

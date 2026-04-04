# frozen_string_literal: true

require "minitest/autorun"
require "nobunaga"
require "tmpdir"
require "fileutils"

class NobunagaAutocorrectTest < Minitest::Test
  def test_apply_trailing_whitespace
    source = "x  \ny\t \n"
    path = "(string)"
    offenses = Nobunaga::Engine.inspect_source(path, source)
    assert_equal 2, offenses.size
    corrections = offenses.flat_map(&:corrections)
    refute Nobunaga::Autocorrect.conflicting?(corrections)
    fixed = Nobunaga::Autocorrect.apply(source, corrections)
    assert_equal "x\ny\n", fixed
  end

  def test_fix_command_writes_file
    Dir.mktmpdir do |dir|
      f = File.join(dir, "a.rb")
      File.write(f, "def a  \nend\n")
      runner = Nobunaga::Runner.new
      changed, remaining = runner.fix_paths([f])
      assert_equal 1, changed
      assert_empty remaining
      assert_equal "def a\nend\n", File.read(f)
    end
  end

  def test_check_exit_style
    runner = Nobunaga::Runner.new
    Dir.mktmpdir do |dir|
      clean = File.join(dir, "c.rb")
      File.write(clean, "x\n")
      assert_empty runner.check_paths([clean])
    end
  end
end

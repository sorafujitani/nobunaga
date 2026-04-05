# frozen_string_literal: true

require "minitest/autorun"
require "json"
require "open3"
require "pathname"
require "nobunaga"

class CliJsonTest < Minitest::Test
  def test_check_format_json_stdout
    Dir.mktmpdir do |dir|
      f = File.join(dir, "x.rb")
      File.write(f, "debugger\n")
      out, _err, st = Open3.capture3(
        Gem.ruby, "-I#{File.expand_path("../lib", __dir__)}",
        File.expand_path("../exe/nobunaga", __dir__),
        "check", "--format", "json", f
      )
      assert_equal 1, st.exitstatus
      rows = JSON.parse(out)
      assert_kind_of Array, rows
      assert(rows.any? { |r| r["rule_id"] == "Lint/Debugger" })
    end
  end
end

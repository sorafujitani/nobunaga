# frozen_string_literal: true

require "json"
require "optparse"

module Nobunaga
  class CLI
    def self.start(argv = ARGV)
      new.start(argv)
    end

    def start(argv)
      global = OptionParser.new do |o|
        o.banner = "Usage: nobunaga check [options] [paths...]\n       nobunaga fix [paths...]\n       nobunaga --help"
        o.on("-h", "--help", "Show help") do
          puts o.help
          exit 0
        end
      end

      args = argv.dup
      if args.empty? || args.first == "-h" || args.first == "--help"
        puts global.help
        return 0
      end

      command = args.shift
      unless %w[check fix].include?(command)
        warn "nobunaga: unknown command #{command.inspect} (expected check or fix)"
        warn global.help
        return 2
      end

      runner = Runner.new

      case command
      when "check"
        format = "text"
        check_opts = OptionParser.new do |o|
          o.on("--format FMT", String, "Output format: text (default) or json") do |f|
            format = f
          end
        end
        check_opts.parse!(args)
        unless %w[text json].include?(format)
          warn "nobunaga: unknown format #{format.inspect} (expected text or json)"
          return 2
        end

        paths = args.empty? ? ["."] : args
        offenses = runner.check_paths(paths)
        if format == "json"
          puts JSON.generate(offenses.map { |off| offense_to_h(off) })
        else
          offenses.each { |off| puts format_offense(off) }
        end
        offenses.empty? ? 0 : 1
      when "fix"
        paths = args.empty? ? ["."] : args
        _changed, remaining = runner.fix_paths(paths)
        remaining.each { |off| puts format_offense(off) }
        remaining.any? ? 1 : 0
      end
    end

    def offense_to_h(off)
      {
        "path" => off.path,
        "line" => off.line,
        "column" => off.column,
        "message" => off.message,
        "rule_id" => off.rule_id,
        "autocorrectable" => off.autocorrectable?
      }
    end

    def format_offense(off)
      "#{off.path}:#{off.line}:#{off.column}: #{off.message} [#{off.rule_id}]"
    end
  end
end

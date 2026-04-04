# frozen_string_literal: true

require "optparse"

module Nobunaga
  class CLI
    def self.start(argv = ARGV)
      new.start(argv)
    end

    def start(argv)
      global = OptionParser.new do |o|
        o.banner = "Usage: nobunaga check [paths...]\n       nobunaga fix [paths...]\n       nobunaga --help"
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

      paths = args.empty? ? ["."] : args
      runner = Runner.new

      case command
      when "check"
        offenses = runner.check_paths(paths)
        offenses.each { |off| puts format_offense(off) }
        offenses.empty? ? 0 : 1
      when "fix"
        changed, remaining = runner.fix_paths(paths)
        remaining.each { |off| puts format_offense(off) }
        if remaining.any?
          1
        else
          changed.positive? ? 0 : 0
        end
      end
    end

    def format_offense(off)
      "#{off.path}:#{off.line}:#{off.column}: #{off.message} [#{off.rule_id}]"
    end
  end
end

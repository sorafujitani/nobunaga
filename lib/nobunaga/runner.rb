# frozen_string_literal: true

module Nobunaga
  class Runner
    def initialize(engine: Engine)
      @engine = engine
    end

    def each_target_path(paths)
      return enum_for(:each_target_path, paths) unless block_given?

      Array(paths).each do |entry|
        p = File.expand_path(entry)
        unless File.exist?(p)
          warn "nobunaga: skip missing path: #{entry}"
          next
        end
        if File.directory?(p)
          Dir.glob(File.join(p, "**", "*.rb"), File::FNM_DOTMATCH).sort.each { |f| yield f if File.file?(f) }
        elsif File.file?(p)
          yield p
        end
      end
    end

    def check_paths(paths)
      offenses = []
      each_target_path(paths) do |path|
        source = File.read(path, encoding: Encoding::UTF_8)
        offenses.concat(@engine.inspect_source(path, source))
      end
      offenses
    end

    def fix_paths(paths, out: $stdout)
      changed_files = 0
      remaining = []
      each_target_path(paths) do |path|
        source = File.read(path, encoding: Encoding::UTF_8)
        file_offenses = @engine.inspect_source(path, source)
        correctable = file_offenses.select(&:autocorrectable?)
        corrections = correctable.flat_map(&:corrections)
        if corrections.empty?
          remaining.concat(file_offenses)
          next
        end
        if Autocorrect.conflicting?(corrections)
          warn "nobunaga: skipping #{path}: overlapping corrections"
          remaining.concat(file_offenses)
          next
        end
        new_source = Autocorrect.apply(source, corrections)
        if new_source != source
          File.write(path, new_source)
          changed_files += 1
          out.puts "Fixed #{correctable.size} offense(s) in #{path}"
        end
        # Re-inspect for remaining (e.g. non-autocorrectable)
        still = @engine.inspect_source(path, File.read(path, encoding: Encoding::UTF_8))
        remaining.concat(still.reject(&:autocorrectable?))
      end
      [changed_files, remaining]
    end
  end
end

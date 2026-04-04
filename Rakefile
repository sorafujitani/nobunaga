# frozen_string_literal: true

require "rake/testtask"
require "fileutils"
require "rbconfig"

desc "Build the Rust extension into lib/nobunaga/"
task :compile do
  ext = File.expand_path("ext/nobunaga", __dir__)
  dest_dir = File.expand_path("lib/nobunaga", __dir__)
  FileUtils.mkdir_p(dest_dir)
  sh "cargo build --release --manifest-path #{File.join(ext, 'Cargo.toml')} --locked"
  profile = "release"
  dlext = RbConfig::CONFIG["DLEXT"]
  pattern = File.join(ext, "target", profile, "libnobunaga.*")
  built = Dir[pattern].find { |f| f.match?(/\.(so|dylib|dll)\z/) }
  raise "native library not found (glob: #{pattern})" unless built

  out = File.join(dest_dir, "nobunaga.#{dlext}")
  FileUtils.cp(built, out)
  puts "Installed #{out}"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task test: :compile
task default: :test

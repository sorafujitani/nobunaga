# frozen_string_literal: true

require "rake/testtask"
require "rb_sys/extensiontask"

REPO_ROOT = __dir__
GEMSPEC = Gem::Specification.load(File.expand_path("nobunaga.gemspec", REPO_ROOT))

# Default RbSys source_files globs match `**/Cargo.lock` and pull in bundled gems' manifests.
class NobunagaExtensionTask < RbSys::ExtensionTask
  def source_files
    list = FileList[
      "#{ext_dir}/**/*.{rs,rb,c,h,toml}",
      File.join(REPO_ROOT, "Cargo.toml"),
      File.join(REPO_ROOT, "Cargo.lock")
    ]
    list.exclude(File.join(target_directory, "**/*")) if defined?(target_directory)
    list
  end
end

Dir.chdir(File.join(REPO_ROOT, "ext/nobunaga")) do
  NobunagaExtensionTask.new("nobunaga", GEMSPEC) do |ext|
    # Must stay relative: rake-compiler computes Pathname relative to tmp build dir.
    ext.lib_dir = "lib/nobunaga"
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task test: :compile
task default: :test

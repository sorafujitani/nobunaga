# frozen_string_literal: true

require_relative "lib/nobunaga/version"

Gem::Specification.new do |spec|
  spec.name = "nobunaga"
  spec.version = Nobunaga::VERSION
  spec.authors = ["fujitani sora"]
  spec.summary = "Fast Ruby linter with Rust (Prism) extension"
  spec.homepage = "https://github.com/sorafujitani/nobunaga"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    libs = Dir["lib/**/*"].select { |p| File.file?(p) }
    bins = Dir["exe/*"].select { |p| File.file?(p) }
    ext = Dir["ext/nobunaga/**/*"].select { |p| File.file?(p) && !p.include?("/target/") }
    doc = Dir["docs/**/*"].select { |p| File.file?(p) }
    lock = File.file?("ext/nobunaga/Cargo.lock") ? ["ext/nobunaga/Cargo.lock"] : []
    (libs + bins + ext + doc + lock + %w[README.md LICENSE]).uniq
  end
  spec.extensions = ["ext/nobunaga/Cargo.toml"]
  spec.bindir = "exe"
  spec.executables = ["nobunaga"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "1.69.2"
end

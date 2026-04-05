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
    libs = Dir["lib/**/*"].select do |p|
      File.file?(p) && !p.match?(/\.(so|bundle|dylib|dll)\z/)
    end
    bins = Dir["exe/*"].select { |p| File.file?(p) }
    ext = Dir["ext/nobunaga/**/*"].select { |p| File.file?(p) && !p.include?("/target/") }
    doc = Dir["docs/**/*"].select { |p| File.file?(p) }
    root_cargo = %w[Cargo.toml Cargo.lock].select { |f| File.file?(f) }
    (libs + bins + ext + doc + root_cargo + %w[README.md LICENSE]).uniq
  end
  spec.extensions = ["ext/nobunaga/extconf.rb"]
  spec.bindir = "exe"
  spec.executables = ["nobunaga"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
  spec.add_development_dependency "rb_sys", "~> 0.9.126"
  spec.add_development_dependency "rubocop", "1.69.2"
end

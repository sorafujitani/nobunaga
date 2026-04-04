# frozen_string_literal: true

require_relative "lib/nobunaga/version"

Gem::Specification.new do |spec|
  spec.name = "nobunaga"
  spec.version = Nobunaga::VERSION
  spec.authors = ["fujitani sora"]
  spec.summary = "Fast Ruby linter (foundation; native engine planned)"
  spec.homepage = "https://github.com/fujitanisora/nobunaga"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*", "exe/*", "README.md", "LICENSE"].select { |path| File.file?(path) }
  spec.bindir = "exe"
  spec.executables = ["nobunaga"]
  spec.require_paths = ["lib"]
end

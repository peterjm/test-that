# frozen_string_literal: true

require_relative "lib/test_that/version"

Gem::Specification.new do |spec|
  spec.name = "test_that"
  spec.version = TestThat::VERSION
  spec.authors = ["Peter McCracken"]
  spec.email = ["peter@petermccracken.com"]

  spec.summary = "Run the right tests for the files you changed."
  spec.description =
    "Automatically detects your test framework and runs relevant tests based on changed or specified files."
  spec.homepage = "https://github.com/peterjm/test-that"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["source_code_uri"] = "https://github.com/peterjm/test-that"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.executables = ["test-that"]
  spec.require_paths = ["lib"]
end

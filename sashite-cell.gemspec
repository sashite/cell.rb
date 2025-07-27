# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-cell"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "CELL (Coordinate Encoding for Layered Locations) implementation for Ruby"
  spec.description            = "CELL defines a standardized format for representing coordinates on multi-dimensional game boards using a cyclical ASCII character system. This gem provides a Ruby interface for working with unlimited dimensional game coordinates through a clean, functional API that strictly follows the CELL Specification v1.0.0."
  spec.homepage               = "https://github.com/sashite/cell.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/cell.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/cell.rb/main",
    "homepage_uri"          => "https://github.com/sashite/cell.rb",
    "source_code_uri"       => "https://github.com/sashite/cell.rb",
    "specification_uri"     => "https://sashite.dev/specs/cell/1.0.0/",
    "wiki_uri"              => "https://sashite.dev/specs/cell/1.0.0/examples/",
    "funding_uri"           => "https://github.com/sponsors/sashite",
    "rubygems_mfa_required" => "true"
  }
end

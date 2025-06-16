# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-cell"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "CELL (Coordinate Expression Location Label) implementation for Ruby"
  spec.description            = "CELL defines a consistent and rule-agnostic format for representing locations in abstract strategy board games. This gem provides a Ruby interface for working with game locations, serving as a foundational building block for the Sashité notation ecosystem."
  spec.homepage               = "https://github.com/sashite/cell.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/cell.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/cell.rb/main",
    "homepage_uri"          => "https://github.com/sashite/cell.rb",
    "source_code_uri"       => "https://github.com/sashite/cell.rb",
    "specification_uri"     => "https://sashite.dev/documents/cell/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end

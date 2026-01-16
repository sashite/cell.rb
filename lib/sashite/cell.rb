# frozen_string_literal: true

require_relative "cell/errors"
require_relative "cell/formatter"
require_relative "cell/coordinate"
require_relative "cell/parser"

module Sashite
  # CELL (Coordinate Encoding for Layered Locations) implementation.
  #
  # Provides parsing, formatting, and validation of CELL coordinates
  # for multi-dimensional game boards (up to 3 dimensions).
  #
  # @example Parsing a coordinate
  #   coord = Sashite::Cell.parse("e4")
  #   coord.indices    # => [4, 3]
  #   coord.dimensions # => 2
  #
  # @example Formatting indices
  #   Sashite::Cell.format(4, 3) # => "e4"
  #
  # @example Validation
  #   Sashite::Cell.valid?("e4") # => true
  #   Sashite::Cell.valid?("a0") # => false
  #
  # @see https://sashite.dev/specs/cell/1.0.0/
  module Cell
    # Parses a CELL string into a Coordinate.
    #
    # @param string [String] CELL coordinate string
    # @return [Coordinate] parsed coordinate
    # @raise [Sashite::Cell::Errors::Argument] if the string is not a valid CELL coordinate
    #
    # @example
    #   Sashite::Cell.parse("e4")  # => #<Sashite::Cell::Coordinate e4>
    #   Sashite::Cell.parse("a1A") # => #<Sashite::Cell::Coordinate a1A>
    #   Sashite::Cell.parse("a0")  # => raises Sashite::Cell::Errors::Argument
    def self.parse(string)
      Coordinate.new(*Parser.parse_to_indices(string))
    end

    # Formats indices into a CELL string.
    #
    # @param indices [Array<Integer>] 0-indexed coordinate values (0-255)
    # @return [String] CELL coordinate string
    # @raise [Sashite::Cell::Errors::Argument] if indices are invalid
    #
    # @example
    #   Sashite::Cell.format(4, 3)    # => "e4"
    #   Sashite::Cell.format(0, 0, 0) # => "a1A"
    def self.format(*indices)
      Coordinate.new(*indices).to_s
    end

    # Validates a CELL string.
    #
    # @param string [String] CELL coordinate string
    # @return [nil]
    # @raise [Sashite::Cell::Errors::Argument] if the string is not a valid CELL coordinate
    #
    # @example
    #   Sashite::Cell.validate("e4")  # => nil
    #   Sashite::Cell.validate("a0")  # => raises Sashite::Cell::Errors::Argument
    def self.validate(string)
      Parser.parse_to_indices(string)
      nil
    end

    # Reports whether string is a valid CELL coordinate.
    #
    # @param string [String] CELL coordinate string
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Cell.valid?("e4")  # => true
    #   Sashite::Cell.valid?("a0")  # => false
    def self.valid?(string)
      validate(string)
      true
    rescue Errors::Argument
      false
    end
  end
end

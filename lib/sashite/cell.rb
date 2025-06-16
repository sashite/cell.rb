# frozen_string_literal: true

require_relative "cell/location"

# Sashité module providing implementations of various game notation specifications
#
# @see https://sashite.com/ Sashité
module Sashite
  # CELL (Coordinate Expression Location Label) implementation
  #
  # CELL defines a consistent and rule-agnostic format for representing locations
  # in abstract strategy board games. CELL provides a standardized way to identify
  # positions on game boards and pieces held in hand/reserve.
  #
  # @see https://sashite.dev/documents/cell/1.0.0/ CELL Specification v1.0.0
  module Cell
    # Regular expression for validating CELL notation
    #
    # Matches either:
    # - Hand/reserve location: exactly "*"
    # - Board coordinate: one or more alphanumeric characters [a-zA-Z0-9]
    #
    # @return [Regexp] the validation pattern
    CELL_PATTERN = /\A(#{::Regexp.escape(Location::HAND_CHAR)}|[a-zA-Z0-9]+)\z/

    # Check if a string is valid CELL notation
    #
    # @param cell_string [String] the string to validate
    # @return [Boolean] true if valid CELL notation, false otherwise
    #
    # @example Valid CELL strings
    #   Sashite::Cell.valid?("e4")      # => true
    #   Sashite::Cell.valid?("*")       # => true
    #   Sashite::Cell.valid?("A3a")     # => true
    #   Sashite::Cell.valid?("center")  # => true
    #
    # @example Invalid CELL strings
    #   Sashite::Cell.valid?("")        # => false
    #   Sashite::Cell.valid?("e-4")     # => false
    #   Sashite::Cell.valid?("@")       # => false
    #   Sashite::Cell.valid?("e4!")     # => false
    def self.valid?(cell_string)
      return false unless cell_string.is_a?(::String)

      CELL_PATTERN.match?(cell_string)
    end

    # Convenience method to create a Location object
    #
    # @param coordinate [String] the coordinate string in CELL format
    # @return [Location] a new Location object
    # @raise [ArgumentError] if the coordinate is invalid
    #
    # @example
    #   location = Sashite::Cell.location("e4")
    #   hand = Sashite::Cell.location("*")
    def self.location(coordinate)
      Location.new(coordinate)
    end
  end
end

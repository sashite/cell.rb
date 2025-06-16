# frozen_string_literal: true

require_relative "location/hand_char"

module Sashite
  module Cell
    # Represents a game location in CELL format
    #
    # A Location object encapsulates either a board coordinate (alphanumeric string)
    # or a hand/reserve location (the "*" character). This class provides methods
    # to distinguish between location types and convert to string representation.
    #
    # @see https://sashite.dev/documents/cell/1.0.0/ CELL Specification v1.0.0
    class Location
      # The coordinate string for this location
      # @return [String] the coordinate in CELL format
      attr_reader :coordinate

      # Create a new Location object
      #
      # @param coordinate [String] the coordinate string in CELL format
      # @raise [ArgumentError] if the coordinate is not valid CELL notation
      #
      # @example Create board locations
      #   Location.new("e4")      # Chess square
      #   Location.new("5c")      # Shōgi square
      #   Location.new("A3a")     # 3D coordinate
      #   Location.new("center")  # Custom coordinate
      #
      # @example Create hand/reserve location
      #   Location.new("*")       # Hand/reserve
      def initialize(coordinate)
        raise ::ArgumentError, "Invalid CELL coordinate: #{coordinate.inspect}" unless Sashite::Cell.valid?(coordinate)

        @coordinate = coordinate.freeze

        freeze
      end

      # Parse a CELL string into a Location object
      #
      # @param cell_string [String] the CELL string to parse
      # @return [Location] a new Location object
      # @raise [ArgumentError] if the string is not valid CELL notation
      #
      # @example
      #   location = Location.parse("e4")
      #   hand = Location.parse("*")
      def self.parse(cell_string)
        new(cell_string)
      end

      # Check if this location represents a board coordinate
      #
      # @return [Boolean] true if this is a board coordinate, false if hand/reserve
      #
      # @example
      #   Location.new("e4").board?  # => true
      #   Location.new("*").board?   # => false
      def board?
        @coordinate != HAND_CHAR
      end

      # Check if this location represents a hand/reserve location
      #
      # @return [Boolean] true if this is hand/reserve, false if board coordinate
      #
      # @example
      #   Location.new("e4").hand?  # => false
      #   Location.new("*").hand?   # => true
      def hand?
        @coordinate == HAND_CHAR
      end

      # Convert to CELL string representation
      #
      # @return [String] the coordinate in CELL format
      #
      # @example
      #   Location.new("e4").to_s  # => "e4"
      #   Location.new("*").to_s   # => "*"
      def to_s
        @coordinate
      end

      # Detailed string representation for debugging
      #
      # @return [String] detailed representation showing class and coordinate
      #
      # @example
      #   Location.new("e4").inspect
      #   # => "#<Sashite::Cell::Location:0x... @coordinate=\"e4\">"
      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} @coordinate=#{@coordinate.inspect}>"
      end

      # Compare locations for equality
      #
      # Two locations are equal if they have the same coordinate string.
      #
      # @param other [Object] the object to compare with
      # @return [Boolean] true if locations are equal
      #
      # @example
      #   loc1 = Location.new("e4")
      #   loc2 = Location.new("e4")
      #   loc1 == loc2  # => true
      def ==(other)
        other.is_a?(Location) && @coordinate == other.coordinate
      end

      # Strict equality comparison
      #
      # @param other [Object] the object to compare with
      # @return [Boolean] true if objects are equal
      def eql?(other)
        self == other
      end

      # Hash value for use in collections
      #
      # Ensures that equal locations have the same hash value.
      #
      # @return [Integer] hash value based on coordinate
      #
      # @example
      #   locations = Set.new
      #   locations << Location.new("e4")
      #   locations << Location.new("e4")  # Won't be added (same hash)
      #   locations.size  # => 1
      def hash
        [self.class, @coordinate].hash
      end
    end
  end
end

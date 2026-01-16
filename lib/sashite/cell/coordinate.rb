# frozen_string_literal: true

require_relative "constants"
require_relative "errors"
require_relative "formatter"

module Sashite
  module Cell
    # Represents a parsed CELL coordinate with up to 3 dimensions.
    #
    # A Coordinate holds 0-indexed integer values for each dimension
    # and provides conversion to/from CELL string format.
    #
    # @example Creating a coordinate
    #   coord = Sashite::Cell::Coordinate.new(4, 3)
    #   coord.indices    # => [4, 3]
    #   coord.dimensions # => 2
    #   coord.to_s       # => "e4"
    #
    # @example 3D coordinate
    #   coord = Sashite::Cell::Coordinate.new(0, 0, 0)
    #   coord.to_s # => "a1A"
    class Coordinate
      # Returns the coordinate indices as a frozen array.
      #
      # @return [Array<Integer>] 0-indexed coordinate values
      #
      # @example
      #   Sashite::Cell::Coordinate.new(4, 3).indices # => [4, 3]
      attr_reader :indices

      # Creates a Coordinate from 1 to 3 indices.
      #
      # @param indices [Array<Integer>] 0-indexed coordinate values (0-255 each)
      # @raise [Sashite::Cell::Errors::Argument] if no indices provided, more than 3, or values out of range
      #
      # @example
      #   Sashite::Cell::Coordinate.new(4, 3)    # 2D coordinate
      #   Sashite::Cell::Coordinate.new(0, 0, 0) # 3D coordinate
      def initialize(*indices)
        if indices.empty?
          raise Errors::Argument, Errors::Argument::Messages::NO_INDICES
        end

        if indices.size > Constants::MAX_DIMENSIONS
          raise Errors::Argument, Errors::Argument::Messages::TOO_MANY_DIMENSIONS
        end

        indices.each do |index|
          unless index.is_a?(::Integer) && index >= 0 && index <= Constants::MAX_INDEX_VALUE
            raise Errors::Argument, Errors::Argument::Messages::INDEX_OUT_OF_RANGE
          end
        end

        @indices = indices.freeze
      end

      # Returns the number of dimensions (1, 2, or 3).
      #
      # @return [Integer] dimension count
      #
      # @example
      #   Sashite::Cell::Coordinate.new(4, 3).dimensions # => 2
      def dimensions
        @indices.size
      end

      # Returns the CELL string representation.
      #
      # @return [String] CELL coordinate string
      #
      # @example
      #   Sashite::Cell::Coordinate.new(4, 3).to_s # => "e4"
      def to_s
        Formatter.indices_to_string(@indices)
      end

      # Checks equality with another Coordinate.
      #
      # @param other [Object] object to compare
      # @return [Boolean] true if equal, false otherwise
      #
      # @example
      #   Sashite::Cell::Coordinate.new(4, 3) == Sashite::Cell::Coordinate.new(4, 3) # => true
      def ==(other)
        other.is_a?(Coordinate) && @indices == other.indices
      end

      alias eql? ==

      # Returns hash code for use in Hash keys.
      #
      # @return [Integer] hash code
      #
      # @example
      #   coord = Sashite::Cell::Coordinate.new(4, 3)
      #   hash = { coord => "value" }
      def hash
        @indices.hash
      end

      # Returns a human-readable representation.
      #
      # @return [String] inspection string
      #
      # @example
      #   Sashite::Cell::Coordinate.new(4, 3).inspect # => "#<Sashite::Cell::Coordinate e4>"
      def inspect
        "#<#{self.class} #{self}>"
      end
    end
  end
end

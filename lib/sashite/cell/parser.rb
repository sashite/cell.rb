# frozen_string_literal: true

module Sashite
  module Cell
    # Parses CELL coordinate strings into index arrays.
    #
    # @example
    #   Parser.parse_to_indices("e4")  # => [4, 3]
    #   Parser.parse_to_indices("a1A") # => [0, 0, 0]
    #
    # @api private
    module Parser
      # Parses a CELL string into an array of indices.
      #
      # @param string [String] CELL coordinate string
      # @return [Array<Integer>] 0-indexed coordinate values
      # @raise [ArgumentError] if parsing fails
      def self.parse_to_indices(string)
        raise ::ArgumentError, "empty input" if string.empty?
        if string.length > Coordinate::MAX_STRING_LENGTH
          raise ::ArgumentError, "input exceeds #{Coordinate::MAX_STRING_LENGTH} characters"
        end
        raise ::ArgumentError, "must start with lowercase letter" unless string[0].match?(/[a-z]/)

        indices = []
        remaining = string
        dimension = 1

        until remaining.empty?
          value, consumed = parse_dimension(remaining, dimension)
          indices << value
          remaining = remaining[consumed..]
          dimension += 1
        end

        if indices.size > Coordinate::MAX_DIMENSIONS
          raise ::ArgumentError, "exceeds #{Coordinate::MAX_DIMENSIONS} dimensions"
        end

        indices
      end

      # Parses a single dimension from the remaining string.
      #
      # @param remaining [String] remaining string to parse
      # @param dimension [Integer] current dimension number (1-based)
      # @return [Array(Integer, Integer)] parsed value and characters consumed
      # @raise [ArgumentError] if parsing fails
      private_class_method def self.parse_dimension(remaining, dimension)
        case dimension % 3
        when 1 then parse_lowercase(remaining)
        when 2 then parse_integer(remaining)
        when 0 then parse_uppercase(remaining)
        end
      end

      # Parses lowercase letters dimension.
      #
      # @param remaining [String] remaining string to parse
      # @return [Array(Integer, Integer)] parsed value and characters consumed
      # @raise [ArgumentError] if parsing fails
      private_class_method def self.parse_lowercase(remaining)
        match = remaining.match(/\A([a-z]+)/)
        raise ::ArgumentError, "unexpected character" unless match

        value = decode_letters(match[1])
        raise ::ArgumentError, "index exceeds #{Coordinate::MAX_INDEX_VALUE}" if value > Coordinate::MAX_INDEX_VALUE

        [value, match[1].length]
      end

      # Parses positive integer dimension.
      #
      # @param remaining [String] remaining string to parse
      # @return [Array(Integer, Integer)] parsed value and characters consumed
      # @raise [ArgumentError] if parsing fails
      private_class_method def self.parse_integer(remaining)
        match = remaining.match(/\A(0|[1-9][0-9]*)/)
        raise ::ArgumentError, "unexpected character" unless match
        raise ::ArgumentError, "leading zero" if match[1] == "0"

        value = match[1].to_i - 1
        raise ::ArgumentError, "index exceeds #{Coordinate::MAX_INDEX_VALUE}" if value > Coordinate::MAX_INDEX_VALUE

        [value, match[1].length]
      end

      # Parses uppercase letters dimension.
      #
      # @param remaining [String] remaining string to parse
      # @return [Array(Integer, Integer)] parsed value and characters consumed
      # @raise [ArgumentError] if parsing fails
      private_class_method def self.parse_uppercase(remaining)
        match = remaining.match(/\A([A-Z]+)/)
        raise ::ArgumentError, "unexpected character" unless match

        value = decode_letters(match[1].downcase)
        raise ::ArgumentError, "index exceeds #{Coordinate::MAX_INDEX_VALUE}" if value > Coordinate::MAX_INDEX_VALUE

        [value, match[1].length]
      end

      # Decodes letter sequence to index (a=0, z=25, aa=26, ...).
      #
      # @param letters [String] lowercase letter sequence
      # @return [Integer] decoded index
      private_class_method def self.decode_letters(letters)
        letters = letters.downcase
        return letters.ord - "a".ord if letters.length == 1

        # Multi-letter: aa=26, ab=27, ..., zz=701
        result = 0
        letters.each_char do |char|
          result = (result * 26) + (char.ord - "a".ord)
        end
        result + 26
      end
    end
  end
end

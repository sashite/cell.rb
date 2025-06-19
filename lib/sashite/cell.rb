# frozen_string_literal: true

module Sashite
  # CELL (Cell Encoding Location Label) implementation for Ruby
  #
  # Provides functionality for working with multi-dimensional game board coordinates
  # using a cyclical ASCII character system.
  #
  # @see https://sashite.dev/documents/cell/1.0.0/ CELL Specification v1.0.0
  module Cell
    # Regular expression for validating CELL coordinates according to specification
    # This is the exact regex from the CELL specification v1.0.0
    # Using non-capturing groups to avoid Ruby's nested quantifier warning
    REGEX = /\A[a-z]+(?:[1-9]\d*[A-Z]+[a-z]+)*(?:[1-9]\d*(?:[A-Z]*))?\z/

    # Check if a string represents a valid CELL coordinate
    #
    # @param string [String] the string to validate
    # @return [Boolean] true if the string is a valid CELL coordinate
    #
    # @example
    #   Sashite::Cell.valid?("a1")     # => true
    #   Sashite::Cell.valid?("a1A")    # => true
    #   Sashite::Cell.valid?("*")      # => false
    #   Sashite::Cell.valid?("a0")     # => false
    def self.valid?(string)
      return false unless string.is_a?(String)
      return false if string.empty?

      # Use the formal regex for validation
      string.match?(REGEX)
    end

    # Get the number of dimensions in a coordinate
    #
    # @param string [String] the coordinate string
    # @return [Integer] the number of dimensions
    #
    # @example
    #   Sashite::Cell.dimensions("a1")     # => 2
    #   Sashite::Cell.dimensions("a1A")    # => 3
    #   Sashite::Cell.dimensions("foobar") # => 1
    def self.dimensions(string)
      return 0 unless valid?(string)

      parse(string).length
    end

    # Parse a coordinate string into dimensional components
    #
    # @param string [String] the coordinate string to parse
    # @return [Array<String>] array of dimensional components
    #
    # @example
    #   Sashite::Cell.parse("a1A")      # => ["a", "1", "A"]
    #   Sashite::Cell.parse("h8Hh8")    # => ["h", "8", "H", "h", "8"]
    #   Sashite::Cell.parse("foobar")   # => ["foobar"] (if valid single dimension)
    def self.parse(string)
      return [] unless string.is_a?(::String)
      return [] if string.empty?
      return [] unless valid?(string)

      parse_recursive(string, 1)
    end

    # Convert a CELL coordinate to an array of 0-indexed integers
    #
    # @param string [String] the CELL coordinate
    # @return [Array<Integer>] array of 0-indexed positions
    #
    # @example
    #   Sashite::Cell.to_indices("a1")   # => [0, 0]
    #   Sashite::Cell.to_indices("e4")   # => [4, 3]
    #   Sashite::Cell.to_indices("a1A")  # => [0, 0, 0]
    def self.to_indices(string)
      return [] unless valid?(string)

      parse(string).map.with_index do |component, index|
        dimension_type = dimension_type(index + 1)
        component_to_index(component, dimension_type)
      end
    end

    # Convert an array of 0-indexed integers to a CELL coordinate
    #
    # @param indices [Array<Integer>] splat arguments of 0-indexed positions
    # @return [String] the CELL coordinate
    #
    # @example
    #   Sashite::Cell.from_indices(0, 0)     # => "a1"
    #   Sashite::Cell.from_indices(4, 3)     # => "e4"
    #   Sashite::Cell.from_indices(0, 0, 0)  # => "a1A"
    def self.from_indices(*indices)
      return "" if indices.empty?

      result = indices.map.with_index do |index, dimension|
        dimension_type = dimension_type(dimension + 1)
        index_to_component(index, dimension_type)
      end.join

      # Verify the result is valid according to CELL specification
      valid?(result) ? result : ""
    end

    # Get the validation regular expression
    #
    # @return [Regexp] the CELL validation regex
    def self.regex
      REGEX
    end

    # Recursively parse a coordinate string into components
    # following the strict CELL specification pattern
    #
    # @param string [String] the remaining string to parse
    # @param dimension [Integer] the current dimension (1-indexed)
    # @return [Array<String>] array of dimensional components
    def self.parse_recursive(string, dimension)
      return [] if string.empty?

      expected_type = dimension_type(dimension)
      component = extract_component(string, expected_type)

      return [] if component.nil?

      # Invalid format according to CELL specification

      # Extract component and recursively parse the rest
      remaining = string[component.length..]
      [component] + parse_recursive(remaining, dimension + 1)
    end

    # Determine the character set type for a given dimension
    # Following CELL specification: dimension n % 3 determines character set
    #
    # @param dimension [Integer] the dimension number (1-indexed)
    # @return [Symbol] :lowercase, :numeric, or :uppercase
    def self.dimension_type(dimension)
      case dimension % 3
      when 1 then :lowercase
      when 2 then :numeric
      when 0 then :uppercase
      end
    end

    # Extract the next component from a string based on expected type
    # Strictly follows CELL specification patterns
    #
    # @param string [String] the string to extract from
    # @param type [Symbol] the expected component type
    # @return [String, nil] the extracted component or nil if invalid
    def self.extract_component(string, type)
      case type
      when :lowercase
        match = string.match(/\A([a-z]+)/)
        match ? match[1] : nil
      when :numeric
        # CELL specification requires positive integers only (no zero)
        match = string.match(/\A([1-9]\d*)/)
        match ? match[1] : nil
      when :uppercase
        match = string.match(/\A([A-Z]+)/)
        match ? match[1] : nil
      end
    end

    # Convert a component to its 0-indexed position
    #
    # @param component [String] the component
    # @param type [Symbol] the component type
    # @return [Integer] the 0-indexed position
    def self.component_to_index(component, type)
      case type
      when :lowercase
        letters_to_index(component)
      when :numeric
        component.to_i - 1
      when :uppercase
        letters_to_index(component.downcase)
      end
    end

    # Convert a 0-indexed position to a component
    #
    # @param index [Integer] the 0-indexed position
    # @param type [Symbol] the component type
    # @return [String] the component
    def self.index_to_component(index, type)
      case type
      when :lowercase
        index_to_letters(index)
      when :numeric
        (index + 1).to_s
      when :uppercase
        index_to_letters(index).upcase
      end
    end

    # Convert letter sequence to 0-indexed position
    # Extended alphabet: a=0, b=1, ..., z=25, aa=26, ab=27, ..., zz=701, aaa=702, etc.
    #
    # @param letters [String] the letter sequence
    # @return [Integer] the 0-indexed position
    def self.letters_to_index(letters)
      length = letters.length
      index = 0

      # Add positions from shorter sequences
      (1...length).each do |len|
        index += 26**len
      end

      # Add position within current length
      letters.each_char.with_index do |char, pos|
        index += (char.ord - 97) * (26**(length - pos - 1))
      end

      index
    end

    # Convert 0-indexed position to letter sequence
    # Extended alphabet: 0=a, 1=b, ..., 25=z, 26=aa, 27=ab, ..., 701=zz, 702=aaa, etc.
    #
    # @param index [Integer] the 0-indexed position
    # @return [String] the letter sequence
    def self.index_to_letters(index)
      # Find the length of the result
      length = 1
      base = 0

      loop do
        range_size = 26**length
        break if index < base + range_size

        base += range_size
        length += 1
      end

      # Convert within the found length
      adjusted_index = index - base
      result = ""

      length.times do |pos|
        char_index = adjusted_index / (26**(length - pos - 1))
        result += (char_index + 97).chr
        adjusted_index %= (26**(length - pos - 1))
      end

      result
    end
  end
end

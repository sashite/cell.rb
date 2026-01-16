# frozen_string_literal: true

require_relative "constants"
require_relative "errors"

module Sashite
  module Cell
    # Parses CELL coordinate strings into index arrays.
    #
    # This module handles the conversion from CELL string representation
    # to numeric indices, following the cyclic pattern:
    # - Dimension 1, 4, 7...: lowercase letters (a-z, aa-iv)
    # - Dimension 2, 5, 8...: positive integers (1-256)
    # - Dimension 3, 6, 9...: uppercase letters (A-Z, AA-IV)
    #
    # Security considerations:
    # - Character-by-character parsing (no regex, no ReDoS risk)
    # - Fail-fast on invalid input
    # - Bounded iteration (max 7 characters)
    # - Explicit ASCII validation
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
      # @raise [Sashite::Cell::Errors::Argument] if parsing fails
      #
      # @example
      #   Parser.parse_to_indices("e4")      # => [4, 3]
      #   Parser.parse_to_indices("iv256IV") # => [255, 255, 255]
      def self.parse_to_indices(string)
        raise Errors::Argument, Errors::Argument::Messages::EMPTY_INPUT if string.empty?

        if string.length > Constants::MAX_STRING_LENGTH
          raise Errors::Argument, Errors::Argument::Messages::INPUT_TOO_LONG
        end

        first_byte = string.getbyte(0)
        unless lowercase?(first_byte)
          raise Errors::Argument, Errors::Argument::Messages::INVALID_START
        end

        indices = []
        pos = 0
        dimension_type = 0 # 0: lowercase, 1: integer, 2: uppercase

        while pos < string.length
          if indices.size >= Constants::MAX_DIMENSIONS
            raise Errors::Argument, Errors::Argument::Messages::TOO_MANY_DIMENSIONS
          end

          case dimension_type
          when 0
            value, consumed = parse_lowercase(string, pos)
            indices << value
            pos += consumed
            dimension_type = 1
          when 1
            value, consumed = parse_integer(string, pos)
            indices << value
            pos += consumed
            dimension_type = 2
          when 2
            value, consumed = parse_uppercase(string, pos)
            indices << value
            pos += consumed
            dimension_type = 0
          end
        end

        indices
      end

      # Checks if a byte is a lowercase ASCII letter (a-z).
      #
      # @param byte [Integer, nil] byte value
      # @return [Boolean] true if lowercase letter
      private_class_method def self.lowercase?(byte)
        byte && byte >= 97 && byte <= 122 # 'a' = 97, 'z' = 122
      end

      # Checks if a byte is an uppercase ASCII letter (A-Z).
      #
      # @param byte [Integer, nil] byte value
      # @return [Boolean] true if uppercase letter
      private_class_method def self.uppercase?(byte)
        byte && byte >= 65 && byte <= 90 # 'A' = 65, 'Z' = 90
      end

      # Checks if a byte is an ASCII digit (0-9).
      #
      # @param byte [Integer, nil] byte value
      # @return [Boolean] true if digit
      private_class_method def self.digit?(byte)
        byte && byte >= 48 && byte <= 57 # '0' = 48, '9' = 57
      end

      # Parses lowercase letters starting at position.
      #
      # @param string [String] input string
      # @param pos [Integer] starting position
      # @return [Array(Integer, Integer)] decoded value and characters consumed
      # @raise [Sashite::Cell::Errors::Argument] if parsing fails
      private_class_method def self.parse_lowercase(string, pos)
        byte = string.getbyte(pos)
        unless lowercase?(byte)
          raise Errors::Argument, Errors::Argument::Messages::UNEXPECTED_CHARACTER
        end

        chars = [byte]
        pos += 1

        while pos < string.length && lowercase?(string.getbyte(pos))
          chars << string.getbyte(pos)
          pos += 1
        end

        value = decode_lowercase(chars)
        if value > Constants::MAX_INDEX_VALUE
          raise Errors::Argument, Errors::Argument::Messages::INDEX_OUT_OF_RANGE
        end

        [value, chars.size]
      end

      # Parses a positive integer starting at position.
      #
      # @param string [String] input string
      # @param pos [Integer] starting position
      # @return [Array(Integer, Integer)] decoded value and characters consumed
      # @raise [Sashite::Cell::Errors::Argument] if parsing fails
      private_class_method def self.parse_integer(string, pos)
        byte = string.getbyte(pos)
        unless digit?(byte)
          raise Errors::Argument, Errors::Argument::Messages::UNEXPECTED_CHARACTER
        end

        # Check for leading zero
        if byte == 48 # '0'
          raise Errors::Argument, Errors::Argument::Messages::LEADING_ZERO
        end

        chars = [byte]
        pos += 1

        while pos < string.length && digit?(string.getbyte(pos))
          chars << string.getbyte(pos)
          pos += 1
        end

        value = decode_integer(chars)
        if value < 0 || value > Constants::MAX_INDEX_VALUE
          raise Errors::Argument, Errors::Argument::Messages::INDEX_OUT_OF_RANGE
        end

        [value, chars.size]
      end

      # Parses uppercase letters starting at position.
      #
      # @param string [String] input string
      # @param pos [Integer] starting position
      # @return [Array(Integer, Integer)] decoded value and characters consumed
      # @raise [Sashite::Cell::Errors::Argument] if parsing fails
      private_class_method def self.parse_uppercase(string, pos)
        byte = string.getbyte(pos)
        unless uppercase?(byte)
          raise Errors::Argument, Errors::Argument::Messages::UNEXPECTED_CHARACTER
        end

        chars = [byte]
        pos += 1

        while pos < string.length && uppercase?(string.getbyte(pos))
          chars << string.getbyte(pos)
          pos += 1
        end

        value = decode_uppercase(chars)
        if value > Constants::MAX_INDEX_VALUE
          raise Errors::Argument, Errors::Argument::Messages::INDEX_OUT_OF_RANGE
        end

        [value, chars.size]
      end

      # Decodes lowercase letter bytes to an index.
      #
      # @param bytes [Array<Integer>] byte values
      # @return [Integer] decoded index (0-255)
      private_class_method def self.decode_lowercase(bytes)
        if bytes.size == 1
          bytes[0] - 97 # 'a' = 97
        else
          first = bytes[0] - 97
          second = bytes[1] - 97
          26 + (first * 26) + second
        end
      end

      # Decodes uppercase letter bytes to an index.
      #
      # @param bytes [Array<Integer>] byte values
      # @return [Integer] decoded index (0-255)
      private_class_method def self.decode_uppercase(bytes)
        if bytes.size == 1
          bytes[0] - 65 # 'A' = 65
        else
          first = bytes[0] - 65
          second = bytes[1] - 65
          26 + (first * 26) + second
        end
      end

      # Decodes digit bytes to an index (1-based to 0-based).
      #
      # @param bytes [Array<Integer>] byte values
      # @return [Integer] decoded index (0-255)
      private_class_method def self.decode_integer(bytes)
        value = 0
        bytes.each do |byte|
          value = (value * 10) + (byte - 48) # '0' = 48
        end
        value - 1 # Convert from 1-based to 0-based
      end
    end
  end
end

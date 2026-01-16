# frozen_string_literal: true

module Sashite
  module Cell
    # Formats index arrays into CELL coordinate strings.
    #
    # This module handles the conversion from numeric indices to their
    # CELL string representation following the cyclic pattern:
    # - Dimension 1, 4, 7...: lowercase letters (a-z, aa-iv)
    # - Dimension 2, 5, 8...: positive integers (1-256)
    # - Dimension 3, 6, 9...: uppercase letters (A-Z, AA-IV)
    #
    # @example
    #   Formatter.indices_to_string([4, 3])    # => "e4"
    #   Formatter.indices_to_string([0, 0, 0]) # => "a1A"
    #
    # @api private
    module Formatter
      # Formats an indices array to a CELL string.
      #
      # @param indices [Array<Integer>] 0-indexed coordinate values
      # @return [String] CELL coordinate string
      #
      # @example
      #   Formatter.indices_to_string([4, 3])       # => "e4"
      #   Formatter.indices_to_string([255, 255, 255]) # => "iv256IV"
      def self.indices_to_string(indices)
        result = +""

        indices.each_with_index do |index, i|
          dimension_type = i % 3

          result << case dimension_type
                    when 0 then encode_to_lower(index)
                    when 1 then encode_to_number(index)
                    when 2 then encode_to_upper(index)
                    end
        end

        result.freeze
      end

      # Encodes an index (0-255) as lowercase letters (a-z, aa-iv).
      #
      # @param index [Integer] 0-indexed value (0-255)
      # @return [String] lowercase letter sequence
      #
      # @example
      #   encode_to_lower(0)   # => "a"
      #   encode_to_lower(25)  # => "z"
      #   encode_to_lower(26)  # => "aa"
      #   encode_to_lower(255) # => "iv"
      private_class_method def self.encode_to_lower(index)
        encode_to_letters(index, base: "a")
      end

      # Encodes an index (0-255) as uppercase letters (A-Z, AA-IV).
      #
      # @param index [Integer] 0-indexed value (0-255)
      # @return [String] uppercase letter sequence
      #
      # @example
      #   encode_to_upper(0)   # => "A"
      #   encode_to_upper(25)  # => "Z"
      #   encode_to_upper(26)  # => "AA"
      #   encode_to_upper(255) # => "IV"
      private_class_method def self.encode_to_upper(index)
        encode_to_letters(index, base: "A")
      end

      # Encodes an index to a letter sequence.
      #
      # @param index [Integer] 0-indexed value (0-255)
      # @param base [String] base character ("a" or "A")
      # @return [String] letter sequence
      private_class_method def self.encode_to_letters(index, base:)
        base_ord = base.ord

        if index < 26
          (base_ord + index).chr
        else
          adjusted = index - 26
          first = adjusted / 26
          second = adjusted % 26
          (base_ord + first).chr + (base_ord + second).chr
        end
      end

      # Encodes an index (0-255) as a 1-based positive integer string.
      #
      # @param index [Integer] 0-indexed value (0-255)
      # @return [String] number string (1-indexed)
      #
      # @example
      #   encode_to_number(0)   # => "1"
      #   encode_to_number(255) # => "256"
      private_class_method def self.encode_to_number(index)
        (index + 1).to_s
      end
    end
  end
end

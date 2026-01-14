# frozen_string_literal: true

module Sashite
  module Cell
    # Formats index arrays into CELL coordinate strings.
    #
    # @example
    #   Dumper.indices_to_string([4, 3])    # => "e4"
    #   Dumper.indices_to_string([0, 0, 0]) # => "a1A"
    #
    # @api private
    module Dumper
      # Formats indices array to CELL string.
      #
      # @param indices [Array<Integer>] 0-indexed coordinate values
      # @return [String] CELL coordinate string
      def self.indices_to_string(indices)
        indices.each_with_index.map do |index, i|
          dimension = i + 1
          case dimension % 3
          when 1 then encode_letters(index, uppercase: false)
          when 2 then encode_integer(index)
          when 0 then encode_letters(index, uppercase: true)
          end
        end.join
      end

      # Encodes index to letter sequence (0=a, 25=z, 26=aa, ...).
      #
      # @param index [Integer] 0-indexed value
      # @param uppercase [Boolean] whether to use uppercase letters
      # @return [String] letter sequence
      private_class_method def self.encode_letters(index, uppercase:)
        base_char = uppercase ? "A" : "a"

        if index < 26
          (base_char.ord + index).chr
        else
          adjusted = index - 26
          first = adjusted / 26
          second = adjusted % 26
          (base_char.ord + first).chr + (base_char.ord + second).chr
        end
      end

      # Encodes index to number string (0=1, 1=2, ...).
      #
      # @param index [Integer] 0-indexed value
      # @return [String] number string (1-indexed)
      private_class_method def self.encode_integer(index)
        (index + 1).to_s
      end
    end
  end
end

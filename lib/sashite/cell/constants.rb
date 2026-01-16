# frozen_string_literal: true

module Sashite
  module Cell
    module Constants
      # Maximum number of dimensions supported by a CELL coordinate.
      # Sufficient for 1D, 2D, and 3D game boards.
      MAX_DIMENSIONS = 3

      # Maximum value for a single coordinate index.
      # Fits in an 8-bit unsigned integer (0-255).
      MAX_INDEX_VALUE = 255

      # Maximum length of a CELL string representation.
      # Corresponds to "iv256IV" (worst case for all dimensions at 255).
      MAX_STRING_LENGTH = 7
    end
  end
end

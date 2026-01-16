# frozen_string_literal: true

module Sashite
  module Cell
    module Errors
      class Argument < ::ArgumentError
        # Error messages for validation failures.
        # Kept as constants to ensure consistency across the library.
        module Messages
          EMPTY_INPUT          = "empty input"
          INPUT_TOO_LONG       = "input exceeds 7 characters"
          INVALID_START        = "must start with lowercase letter"
          UNEXPECTED_CHARACTER = "unexpected character"
          LEADING_ZERO         = "leading zero"
          TOO_MANY_DIMENSIONS  = "exceeds 3 dimensions"
          INDEX_OUT_OF_RANGE   = "index exceeds 255"
          NO_INDICES           = "at least one index required"
        end
      end
    end
  end
end

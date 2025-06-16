# frozen_string_literal: true

module Sashite
  module Cell
    class Location
      # Character representing hand/reserve location in CELL notation
      #
      # This character is used to identify pieces held off-board in a player's
      # hand or reserve, as opposed to pieces positioned on the game board.
      #
      # @return [String] the hand/reserve character
      # @see https://sashite.dev/documents/cell/1.0.0/ CELL Specification v1.0.0
      HAND_CHAR = "*"
    end
  end
end

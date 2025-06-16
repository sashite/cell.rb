# frozen_string_literal: true

# Sashité namespace for board game notation libraries
module Sashite
  # Coordinate Expression Location Label (CELL) implementation for Ruby
  #
  # CELL defines a consistent and rule-agnostic format for representing locations
  # in abstract strategy board games. CELL provides a standardized way to identify
  # positions on game boards and pieces held in hand/reserve, establishing a
  # common foundation for location reference across the Sashité notation ecosystem.
  #
  # @see https://sashite.dev/documents/cell/1.0.0/ CELL Specification v1.0.0
end

require_relative "sashite/cell"

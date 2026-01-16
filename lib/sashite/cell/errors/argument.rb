# frozen_string_literal: true

require_relative "argument/messages"

module Sashite
  module Cell
    module Errors
      # Custom error class for CELL parsing and validation failures.
      #
      # Inherits from ArgumentError to maintain semantic meaning
      # while allowing specific rescue of CELL-related errors.
      #
      # @example Rescuing specific CELL errors
      #   begin
      #     Sashite::Cell.parse("invalid")
      #   rescue Sashite::Cell::Errors::Argument => e
      #     puts "CELL error: #{e.message}"
      #   end
      #
      # @example Rescuing as ArgumentError
      #   begin
      #     Sashite::Cell.parse("invalid")
      #   rescue ArgumentError => e
      #     puts "Argument error: #{e.message}"
      #   end
      class Argument < ::ArgumentError
      end
    end
  end
end

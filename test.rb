#!/usr/bin/env ruby
# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Cell (Coordinate Encoding for Layered Locations)
#
# Tests the CELL implementation for Ruby, covering validation,
# parsing, formatting, and coordinate conversion according to
# the CELL Specification v1.0.0.
#
# This implementation is constrained to:
# - Maximum 3 dimensions
# - Maximum index value 255
# - Maximum string length 7 characters
#
# @see https://sashite.dev/specs/cell/1.0.0/ CELL Specification v1.0.0

require_relative "lib/sashite/cell"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Cell (Coordinate Encoding for Layered Locations)"
puts "Validating compliance with CELL Specification v1.0.0"
puts "Implementation constraints: max 3 dimensions, max index 255, max length 7"
puts "Specification: https://sashite.dev/specs/cell/1.0.0/"
puts

# ============================================================================
# CONSTANTS TESTS
# ============================================================================

run_test("Constants are defined correctly") do
  raise "MAX_DIMENSIONS should be 3" unless Sashite::Cell::Coordinate::MAX_DIMENSIONS == 3
  raise "MAX_INDEX_VALUE should be 255" unless Sashite::Cell::Coordinate::MAX_INDEX_VALUE == 255
  raise "MAX_STRING_LENGTH should be 7" unless Sashite::Cell::Coordinate::MAX_STRING_LENGTH == 7
end

# ============================================================================
# SPECIFICATION COMPLIANCE TESTS
# ============================================================================

run_test("Specification valid examples (within constraints) are accepted") do
  # Valid examples from CELL Specification v1.0.0 that fit within constraints
  spec_valid_examples = [
    # Basic Examples (1D, 2D, 3D only)
    "a",        # 1D coordinate
    "a1",       # 2D coordinate
    "a1A",      # 3D coordinate

    # Game-Specific Examples
    "e4", "h8", "a1",     # Chess
    "e1", "i9",           # Shogi
    "a1A", "b2B", "c3C"   # 3D Tic-Tac-Toe
  ]

  spec_valid_examples.each do |coord|
    raise "Specification example '#{coord}' should be valid but was rejected" unless Sashite::Cell.valid?(coord)
  end
end

run_test("Specification invalid examples are rejected") do
  # Invalid examples directly from CELL Specification v1.0.0
  spec_invalid_examples = [
    "",       # Empty string
    "1",      # Starts with numeric (must start with lowercase)
    "A",      # Starts with uppercase (must start with lowercase)
    "a0",     # Contains zero (only positive integers allowed)
    "a01",    # Leading zero
    "a1a",    # Lowercase after numeric without uppercase
    "1a",     # Numeric before lowercase (wrong order)
    "aA",     # Uppercase directly after lowercase (missing numeric)
    "a1A1"    # Numeric after uppercase without lowercase
  ]

  spec_invalid_examples.each do |coord|
    raise "Specification invalid example '#{coord}' should be rejected but was accepted" if Sashite::Cell.valid?(coord)
  end
end

run_test("Coordinates exceeding 3 dimensions are rejected") do
  # These are valid per spec but exceed implementation constraints
  over_dimension_examples = [
    "a1Aa",     # 4D coordinate
    "a1Aa1",    # 5D coordinate
    "a1Aa1A",   # 6D coordinate
    "h8Hh8",    # 5D coordinate
    "h8Hh8H"    # 6D coordinate
  ]

  over_dimension_examples.each do |coord|
    raise "Over-dimension coordinate '#{coord}' should be rejected" if Sashite::Cell.valid?(coord)
  end
end

run_test("Coordinates exceeding max string length are rejected") do
  long_examples = [
    "abcdefgh",   # 8 characters (1D but too long)
    "abcd1234"    # 8 characters (2D but too long)
  ]

  long_examples.each do |coord|
    raise "Long coordinate '#{coord}' should be rejected" if Sashite::Cell.valid?(coord)
  end
end

# ============================================================================
# VALIDATION TESTS
# ============================================================================

run_test("Valid coordinates are properly accepted") do
  valid_coordinates = [
    # Single dimension (1D)
    "a", "z", "aa", "iv",

    # Two dimensions (2D)
    "a1", "z26", "h8", "i9", "aa1",

    # Three dimensions (3D)
    "a1A", "z26Z", "c3C", "h8H"
  ]

  valid_coordinates.each do |coord|
    raise "#{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
  end
end

run_test("Invalid coordinates are properly rejected") do
  invalid_coordinates = [
    # Empty
    "",

    # Wrong starting character
    "1", "A", "1a", "Aa",

    # Contains zero
    "a0", "a0A",

    # Wrong cyclical order
    "a1a", "A1A", "aA", "a1A1",

    # Invalid characters
    "*", "a*", "a-1", "a1-A",

    # Whitespace issues
    " a1", "a1 ", "a 1", "a1 A"
  ]

  invalid_coordinates.each do |coord|
    raise "#{coord.inspect} should be invalid" if Sashite::Cell.valid?(coord)
  end
end

# ============================================================================
# PARSING TESTS
# ============================================================================

run_test("Parsing returns correct Coordinate objects") do
  test_cases = {
    "a"   => [0],
    "z"   => [25],
    "aa"  => [26],
    "a1"  => [0, 0],
    "e4"  => [4, 3],
    "h8"  => [7, 7],
    "i9"  => [8, 8],
    "a1A" => [0, 0, 0],
    "b2B" => [1, 1, 1],
    "c3C" => [2, 2, 2]
  }

  test_cases.each do |input, expected_indices|
    coord = Sashite::Cell.parse(input)

    raise "parse(#{input.inspect}) should return Coordinate" unless coord.is_a?(Sashite::Cell::Coordinate)
    raise "parse(#{input.inspect}).indices should be #{expected_indices}, got #{coord.indices}" unless coord.indices == expected_indices
    raise "parse(#{input.inspect}).dimensions should be #{expected_indices.size}, got #{coord.dimensions}" unless coord.dimensions == expected_indices.size
  end
end

run_test("Parsing invalid input raises ArgumentError") do
  invalid_inputs = ["", "a0", "1a", "aA", "a1a", "a1A1", "a1Aa"]

  invalid_inputs.each do |input|
    begin
      Sashite::Cell.parse(input)
      raise "parse(#{input.inspect}) should raise ArgumentError"
    rescue ArgumentError
      # Expected
    end
  end
end

run_test("Parsing error messages are descriptive") do
  error_cases = {
    ""      => "empty input",
    "abcdefgh" => "input exceeds 7 characters",
    "1a"    => "must start with lowercase letter",
    "Aa"    => "must start with lowercase letter",
    "aA"    => "unexpected character",
    "a0"    => "leading zero",
    "a1Aa"  => "exceeds 3 dimensions"
  }

  error_cases.each do |input, expected_message|
    begin
      Sashite::Cell.parse(input)
      raise "parse(#{input.inspect}) should raise ArgumentError"
    rescue ArgumentError => e
      raise "parse(#{input.inspect}) error should contain '#{expected_message}', got '#{e.message}'" unless e.message.include?(expected_message)
    end
  end
end

# ============================================================================
# FORMATTING TESTS
# ============================================================================

run_test("Formatting returns correct CELL strings") do
  test_cases = {
    [0]          => "a",
    [25]         => "z",
    [26]         => "aa",
    [0, 0]       => "a1",
    [4, 3]       => "e4",
    [7, 7]       => "h8",
    [8, 8]       => "i9",
    [0, 0, 0]    => "a1A",
    [1, 1, 1]    => "b2B",
    [2, 2, 2]    => "c3C",
    [255, 255, 255] => "iv256IV"
  }

  test_cases.each do |indices, expected_string|
    result = Sashite::Cell.format(*indices)
    raise "format(#{indices.inspect}) should be #{expected_string.inspect}, got #{result.inspect}" unless result == expected_string
  end
end

run_test("Formatting invalid indices raises ArgumentError") do
  invalid_cases = [
    [],           # Empty
    [256],        # Exceeds max value
    [0, 256],     # Second index exceeds max
    [0, 0, 256],  # Third index exceeds max
    [0, 0, 0, 0], # Too many dimensions
    [-1],         # Negative value
    [0, -1]       # Negative in second position
  ]

  invalid_cases.each do |indices|
    begin
      Sashite::Cell.format(*indices)
      raise "format(#{indices.inspect}) should raise ArgumentError"
    rescue ArgumentError
      # Expected
    end
  end
end

# ============================================================================
# COORDINATE CLASS TESTS
# ============================================================================

run_test("Coordinate initialization works correctly") do
  coord = Sashite::Cell::Coordinate.new(4, 3)

  raise "indices should be [4, 3]" unless coord.indices == [4, 3]
  raise "dimensions should be 2" unless coord.dimensions == 2
  raise "to_s should be 'e4'" unless coord.to_s == "e4"
end

run_test("Coordinate indices are frozen") do
  coord = Sashite::Cell::Coordinate.new(4, 3)

  raise "indices should be frozen" unless coord.indices.frozen?

  begin
    coord.indices << 5
    raise "Should not be able to modify frozen indices"
  rescue FrozenError
    # Expected
  end
end

run_test("Coordinate equality works correctly") do
  coord1 = Sashite::Cell::Coordinate.new(4, 3)
  coord2 = Sashite::Cell::Coordinate.new(4, 3)
  coord3 = Sashite::Cell::Coordinate.new(4, 4)

  raise "Equal coordinates should be ==" unless coord1 == coord2
  raise "Equal coordinates should be eql?" unless coord1.eql?(coord2)
  raise "Different coordinates should not be ==" if coord1 == coord3
  raise "Equal coordinates should have same hash" unless coord1.hash == coord2.hash
end

run_test("Coordinate can be used as Hash key") do
  hash = {}
  coord1 = Sashite::Cell::Coordinate.new(4, 3)
  coord2 = Sashite::Cell::Coordinate.new(4, 3)

  hash[coord1] = "value"

  raise "Should find value with equivalent coordinate" unless hash[coord2] == "value"
end

run_test("Coordinate inspect returns readable format") do
  coord = Sashite::Cell::Coordinate.new(4, 3)
  inspect_result = coord.inspect

  raise "inspect should contain class name" unless inspect_result.include?("Coordinate")
  raise "inspect should contain string representation" unless inspect_result.include?("e4")
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

run_test("Parse and format round-trip is consistent") do
  test_coords = ["a", "z", "aa", "a1", "e4", "h8", "i9", "a1A", "b2B", "c3C"]

  test_coords.each do |original|
    coord = Sashite::Cell.parse(original)
    formatted = coord.to_s
    raise "Round-trip failed for #{original.inspect}: got #{formatted.inspect}" unless formatted == original
  end
end

run_test("Format and parse round-trip is consistent") do
  test_indices = [
    [0], [25], [26],
    [0, 0], [4, 3], [7, 7],
    [0, 0, 0], [1, 1, 1], [255, 255, 255]
  ]

  test_indices.each do |original|
    formatted = Sashite::Cell.format(*original)
    coord = Sashite::Cell.parse(formatted)
    raise "Round-trip failed for #{original.inspect}: got #{coord.indices.inspect}" unless coord.indices == original
  end
end

# ============================================================================
# EXTENDED ALPHABET TESTS
# ============================================================================

run_test("Single letter encoding (a=0, z=25)") do
  single_letter_cases = {
    0 => "a", 1 => "b", 25 => "z"
  }

  single_letter_cases.each do |index, expected|
    actual = Sashite::Cell.format(index)
    raise "Index #{index} should produce #{expected.inspect}, got #{actual.inspect}" unless actual == expected

    parsed = Sashite::Cell.parse(expected)
    raise "Letter #{expected.inspect} should produce [#{index}], got #{parsed.indices.inspect}" unless parsed.indices == [index]
  end
end

run_test("Double letter encoding (aa=26, ab=27, az=51, ba=52)") do
  double_letter_cases = {
    26 => "aa", 27 => "ab", 51 => "az", 52 => "ba"
  }

  double_letter_cases.each do |index, expected|
    actual = Sashite::Cell.format(index)
    raise "Index #{index} should produce #{expected.inspect}, got #{actual.inspect}" unless actual == expected

    parsed = Sashite::Cell.parse(expected)
    raise "Letters #{expected.inspect} should produce [#{index}], got #{parsed.indices.inspect}" unless parsed.indices == [index]
  end
end

run_test("Numeric encoding (1-indexed: 0→1, 1→2, 255→256)") do
  numeric_cases = {
    [0, 0] => "a1",
    [0, 1] => "a2",
    [0, 255] => "a256"
  }

  numeric_cases.each do |indices, expected|
    actual = Sashite::Cell.format(*indices)
    raise "Indices #{indices.inspect} should produce #{expected.inspect}, got #{actual.inspect}" unless actual == expected

    parsed = Sashite::Cell.parse(expected)
    raise "Coordinate #{expected.inspect} should produce #{indices.inspect}, got #{parsed.indices.inspect}" unless parsed.indices == indices
  end
end

run_test("Uppercase letter encoding (A=0, Z=25, AA=26)") do
  uppercase_cases = {
    [0, 0, 0] => "a1A",
    [0, 0, 25] => "a1Z",
    [0, 0, 26] => "a1AA"
  }

  uppercase_cases.each do |indices, expected|
    actual = Sashite::Cell.format(*indices)
    raise "Indices #{indices.inspect} should produce #{expected.inspect}, got #{actual.inspect}" unless actual == expected

    parsed = Sashite::Cell.parse(expected)
    raise "Coordinate #{expected.inspect} should produce #{indices.inspect}, got #{parsed.indices.inspect}" unless parsed.indices == indices
  end
end

# ============================================================================
# BOUNDARY TESTS
# ============================================================================

run_test("Maximum index value (255) is accepted") do
  max_cases = [
    [255],
    [255, 255],
    [255, 255, 255]
  ]

  max_cases.each do |indices|
    coord = Sashite::Cell::Coordinate.new(*indices)
    raise "Max indices #{indices.inspect} should be accepted" unless coord.indices == indices

    formatted = coord.to_s
    parsed = Sashite::Cell.parse(formatted)
    raise "Round-trip failed for max indices #{indices.inspect}" unless parsed.indices == indices
  end
end

run_test("Index value 256 is rejected") do
  begin
    Sashite::Cell::Coordinate.new(256)
    raise "Index 256 should be rejected"
  rescue ArgumentError => e
    raise "Error should mention 255" unless e.message.include?("255")
  end
end

run_test("Maximum string length (7) edge cases") do
  # "iv256IV" = 7 characters (max valid)
  max_string = "iv256IV"
  raise "Max string #{max_string.inspect} should be valid" unless Sashite::Cell.valid?(max_string)

  # Verify it parses to max values
  coord = Sashite::Cell.parse(max_string)
  raise "Max string should parse to [255, 255, 255]" unless coord.indices == [255, 255, 255]
end

run_test("String exceeding 7 characters is rejected") do
  long_string = "iv256IVx"  # 8 characters

  raise "String >7 chars should be rejected" if Sashite::Cell.valid?(long_string)

  begin
    Sashite::Cell.parse(long_string)
    raise "Should raise ArgumentError for long string"
  rescue ArgumentError => e
    raise "Error should mention 7 characters" unless e.message.include?("7")
  end
end

# ============================================================================
# GAME-SPECIFIC TESTS
# ============================================================================

run_test("Chess board coordinates (8x8)") do
  chess_files = %w[a b c d e f g h]
  chess_ranks = %w[1 2 3 4 5 6 7 8]

  chess_files.each_with_index do |file, file_idx|
    chess_ranks.each_with_index do |rank, rank_idx|
      coord_str = "#{file}#{rank}"

      raise "Chess coordinate #{coord_str} should be valid" unless Sashite::Cell.valid?(coord_str)

      coord = Sashite::Cell.parse(coord_str)
      raise "#{coord_str} should have 2 dimensions" unless coord.dimensions == 2
      raise "#{coord_str} file index should be #{file_idx}" unless coord.indices[0] == file_idx
      raise "#{coord_str} rank index should be #{rank_idx}" unless coord.indices[1] == rank_idx
    end
  end
end

run_test("Shogi board coordinates (9x9)") do
  # Shogi uses files a-i and ranks 1-9
  (0..8).each do |file|
    (0..8).each do |rank|
      coord = Sashite::Cell::Coordinate.new(file, rank)
      formatted = coord.to_s

      raise "Shogi coordinate [#{file}, #{rank}] should be valid" unless Sashite::Cell.valid?(formatted)

      parsed = Sashite::Cell.parse(formatted)
      raise "Round-trip failed for shogi [#{file}, #{rank}]" unless parsed.indices == [file, rank]
    end
  end
end

run_test("3D Tic-Tac-Toe (3x3x3)") do
  # All valid positions in a 3x3x3 cube
  (0..2).each do |x|
    (0..2).each do |y|
      (0..2).each do |z|
        coord = Sashite::Cell::Coordinate.new(x, y, z)
        formatted = coord.to_s

        raise "3D coordinate [#{x}, #{y}, #{z}] should be valid" unless Sashite::Cell.valid?(formatted)
        raise "3D coordinate should have 3 dimensions" unless coord.dimensions == 3

        parsed = Sashite::Cell.parse(formatted)
        raise "Round-trip failed for 3D [#{x}, #{y}, #{z}]" unless parsed.indices == [x, y, z]
      end
    end
  end

  # Test diagonal win from spec examples
  diagonal = [[0, 0, 0], [1, 1, 1], [2, 2, 2]]
  diagonal_strings = %w[a1A b2B c3C]

  diagonal.each_with_index do |indices, i|
    coord = Sashite::Cell.parse(diagonal_strings[i])
    raise "Diagonal #{diagonal_strings[i]} should be #{indices}" unless coord.indices == indices
  end
end

# ============================================================================
# API CONSISTENCY TESTS
# ============================================================================

run_test("API methods are stateless and consistent") do
  test_coord = "e4"

  5.times do
    raise "valid? should be consistent" unless Sashite::Cell.valid?(test_coord) == true

    coord = Sashite::Cell.parse(test_coord)
    raise "parse should be consistent" unless coord.indices == [4, 3]
    raise "to_s should be consistent" unless coord.to_s == "e4"
  end

  5.times do
    raise "format should be consistent" unless Sashite::Cell.format(4, 3) == "e4"
  end
end

run_test("validate returns nil for valid input") do
  result = Sashite::Cell.validate("e4")
  raise "validate should return nil for valid input, got #{result.inspect}" unless result.nil?
end

run_test("validate raises for invalid input") do
  begin
    Sashite::Cell.validate("a0")
    raise "validate should raise for invalid input"
  rescue ArgumentError
    # Expected
  end
end

puts
puts "All CELL v1.0.0 tests passed!"
puts

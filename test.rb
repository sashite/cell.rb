# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"

SimpleCov.start

# Tests for Sashite::Cell (Cell Encoding Location Label)
#
# Tests the CELL implementation for Ruby, covering validation,
# parsing, dimensional analysis, and coordinate conversion
# according to the CELL specification v1.0.0.
#
# This test assumes the existence of:
# - lib/sashite/cell.rb

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
puts "Tests for Sashite::Cell (Cell Encoding Location Label)"
puts

# Test module-level validation method with corrected expectations
run_test("Module validation accepts valid CELL coordinates") do
  valid_coordinates = %w[a a1 a1A a1Aa a1Aa1 a1Aa1A b2B c3Cc3C h8 e4 z26Z aa1AA bb2BB zz26ZZ aaa1AAA foobar abc xyz]

  valid_coordinates.each do |coord|
    raise "#{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
  end
end

run_test("Module validation rejects invalid CELL coordinates") do
  # Updated based on CELL specification - these should be invalid
  invalid_coordinates = ["", "0", "a0", "A0", "1a", "Aa", "aA", "a1a", "A1A", "aB1", " a1", "a1 ",
                        "a-1", "a1-A", "*", "a*", "1*", "A*", "abc 123", "123abc", "AbC",
                        "1", "A", "1A", "A1", "a1b", "a1B1"]

  invalid_coordinates.each do |coord|
    raise "#{coord.inspect} should be invalid" if Sashite::Cell.valid?(coord)
  end
end

run_test("Module validation handles non-string input") do
  non_strings = [nil, 123, :a1, [], {}]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Cell.valid?(input)
  end
end

# Test dimensional analysis - corrected to match spec
run_test("Dimensions detection for various coordinates") do
  dimension_cases = {
    "a" => 1,
    "a1" => 2,
    "a1A" => 3,
    "a1Aa" => 4,
    "a1Aa1" => 5,
    "a1Aa1A" => 6,
    "h8Hh8H" => 6,
    "foobar" => 1,
    "abc" => 1,
    "xyz" => 1
  }

  dimension_cases.each do |coord, expected_dimensions|
    actual_dimensions = Sashite::Cell.dimensions(coord)
    raise "#{coord.inspect} should have #{expected_dimensions} dimensions, got #{actual_dimensions}" unless actual_dimensions == expected_dimensions
  end
end

run_test("Dimensions returns 0 for invalid input") do
  invalid_inputs = [nil, "", 123, [], "1a", "A1a", "a0"]

  invalid_inputs.each do |input|
    dimensions = Sashite::Cell.dimensions(input)
    raise "#{input.inspect} should return 0 dimensions, got #{dimensions}" unless dimensions == 0
  end
end

# Test parsing functionality - updated for strict CELL compliance
run_test("Parse method splits coordinates correctly") do
  parse_cases = {
    "a" => ["a"],
    "a1" => ["a", "1"],
    "a1A" => ["a", "1", "A"],
    "a1Aa" => ["a", "1", "A", "a"],
    "a1Aa1" => ["a", "1", "A", "a", "1"],
    "h8Hh8" => ["h", "8", "H", "h", "8"],
    "bb25BB" => ["bb", "25", "BB"],
    "foobar" => ["foobar"],
    "abc" => ["abc"],
    "xyz" => ["xyz"]
  }

  parse_cases.each do |coord, expected_components|
    actual_components = Sashite::Cell.parse(coord)
    raise "#{coord.inspect} should parse to #{expected_components.inspect}, got #{actual_components.inspect}" unless actual_components == expected_components
  end
end

run_test("Parse handles empty and invalid input") do
  Sashite::Cell.parse("").tap do |result|
    raise "Empty string should return empty array, got #{result.inspect}" unless result == []
  end

  Sashite::Cell.parse(nil).tap do |result|
    raise "nil should return empty array, got #{result.inspect}" unless result == []
  end

  # Test invalid coordinates return empty arrays
  ["1a", "A1a", "a0"].each do |invalid|
    result = Sashite::Cell.parse(invalid)
    raise "Invalid coordinate #{invalid.inspect} should return empty array, got #{result.inspect}" unless result == []
  end
end

# Test coordinate to indices conversion
run_test("Coordinate to indices conversion") do
  conversion_cases = {
    "a1" => [0, 0],
    "b2" => [1, 1],
    "e4" => [4, 3],
    "h8" => [7, 7],
    "a1A" => [0, 0, 0],
    "b2B" => [1, 1, 1],
    "z26Z" => [25, 25, 25],
    "aa1AA" => [26, 0, 26],
    "ab2AB" => [27, 1, 27]
  }

  conversion_cases.each do |coord, expected_indices|
    actual_indices = Sashite::Cell.to_indices(coord)
    raise "#{coord.inspect} should convert to #{expected_indices.inspect}, got #{actual_indices.inspect}" unless actual_indices == expected_indices
  end
end

run_test("Invalid coordinates return empty array for to_indices") do
  invalid_coords = ["", "a0", "1a", "*"]

  invalid_coords.each do |coord|
    result = Sashite::Cell.to_indices(coord)
    raise "#{coord.inspect} should return empty array, got #{result.inspect}" unless result == []
  end
end

# Test indices to coordinate conversion
run_test("Indices to coordinate conversion") do
  conversion_cases = [
    [[0, 0], "a1"],
    [[1, 1], "b2"],
    [[4, 3], "e4"],
    [[7, 7], "h8"],
    [[0, 0, 0], "a1A"],
    [[1, 1, 1], "b2B"],
    [[25, 25, 25], "z26Z"],
    [[26, 0, 26], "aa1AA"],
    [[27, 1, 27], "ab2AB"],
    [[0], "a"],
    [[25], "z"],
    [[26], "aa"],
    [[701], "zz"]
  ]

  conversion_cases.each do |indices, expected_coord|
    actual_coord = Sashite::Cell.from_indices(*indices)
    raise "#{indices.inspect} should convert to #{expected_coord.inspect}, got #{actual_coord.inspect}" unless actual_coord == expected_coord
  end
end

# Test round-trip conversion
run_test("Round-trip coordinate conversion") do
  test_coordinates = %w[a1 e4 h8 a1A b2B z26Z aa1AA bb2BB zz26ZZ]

  test_coordinates.each do |coord|
    indices = Sashite::Cell.to_indices(coord)
    converted_back = Sashite::Cell.from_indices(*indices)
    raise "Round-trip failed for #{coord.inspect}: got #{converted_back.inspect}" unless converted_back == coord
  end
end

run_test("Round-trip indices conversion") do
  test_indices = [[0, 0], [4, 3], [7, 7], [0, 0, 0], [1, 1, 1], [25, 25, 25], [26, 0, 26], [27, 1, 27]]

  test_indices.each do |indices|
    coord = Sashite::Cell.from_indices(*indices)
    converted_back = Sashite::Cell.to_indices(coord)
    raise "Round-trip failed for #{indices.inspect}: got #{converted_back.inspect}" unless converted_back == indices
  end
end

# Test regex access - updated to match the correct CELL specification regex
run_test("Regex validates coordinates correctly") do
  valid_coords = %w[a a1 a1A h8Hh8H aa1AA bb2BB foobar abc xyz]
  invalid_coords = ["", "a0", "1a", "*", " a1", "1", "A", "a1a"]

  regex = Sashite::Cell.regex

  valid_coords.each do |coord|
    raise "#{coord.inspect} should match regex" unless coord.match?(regex)
  end

  invalid_coords.each do |coord|
    raise "#{coord.inspect} should not match regex" if coord.match?(regex)
  end
end

# Test character set cycling behavior
run_test("Character set cycling follows specification") do
  # We'll test this by checking that coordinates follow the pattern
  test_coords = %w[a a1 a1A a1Aa a1Aa1 a1Aa1A a1Aa1Aa]

  test_coords.each_with_index do |coord, index|
    expected_dimensions = index + 1
    actual_dimensions = Sashite::Cell.dimensions(coord)
    raise "#{coord.inspect} should have #{expected_dimensions} dimensions" unless actual_dimensions == expected_dimensions

    raise "#{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
  end
end

# Test letter sequence encoding (extended alphabet)
run_test("Extended alphabet encoding") do
  # Test single letters
  single_letter_cases = {
    0 => "a", 1 => "b", 25 => "z"
  }

  single_letter_cases.each do |index, expected_letter|
    actual_coord = Sashite::Cell.from_indices(index)
    raise "Index #{index} should produce #{expected_letter.inspect}, got #{actual_coord.inspect}" unless actual_coord == expected_letter

    actual_index = Sashite::Cell.to_indices(expected_letter)
    raise "Letter #{expected_letter.inspect} should produce [#{index}], got #{actual_index.inspect}" unless actual_index == [index]
  end

  # Test double letters (aa = 26, ab = 27, etc.)
  double_letter_cases = {
    26 => "aa", 27 => "ab", 51 => "az", 52 => "ba", 701 => "zz"
  }

  double_letter_cases.each do |index, expected_letters|
    actual_coord = Sashite::Cell.from_indices(index)
    raise "Index #{index} should produce #{expected_letters.inspect}, got #{actual_coord.inspect}" unless actual_coord == expected_letters

    actual_index = Sashite::Cell.to_indices(expected_letters)
    raise "Letters #{expected_letters.inspect} should produce [#{index}], got #{actual_index.inspect}" unless actual_index == [index]
  end
end

# Test game-specific scenarios
run_test("Chess board coordinates (8x8)") do
  chess_files = %w[a b c d e f g h]
  chess_ranks = %w[1 2 3 4 5 6 7 8]

  chess_files.each do |file|
    chess_ranks.each do |rank|
      coord = "#{file}#{rank}"
      raise "Chess coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
      raise "Chess coordinate #{coord.inspect} should have 2 dimensions" unless Sashite::Cell.dimensions(coord) == 2
    end
  end

  # Test some specific chess positions
  Sashite::Cell.to_indices("e4").tap do |indices|
    raise "e4 should be [4, 3], got #{indices.inspect}" unless indices == [4, 3]
  end

  Sashite::Cell.from_indices(4, 3).tap do |coord|
    raise "[4, 3] should be e4, got #{coord.inspect}" unless coord == "e4"
  end
end

# Note: Removed Shogi test as "1a" format violates CELL specification
# CELL requires lowercase first, then numeric, then uppercase in cycles

run_test("3D Tic-Tac-Toe coordinates (3x3x3)") do
  # Test some 3D positions
  positions_3d = %w[a1A b2B c3C a3A c1C]

  positions_3d.each do |coord|
    raise "3D coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
    raise "3D coordinate #{coord.inspect} should have 3 dimensions" unless Sashite::Cell.dimensions(coord) == 3

    # Ensure indices are in valid range for 3x3x3
    indices = Sashite::Cell.to_indices(coord)
    indices.each_with_index do |index, dim|
      raise "Index #{index} in dimension #{dim} should be 0-2 for #{coord.inspect}" unless (0..2).include?(index)
    end
  end
end

# Test edge cases and boundary conditions
run_test("Large coordinate values") do
  # Test larger board sizes
  large_coords = ["z26Z", "aa27AA", "zz702ZZ"]

  large_coords.each do |coord|
    raise "Large coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)

    indices = Sashite::Cell.to_indices(coord)
    converted_back = Sashite::Cell.from_indices(*indices)
    raise "Round-trip failed for large coordinate #{coord.inspect}" unless converted_back == coord
  end
end

run_test("High-dimensional coordinates") do
  # Test coordinates with many dimensions
  high_dim_coords = ["a1Aa1Aa1A", "b2Bb2Bb2B"]

  high_dim_coords.each do |coord|
    raise "High-dimensional coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)

    expected_dimensions = coord.scan(/[a-z]+|[1-9]\d*|[A-Z]+/).length
    actual_dimensions = Sashite::Cell.dimensions(coord)
    raise "#{coord.inspect} should have #{expected_dimensions} dimensions, got #{actual_dimensions}" unless actual_dimensions == expected_dimensions
  end
end

run_test("Numeric boundary conditions") do
  # Test numeric components
  numeric_coords = ["a1", "a10", "a100", "a999"]

  numeric_coords.each do |coord|
    raise "Numeric coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)

    # Extract the numeric part and verify it converts correctly
    components = Sashite::Cell.parse(coord)
    numeric_component = components[1]
    expected_index = numeric_component.to_i - 1

    indices = Sashite::Cell.to_indices(coord)
    actual_numeric_index = indices[1]
    raise "Numeric component #{numeric_component} should convert to #{expected_index}, got #{actual_numeric_index}" unless actual_numeric_index == expected_index
  end
end

# Test error handling and robustness
run_test("Graceful handling of malformed input") do
  # Updated to reflect strict CELL specification
  valid_single_dim = ["a", "z", "aa", "zz", "foobar", "abc", "xyz"]
  invalid_inputs = ["1", "A", "a1a", "1A1", "Aa1", "a0"]

  valid_single_dim.each do |input|
    raise "Valid single dimension #{input.inspect} should be valid" unless Sashite::Cell.valid?(input)
    components = Sashite::Cell.parse(input)
    raise "Valid input #{input.inspect} should parse to non-empty array" if components.empty?
  end

  invalid_inputs.each do |input|
    # These should be invalid according to CELL spec
    raise "Invalid input #{input.inspect} should be invalid" if Sashite::Cell.valid?(input)
    indices = Sashite::Cell.to_indices(input)
    raise "Invalid input #{input.inspect} should return empty indices array" unless indices.empty?
  end
end

run_test("Module methods are stateless") do
  # Test that repeated calls with same input give same results
  test_coord = "e4"

  5.times do
    raise "valid? should be consistent" unless Sashite::Cell.valid?(test_coord) == true
    raise "dimensions should be consistent" unless Sashite::Cell.dimensions(test_coord) == 2
    raise "parse should be consistent" unless Sashite::Cell.parse(test_coord) == ["e", "4"]
    raise "to_indices should be consistent" unless Sashite::Cell.to_indices(test_coord) == [4, 3]
  end

  5.times do
    raise "from_indices should be consistent" unless Sashite::Cell.from_indices(4, 3) == "e4"
  end
end

# Test CELL specification compliance specifically
run_test("CELL specification regex compliance") do
  # Test cases specifically for the CELL regex pattern
  valid_per_regex = [
    "a",           # Single dimension (lowercase only)
    "abc",         # Extended single dimension
    "foobar",      # Valid single dimension with multiple letters
    "a1",          # 2D (lowercase + numeric)
    "a10",         # 2D with multi-digit number
    "a1A",         # 3D (lowercase + numeric + uppercase)
    "a10A",        # 3D with multi-digit number
    "a1AA",        # Valid partial cycle (lowercase + numeric + uppercase)
    "a1Aa",        # 4D (complete cycle + lowercase)
    "a1Aa1",       # 5D (complete cycle + lowercase + numeric)
    "a1Aa1A",      # 6D (complete cycles)
    "a1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1Aa1A", # 100D (complete cycles)
    "abc123XYZ",   # Extended components
    "aa1AA",       # Extended alphabet
    "z999ZZZ"      # Large values
  ]

  invalid_per_regex = [
    "",            # Empty
    "1",           # Starts with numeric
    "A",           # Starts with uppercase
    "a0",          # Zero not allowed
    "a1a",         # Lowercase after numeric without uppercase
    "1a",          # Numeric before lowercase
    "A1",          # Uppercase before numeric
    "aA",          # Uppercase directly after lowercase
    "a1A1"         # Numeric after uppercase without lowercase
  ]

  regex = Sashite::Cell.regex

  valid_per_regex.each do |coord|
    raise "#{coord.inspect} should match CELL regex but doesn't" unless coord.match?(regex)
    raise "#{coord.inspect} should be valid per Cell.valid? but isn't" unless Sashite::Cell.valid?(coord)
  end

  invalid_per_regex.each do |coord|
    raise "#{coord.inspect} should NOT match CELL regex but does" if coord.match?(regex)
    raise "#{coord.inspect} should be invalid per Cell.valid? but isn't" if Sashite::Cell.valid?(coord)
  end
end

run_test("CELL specification edge cases") do
  # Test partial cycles at end (allowed by regex)
  partial_cycle_cases = [
    "a1",          # Ends after numeric (2D)
    "a1A",         # Ends after uppercase (3D)
    "a1Aa1",       # Ends after numeric in second cycle (5D)
    "a1Aa1A"       # Ends after uppercase in second cycle (6D)
  ]

  partial_cycle_cases.each do |coord|
    raise "#{coord.inspect} should be valid (partial cycle allowed)" unless Sashite::Cell.valid?(coord)
  end

  # Test that incomplete patterns are rejected
  incomplete_patterns = [
    "a1a",         # lowercase after numeric without uppercase
    "a1A1",        # numeric after uppercase without lowercase
    "a1Aa1A1"      # numeric after uppercase without lowercase
  ]

  incomplete_patterns.each do |coord|
    raise "#{coord.inspect} should be invalid (incomplete pattern)" if Sashite::Cell.valid?(coord)
  end
end

run_test("Zero handling compliance") do
  # CELL specification explicitly forbids zero in numeric components
  zero_cases = ["a0", "a0A", "a01A", "aa0AA", "a1Aa0"]

  zero_cases.each do |coord|
    raise "#{coord.inspect} should be invalid (contains zero)" if Sashite::Cell.valid?(coord)
  end

  # But numbers containing zero in non-leading positions are valid
  valid_with_zeros = ["a10", "a100", "a101", "a1010"]

  valid_with_zeros.each do |coord|
    raise "#{coord.inspect} should be valid (zero in non-leading position)" unless Sashite::Cell.valid?(coord)
  end
end

puts
puts "All CELL tests passed!"
puts

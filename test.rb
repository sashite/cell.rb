# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Cell (Coordinate Encoding for Layered Locations)
#
# Tests the CELL implementation for Ruby, covering validation,
# parsing, dimensional analysis, and coordinate conversion
# according to the CELL Specification v1.0.0.
#
# @see https://sashite.dev/specs/cell/1.0.0/ CELL Specification v1.0.0
#
# This test suite validates strict compliance with the official specification
# and includes all examples provided in the spec documentation.

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
puts "Specification: https://sashite.dev/specs/cell/1.0.0/"
puts

# ============================================================================
# SPECIFICATION COMPLIANCE TESTS
# ============================================================================

run_test("Official specification regex matches implementation") do
  # Exact regex from CELL Specification v1.0.0
  spec_regex = %r{^[a-z]+(?:[1-9][0-9]*[A-Z]+[a-z]+)*(?:[1-9][0-9]*[A-Z]*)?$}
  impl_regex = Sashite::Cell.regex

  raise "Implementation regex differs from specification" unless spec_regex.source == impl_regex.source
end

run_test("All specification valid examples are accepted") do
  # Valid examples directly from CELL Specification v1.0.0
  spec_valid_examples = [
    # Basic Examples
    "a",        # 1D coordinate
    "a1",       # 2D coordinate
    "a1A",      # 3D coordinate
    "a1Aa",     # 4D coordinate
    "a1Aa1",    # 5D coordinate
    "a1Aa1A",   # 6D coordinate

    # Extended Alphabet Examples
    "aa1AA",    # Using extended alphabet (position 26 in dimensions 1 and 3)
    "z26Z",     # Large values in each dimension type
    "abc123XYZ", # Multi-character components

    # Game-Specific Examples
    "e4", "h8", "a1",     # Chess
    "e1", "i9",           # Shogi (adapted to CELL format)
    "a1A", "b2B", "c3C"   # 3D Tic-Tac-Toe
  ]

  spec_valid_examples.each do |coord|
    raise "Specification example '#{coord}' should be valid but was rejected" unless Sashite::Cell.valid?(coord)
  end
end

run_test("All specification invalid examples are rejected") do
  # Invalid examples directly from CELL Specification v1.0.0
  spec_invalid_examples = [
    "",       # Empty string
    "1",      # Starts with numeric (must start with lowercase)
    "A",      # Starts with uppercase (must start with lowercase)
    "a0",     # Contains zero (only positive integers allowed)
    "a1a",    # Lowercase after numeric without uppercase
    "1a",     # Numeric before lowercase (wrong order)
    "aA",     # Uppercase directly after lowercase (missing numeric)
    "a1A1"    # Numeric after uppercase without lowercase
  ]

  spec_invalid_examples.each do |coord|
    raise "Specification invalid example '#{coord}' should be rejected but was accepted" if Sashite::Cell.valid?(coord)
  end
end

run_test("Cyclical dimension system follows specification") do
  # Test the n % 3 cyclical system from specification
  test_cases = [
    ["a", 1, :lowercase],       # Dimension 1 % 3 = 1
    ["a1", 2, :numeric],        # Dimension 2 % 3 = 2
    ["a1A", 3, :uppercase],     # Dimension 3 % 3 = 0
    ["a1Aa", 4, :lowercase],    # Dimension 4 % 3 = 1 (cycle restart)
    ["a1Aa1", 5, :numeric],     # Dimension 5 % 3 = 2
    ["a1Aa1A", 6, :uppercase]   # Dimension 6 % 3 = 0
  ]

  test_cases.each do |coord, expected_dims, last_type|
    actual_dims = Sashite::Cell.dimensions(coord)
    raise "#{coord} should have #{expected_dims} dimensions, got #{actual_dims}" unless actual_dims == expected_dims

    # Verify the coordinate is valid
    raise "#{coord} should be valid according to cyclical system" unless Sashite::Cell.valid?(coord)
  end
end

# ============================================================================
# VALIDATION TESTS
# ============================================================================

run_test("Valid coordinates are properly accepted") do
  valid_coordinates = [
    # Single dimension
    "a", "z", "aa", "zz", "abc", "foobar",

    # Two dimensions
    "a1", "z26", "aa1", "zz701",

    # Three dimensions
    "a1A", "z26Z", "aa1AA", "zz701ZZ",

    # Multi-cycle coordinates
    "a1Aa1A", "b2Bb2B", "h8Hh8H",

    # Extended alphabet cases
    "abc123XYZ", "foo999BAR"
  ]

  valid_coordinates.each do |coord|
    raise "#{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
  end
end

run_test("Invalid coordinates are properly rejected") do
  invalid_coordinates = [
    # Empty and non-string
    "", nil, 123, [], {},

    # Wrong starting character
    "1", "A", "1a", "Aa",

    # Contains zero
    "a0", "a0A", "a01A", "aa0AA",

    # Wrong cyclical order
    "a1a", "A1A", "aA", "a1A1",

    # Invalid characters
    "*", "a*", "1*", "A*", "a-1", "a1-A",

    # Whitespace issues
    " a1", "a1 ", "a 1", "a1 A"
  ]

  invalid_coordinates.each do |coord|
    raise "#{coord.inspect} should be invalid" if Sashite::Cell.valid?(coord)
  end
end

run_test("Non-string input is handled gracefully") do
  non_strings = [nil, 123, :a1, [], {}, true, false]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Cell.valid?(input)
    raise "#{input.inspect} should return 0 dimensions" unless Sashite::Cell.dimensions(input) == 0
    raise "#{input.inspect} should return empty parse array" unless Sashite::Cell.parse(input) == []
    raise "#{input.inspect} should return empty indices array" unless Sashite::Cell.to_indices(input) == []
  end
end

# ============================================================================
# DIMENSIONAL ANALYSIS TESTS
# ============================================================================

run_test("Dimension counting is accurate") do
  dimension_cases = {
    "a" => 1,
    "a1" => 2,
    "a1A" => 3,
    "a1Aa" => 4,
    "a1Aa1" => 5,
    "a1Aa1A" => 6,
    "a1Aa1Aa1A" => 9,    # Three complete cycles
    "abc" => 1,           # Extended single dimension
    "h8Hh8H" => 6,       # Game example
    "z999ZZZ" => 3       # Large values
  }

  dimension_cases.each do |coord, expected_dimensions|
    actual_dimensions = Sashite::Cell.dimensions(coord)
    raise "#{coord.inspect} should have #{expected_dimensions} dimensions, got #{actual_dimensions}" unless actual_dimensions == expected_dimensions
  end
end

run_test("Invalid input returns zero dimensions") do
  invalid_inputs = [nil, "", 123, [], "1a", "A1a", "a0", "*"]

  invalid_inputs.each do |input|
    dimensions = Sashite::Cell.dimensions(input)
    raise "#{input.inspect} should return 0 dimensions, got #{dimensions}" unless dimensions == 0
  end
end

# ============================================================================
# PARSING TESTS
# ============================================================================

run_test("Coordinate parsing splits components correctly") do
  parse_cases = {
    # Single dimension
    "a" => ["a"],
    "abc" => ["abc"],
    "foobar" => ["foobar"],

    # Multiple dimensions
    "a1" => ["a", "1"],
    "a1A" => ["a", "1", "A"],
    "a1Aa" => ["a", "1", "A", "a"],
    "a1Aa1" => ["a", "1", "A", "a", "1"],
    "a1Aa1A" => ["a", "1", "A", "a", "1", "A"],

    # Extended alphabet
    "aa1AA" => ["aa", "1", "AA"],
    "bb25BB" => ["bb", "25", "BB"],
    "abc123XYZ" => ["abc", "123", "XYZ"],

    # Game examples
    "h8Hh8" => ["h", "8", "H", "h", "8"],
    "e4" => ["e", "4"]
  }

  parse_cases.each do |coord, expected_components|
    actual_components = Sashite::Cell.parse(coord)
    raise "#{coord.inspect} should parse to #{expected_components.inspect}, got #{actual_components.inspect}" unless actual_components == expected_components
  end
end

run_test("Parse handles invalid input gracefully") do
  invalid_inputs = ["", nil, 123, "1a", "A1a", "a0", "*"]

  invalid_inputs.each do |input|
    result = Sashite::Cell.parse(input)
    raise "Invalid input #{input.inspect} should return empty array, got #{result.inspect}" unless result == []
  end
end

# ============================================================================
# COORDINATE CONVERSION TESTS
# ============================================================================

run_test("Coordinate to indices conversion is accurate") do
  conversion_cases = {
    # Basic cases
    "a1" => [0, 0],
    "b2" => [1, 1],
    "e4" => [4, 3],
    "h8" => [7, 7],

    # 3D cases
    "a1A" => [0, 0, 0],
    "b2B" => [1, 1, 1],
    "c3C" => [2, 2, 2],

    # Extended alphabet
    "z26Z" => [25, 25, 25],
    "aa1AA" => [26, 0, 26],
    "ab2AB" => [27, 1, 27],

    # Single dimension
    "a" => [0],
    "z" => [25],
    "aa" => [26],
    "zz" => [701]
  }

  conversion_cases.each do |coord, expected_indices|
    actual_indices = Sashite::Cell.to_indices(coord)
    raise "#{coord.inspect} should convert to #{expected_indices.inspect}, got #{actual_indices.inspect}" unless actual_indices == expected_indices
  end
end

run_test("Indices to coordinate conversion is accurate") do
  conversion_cases = [
    # Basic cases
    [[0, 0], "a1"],
    [[1, 1], "b2"],
    [[4, 3], "e4"],
    [[7, 7], "h8"],

    # 3D cases
    [[0, 0, 0], "a1A"],
    [[1, 1, 1], "b2B"],
    [[2, 2, 2], "c3C"],

    # Extended alphabet
    [[25, 25, 25], "z26Z"],
    [[26, 0, 26], "aa1AA"],
    [[27, 1, 27], "ab2AB"],

    # Single dimension
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

run_test("Round-trip coordinate conversion preserves values") do
  test_coordinates = [
    # Specification examples
    "a", "a1", "a1A", "a1Aa", "a1Aa1", "a1Aa1A",
    "aa1AA", "z26Z", "abc123XYZ",
    "e4", "h8", "a1A", "b2B", "c3C",

    # Extended cases
    "zz701ZZ", "abc999XYZ"
  ]

  test_coordinates.each do |coord|
    indices = Sashite::Cell.to_indices(coord)
    converted_back = Sashite::Cell.from_indices(*indices)
    raise "Round-trip failed for #{coord.inspect}: got #{converted_back.inspect}" unless converted_back == coord
  end
end

run_test("Round-trip indices conversion preserves values") do
  test_indices = [
    [0], [25], [26], [701],                    # 1D
    [0, 0], [4, 3], [7, 7], [25, 25],         # 2D
    [0, 0, 0], [1, 1, 1], [25, 25, 25],       # 3D
    [0, 0, 0, 0], [1, 1, 1, 1]                # 4D
  ]

  test_indices.each do |indices|
    coord = Sashite::Cell.from_indices(*indices)
    converted_back = Sashite::Cell.to_indices(coord)
    raise "Round-trip failed for #{indices.inspect}: got #{converted_back.inspect}" unless converted_back == indices
  end
end

run_test("Invalid coordinates return empty arrays for conversions") do
  invalid_coords = ["", "a0", "1a", "*", "a1a"]

  invalid_coords.each do |coord|
    result = Sashite::Cell.to_indices(coord)
    raise "#{coord.inspect} should return empty array, got #{result.inspect}" unless result == []
  end
end

# ============================================================================
# EXTENDED ALPHABET TESTS
# ============================================================================

run_test("Extended alphabet encoding follows specification") do
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

# ============================================================================
# GAME-SPECIFIC TESTS
# ============================================================================

run_test("Chess board coordinates work correctly") do
  chess_files = %w[a b c d e f g h]
  chess_ranks = %w[1 2 3 4 5 6 7 8]

  chess_files.each do |file|
    chess_ranks.each do |rank|
      coord = "#{file}#{rank}"
      raise "Chess coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)
      raise "Chess coordinate #{coord.inspect} should have 2 dimensions" unless Sashite::Cell.dimensions(coord) == 2
    end
  end

  # Test specific chess positions from specification
  Sashite::Cell.to_indices("e4").tap do |indices|
    raise "e4 should be [4, 3], got #{indices.inspect}" unless indices == [4, 3]
  end

  Sashite::Cell.from_indices(4, 3).tap do |coord|
    raise "[4, 3] should be e4, got #{coord.inspect}" unless coord == "e4"
  end
end

run_test("3D Tic-Tac-Toe coordinates work correctly") do
  # Test 3D positions from specification
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

  # Test the diagonal win from specification examples
  diagonal_positions = %w[a1A b2B c3C]
  expected_diagonal = [[0,0,0], [1,1,1], [2,2,2]]
  actual_diagonal = diagonal_positions.map { |pos| Sashite::Cell.to_indices(pos) }
  raise "3D diagonal should be #{expected_diagonal}, got #{actual_diagonal}" unless actual_diagonal == expected_diagonal
end

# ============================================================================
# REGEX AND UTILITY TESTS
# ============================================================================

run_test("Regex access returns correct pattern") do
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

# ============================================================================
# EDGE CASES AND BOUNDARY CONDITIONS
# ============================================================================

run_test("Large coordinate values are handled correctly") do
  large_coords = ["z26Z", "aa27AA", "zz702ZZ", "abc999XYZ"]

  large_coords.each do |coord|
    raise "Large coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)

    indices = Sashite::Cell.to_indices(coord)
    converted_back = Sashite::Cell.from_indices(*indices)
    raise "Round-trip failed for large coordinate #{coord.inspect}" unless converted_back == coord
  end
end

run_test("High-dimensional coordinates are handled correctly") do
  high_dim_coords = ["a1Aa1Aa1A", "b2Bb2Bb2B"]

  high_dim_coords.each do |coord|
    raise "High-dimensional coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)

    expected_dimensions = coord.scan(/[a-z]+|[1-9]\d*|[A-Z]+/).length
    actual_dimensions = Sashite::Cell.dimensions(coord)
    raise "#{coord.inspect} should have #{expected_dimensions} dimensions, got #{actual_dimensions}" unless actual_dimensions == expected_dimensions
  end
end

run_test("Numeric boundary conditions are respected") do
  # Test various numeric components
  numeric_coords = ["a1", "a10", "a100", "a999"]

  numeric_coords.each do |coord|
    raise "Numeric coordinate #{coord.inspect} should be valid" unless Sashite::Cell.valid?(coord)

    components = Sashite::Cell.parse(coord)
    numeric_component = components[1]
    expected_index = numeric_component.to_i - 1

    indices = Sashite::Cell.to_indices(coord)
    actual_numeric_index = indices[1]
    raise "Numeric component #{numeric_component} should convert to #{expected_index}, got #{actual_numeric_index}" unless actual_numeric_index == expected_index
  end

  # Verify zero is rejected
  zero_coords = ["a0", "a0A", "a01A", "aa0AA", "a1Aa0"]
  zero_coords.each do |coord|
    raise "Zero-containing coordinate #{coord.inspect} should be invalid" if Sashite::Cell.valid?(coord)
  end
end

run_test("API methods are stateless and consistent") do
  test_coord = "e4"

  # Test that repeated calls give consistent results
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

# ============================================================================
# SPECIFICATION COMPLIANCE VERIFICATION
# ============================================================================

run_test("All specification constraints are enforced") do
  puts "\n    Verifying specification constraints..."

  # Character validity
  raise "Only ASCII characters should be valid" unless Sashite::Cell.valid?("abc123XYZ")
  raise "Non-ASCII should be invalid" if Sashite::Cell.valid?("café")

  # Cyclical consistency
  raise "Complete cyclical pattern should be valid" unless Sashite::Cell.valid?("a1Aa1A")
  raise "Partial cyclical pattern should be valid" unless Sashite::Cell.valid?("a1Aa1")

  # Character set validity
  raise "Valid letter sequence should be accepted" unless Sashite::Cell.valid?("abc")
  raise "Valid letter sequence should be accepted" unless Sashite::Cell.valid?("cba")
  raise "Valid letter sequence should be accepted" unless Sashite::Cell.valid?("xyz")
  raise "Mixed case should be invalid" if Sashite::Cell.valid?("aBc")

  # Sequential order requirement
  raise "Must start with dimension 1" if Sashite::Cell.valid?("1a")
  raise "Must follow cyclical progression" if Sashite::Cell.valid?("aA")

  # Broken cyclical patterns should be invalid
  raise "Lowercase after numeric without uppercase should be invalid" if Sashite::Cell.valid?("a1a")
  raise "Numeric after uppercase without lowercase should be invalid" if Sashite::Cell.valid?("a1A1")
  raise "Uppercase directly after lowercase should be invalid" if Sashite::Cell.valid?("aA")

  # Partial completion allowed
  raise "Partial after dimension 1 should be valid" unless Sashite::Cell.valid?("a")
  raise "Partial after dimension 2 should be valid" unless Sashite::Cell.valid?("a1")
  raise "Partial after dimension 3 should be valid" unless Sashite::Cell.valid?("a1A")
  raise "Partial after dimension 4 should be valid" unless Sashite::Cell.valid?("a1Aa")
  raise "Partial after dimension 5 should be valid" unless Sashite::Cell.valid?("a1Aa1")

  puts "    ✓ All specification constraints verified"
end

puts
puts "All CELL v1.0.0 tests passed!"
puts

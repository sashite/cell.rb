# frozen_string_literal: true

require "simplecov"
SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Cell (Coordinate Expression Location Label)
#
# Tests the CELL implementation for Ruby, covering validation,
# location creation, board/hand distinction, and format compliance
# according to the CELL specification v1.0.0.
#
# This test assumes the existence of:
# - lib/sashite-cell.rb

require_relative "lib/sashite-cell"

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
puts "Tests for Sashite::Cell (Coordinate Expression Location Label)"
puts

# Test module-level validation method
run_test("Module validation accepts valid CELL strings") do
  valid_cells = [
    "e4", "a1", "h8", "E4", "A1", "H8",         # Chess coordinates
    "9a", "5e", "1i", "9A", "5E", "1I",         # Shōgi coordinates
    "A1", "T19", "K10", "a1", "t19", "k10",     # Go coordinates
    "A3a", "B2c", "Z9z",                        # 3D coordinates
    "center", "corner", "NE", "SW",             # Named locations
    "Q3R7", "P5K2",                             # Hexagonal coordinates
    "a", "A", "z", "Z", "0", "9",               # Single characters
    "abc123", "XYZ789", "test123",              # Mixed alphanumeric
    "*"                                         # Hand/reserve
  ]

  valid_cells.each do |cell|
    raise "#{cell.inspect} should be valid" unless Sashite::Cell.valid?(cell)
  end
end

run_test("Module validation rejects invalid CELL strings") do
  invalid_cells = [
    "", " ", "  ",                              # Empty or whitespace
    "e-4", "a_1", "h@8",                        # Special characters
    "e 4", " e4", "e4 ",                        # Spaces
    "e4!", "a1?", "h8#",                        # Punctuation
    "**", "***", "*a",                          # Multiple or mixed asterisks
    "a*", "*1", "e*4",                          # Asterisk with other chars
    "@", "#", "$", "%", "&",                    # Invalid symbols
    "-", "+", "=", "/", "\\",                   # Mathematical symbols
    ".", ",", ":", ";",                         # Punctuation marks
    "(", ")", "[", "]", "{", "}",               # Brackets
    "é4", "ñ1", "ü8",                          # Non-ASCII characters
    "e4\n", "a1\t", "h8\r"                     # Control characters
  ]

  invalid_cells.each do |cell|
    raise "#{cell.inspect} should be invalid" if Sashite::Cell.valid?(cell)
  end
end

run_test("Module validation handles non-string input") do
  non_strings = [nil, 123, :e4, [], {}, %w[e 4], 4.5, true, false]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Cell.valid?(input)
  end
end

run_test("Module validation follows CELL pattern exactly") do
  # Test the regex pattern boundaries
  boundary_cases = [
    ["e4", true],      # Valid board coordinate
    ["*", true],       # Valid hand coordinate
    ["", false],       # Empty string
    ["e", true],       # Single letter
    ["4", true],       # Single digit
    ["e4e", true],     # Multiple letters and digits
    ["123", true],     # Only digits
    ["ABC", true],     # Only letters
    ["e4-", false],    # Invalid character at end
    ["-e4", false],    # Invalid character at start
    ["e-4", false],    # Invalid character in middle
    ["*e", false],     # Asterisk with other characters
    ["e*", false],     # Other characters with asterisk
    ["**", false]      # Multiple asterisks
  ]

  boundary_cases.each do |cell, expected|
    result = Sashite::Cell.valid?(cell)
    unless result == expected
      raise "#{cell.inspect} should be #{expected ? 'valid' : 'invalid'}, got #{result}"
    end
  end
end

run_test("Module convenience method creates location objects") do
  location = Sashite::Cell.location("e4")

  raise "Should return Location instance" unless location.is_a?(Sashite::Cell::Location)
  raise "Should have correct coordinate" unless location.to_s == "e4"
end

run_test("Module convenience method handles hand location") do
  hand = Sashite::Cell.location("*")

  raise "Should return Location instance" unless hand.is_a?(Sashite::Cell::Location)
  raise "Should have correct coordinate" unless hand.to_s == "*"
  raise "Should be hand location" unless hand.hand?
end

# Test Location class creation and parsing
run_test("Location.new creates valid location objects") do
  locations = [
    "e4", "a1", "h8", "5c", "9a", "1i",
    "A1", "T19", "center", "Q3R7", "*"
  ]

  locations.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "Should be Location instance" unless location.is_a?(Sashite::Cell::Location)
    raise "Should preserve coordinate" unless location.to_s == coord
  end
end

run_test("Location.new rejects invalid coordinates") do
  invalid_coords = ["", "e-4", "a 1", "**", "@", "e4!"]

  invalid_coords.each do |coord|
    begin
      Sashite::Cell::Location.new(coord)
      raise "Should have raised ArgumentError for #{coord.inspect}"
    rescue ArgumentError => e
      raise "Wrong error message" unless e.message.include?("Invalid CELL coordinate")
    end
  end
end

run_test("Location.parse is equivalent to Location.new") do
  test_coords = ["e4", "a1", "5c", "center", "*"]

  test_coords.each do |coord|
    new_location = Sashite::Cell::Location.new(coord)
    parsed_location = Sashite::Cell::Location.parse(coord)

    raise "new and parse should create equivalent objects" unless new_location == parsed_location
    raise "Should have same string representation" unless new_location.to_s == parsed_location.to_s
  end
end

# Test board vs hand distinction
run_test("Location correctly identifies board coordinates") do
  board_coords = [
    "e4", "a1", "h8", "E4", "A1", "H8",
    "9a", "5e", "1i", "center", "corner",
    "A3a", "Q3R7", "abc123", "XYZ789",
    "a", "A", "z", "Z", "0", "9"
  ]

  board_coords.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be board coordinate" unless location.board?
    raise "#{coord} should not be hand coordinate" if location.hand?
  end
end

run_test("Location correctly identifies hand coordinate") do
  hand_location = Sashite::Cell::Location.new("*")

  raise "* should be hand coordinate" unless hand_location.hand?
  raise "* should not be board coordinate" if hand_location.board?
end

run_test("Location board? and hand? are mutually exclusive") do
  all_coords = ["e4", "a1", "center", "*", "9a", "A1", "abc123"]

  all_coords.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    board_result = location.board?
    hand_result = location.hand?

    # Exactly one should be true
    unless (board_result && !hand_result) || (!board_result && hand_result)
      raise "#{coord}: board? and hand? should be mutually exclusive"
    end
  end
end

# Test string conversion and representation
run_test("Location to_s returns original coordinate") do
  test_coords = [
    "e4", "a1", "h8", "E4", "A1", "H8",
    "9a", "5e", "1i", "center", "NE",
    "A3a", "Q3R7", "abc123", "*"
  ]

  test_coords.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should return original string" unless location.to_s == coord
  end
end

run_test("Location inspect provides debugging information") do
  location = Sashite::Cell::Location.new("e4")
  inspect_str = location.inspect

  raise "inspect should include class name" unless inspect_str.include?("Sashite::Cell::Location")
  raise "inspect should include coordinate" unless inspect_str.include?("e4")
  raise "inspect should include object_id" unless inspect_str.include?("0x")
end

# Test equality and hashing
run_test("Location equality works correctly") do
  # Same coordinates should be equal
  loc1 = Sashite::Cell::Location.new("e4")
  loc2 = Sashite::Cell::Location.new("e4")
  raise "Same coordinates should be equal" unless loc1 == loc2
  raise "Same coordinates should be eql" unless loc1.eql?(loc2)

  # Different coordinates should not be equal
  loc3 = Sashite::Cell::Location.new("e5")
  raise "Different coordinates should not be equal" if loc1 == loc3
  raise "Different coordinates should not be eql" if loc1.eql?(loc3)

  # Board vs hand should not be equal
  hand = Sashite::Cell::Location.new("*")
  raise "Board and hand should not be equal" if loc1 == hand
end

run_test("Location equality with non-Location objects") do
  location = Sashite::Cell::Location.new("e4")

  # Should not be equal to non-Location objects
  non_locations = ["e4", :e4, nil, 42, [], {}]
  non_locations.each do |obj|
    raise "Location should not equal #{obj.class}" if location == obj
  end
end

run_test("Location hashing enables use in collections") do
  # Same coordinates should have same hash
  loc1 = Sashite::Cell::Location.new("e4")
  loc2 = Sashite::Cell::Location.new("e4")
  raise "Same coordinates should have same hash" unless loc1.hash == loc2.hash

  # Different coordinates should have different hash (usually)
  loc3 = Sashite::Cell::Location.new("e5")
  # Note: Hash collision is theoretically possible but extremely unlikely
  # for our test cases, so we don't test for inequality

  # Should work in Set
  require 'set'
  location_set = Set.new
  location_set << loc1
  location_set << loc2  # Should not increase size (same location)
  location_set << loc3  # Should increase size (different location)

  raise "Set should deduplicate same locations" unless location_set.size == 2
  raise "Set should contain original locations" unless location_set.include?(loc1)
  raise "Set should contain different location" unless location_set.include?(loc3)
end

# Test coordinate system examples
run_test("Chess coordinate validation") do
  valid_chess = %w[a1 a8 h1 h8 e4 d5 c3 f6]
  invalid_chess = %w[i1 a9 z1 a0 h9]

  valid_chess.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be valid CELL (chess format)" unless location.board?
  end

  # Note: CELL doesn't validate chess-specific rules, so "invalid" chess
  # coordinates like "i1" are still valid CELL coordinates
  invalid_chess.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be valid CELL (even if invalid chess)" unless location.board?
  end
end

run_test("Shogi coordinate validation") do
  valid_shogi = %w[9a 9i 1a 1i 5e 7c 3g]

  valid_shogi.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be valid CELL (shogi format)" unless location.board?
  end
end

run_test("Go coordinate validation") do
  valid_go = %w[A1 A19 T1 T19 K10 D4 Q16]

  valid_go.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be valid CELL (go format)" unless location.board?
  end
end

run_test("Custom coordinate systems") do
  custom_coords = [
    "center", "corner", "NE", "SW", "TOP", "bottom",
    "A3a", "B2c", "Z9z",  # 3D coordinates
    "Q3R7", "P5K2",       # Hexagonal
    "level1", "room42", "exit", "start"
  ]

  custom_coords.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be valid CELL (custom format)" unless location.board?
  end
end

# Test edge cases and boundary conditions
run_test("Single character coordinates") do
  single_chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

  single_chars.each do |char|
    location = Sashite::Cell::Location.new(char)
    raise "#{char} should be valid board coordinate" unless location.board?
    raise "#{char} should not be hand coordinate" if location.hand?
  end
end

run_test("Long alphanumeric coordinates") do
  long_coords = [
    "abcdefghijklmnopqrstuvwxyz",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "0123456789",
    "abc123def456ghi789",
    "A1B2C3D4E5F6G7H8I9J0"
  ]

  long_coords.each do |coord|
    location = Sashite::Cell::Location.new(coord)
    raise "#{coord} should be valid CELL coordinate" unless location.board?
  end
end

run_test("Case sensitivity preservation") do
  case_variants = [
    ["e4", "E4"], ["a1", "A1"], ["center", "CENTER", "Center"],
    ["nw", "NW", "Nw", "nW"]
  ]

  case_variants.each do |variants|
    locations = variants.map { |coord| Sashite::Cell::Location.new(coord) }

    # All should be valid but distinct
    locations.each { |loc| raise "Should be board coordinate" unless loc.board? }

    # Each should preserve its original case
    variants.zip(locations).each do |original, location|
      raise "Should preserve case: #{original}" unless location.to_s == original
    end

    # Different cases should create different locations
    if variants.length > 1
      locations.combination(2).each do |loc1, loc2|
        unless loc1.to_s == loc2.to_s
          raise "Different cases should create different locations" if loc1 == loc2
        end
      end
    end
  end
end

# Test immutability
run_test("Location coordinates are immutable") do
  location = Sashite::Cell::Location.new("e4")
  coord_string = location.to_s

  # The returned string should be frozen or safe to modify
  original_coord = location.coordinate

  # Coordinate should be accessible but frozen
  raise "Coordinate should be frozen" unless original_coord.frozen?

  # Modifying the returned to_s string shouldn't affect the location
  coord_string.upcase! rescue nil  # Some implementations might return frozen strings
  raise "Location coordinate should be unchanged" unless location.to_s == "e4"
end

# Test HAND_CHAR constant
run_test("HAND_CHAR constant is correctly defined") do
  hand_char = Sashite::Cell::Location::HAND_CHAR

  raise "HAND_CHAR should be '*'" unless hand_char == "*"
  raise "HAND_CHAR should be frozen" unless hand_char.frozen?

  # Test that hand detection uses the constant
  hand_location = Sashite::Cell::Location.new(hand_char)
  raise "Location with HAND_CHAR should be hand location" unless hand_location.hand?
end

# Test error handling
run_test("Error messages are informative") do
  invalid_coords = ["", "e-4", "@location", "**"]

  invalid_coords.each do |coord|
    begin
      Sashite::Cell::Location.new(coord)
      raise "Should have raised ArgumentError for #{coord.inspect}"
    rescue ArgumentError => e
      error_msg = e.message
      raise "Error should mention 'Invalid CELL coordinate'" unless error_msg.include?("Invalid CELL coordinate")
      raise "Error should include the invalid coordinate" unless error_msg.include?(coord.inspect)
    end
  end
end

# Test integration scenarios
run_test("Mixed board and hand locations in collections") do
  mixed_coords = ["e4", "a1", "*", "center", "5c", "*", "h8"]
  locations = mixed_coords.map { |coord| Sashite::Cell::Location.new(coord) }

  board_locations = locations.select(&:board?)
  hand_locations = locations.select(&:hand?)

  expected_board_count = mixed_coords.count { |coord| coord != "*" }
  expected_hand_count = mixed_coords.count { |coord| coord == "*" }

  raise "Should have #{expected_board_count} board locations" unless board_locations.length == expected_board_count
  raise "Should have #{expected_hand_count} hand locations" unless hand_locations.length == expected_hand_count

  # All locations together should equal original count
  total_count = board_locations.length + hand_locations.length
  raise "Total should equal original count" unless total_count == locations.length
end

run_test("Locations work as hash keys") do
  location_hash = {}

  # Add some locations as keys
  location_hash[Sashite::Cell::Location.new("e4")] = "white pawn"
  location_hash[Sashite::Cell::Location.new("e5")] = "black pawn"
  location_hash[Sashite::Cell::Location.new("*")] = "captured pieces"

  # Same coordinates should access same values
  e4_again = Sashite::Cell::Location.new("e4")
  raise "Same coordinate should access same hash value" unless location_hash[e4_again] == "white pawn"

  # Different coordinates should be separate keys
  raise "Hash should have 3 keys" unless location_hash.keys.length == 3
end

puts
puts "All CELL tests passed!"
puts

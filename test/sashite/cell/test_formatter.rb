#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/cell/formatter"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "=== Formatter Tests ==="
puts

# ============================================================================
# 1D COORDINATES (LOWERCASE LETTERS)
# ============================================================================

puts "1D coordinates (lowercase letters):"

run_test("formats index 0 as 'a'") do
  result = Sashite::Cell::Formatter.indices_to_string([0])
  raise "expected 'a', got '#{result}'" unless result == "a"
end

run_test("formats index 4 as 'e'") do
  result = Sashite::Cell::Formatter.indices_to_string([4])
  raise "expected 'e', got '#{result}'" unless result == "e"
end

run_test("formats index 25 as 'z'") do
  result = Sashite::Cell::Formatter.indices_to_string([25])
  raise "expected 'z', got '#{result}'" unless result == "z"
end

run_test("formats index 26 as 'aa'") do
  result = Sashite::Cell::Formatter.indices_to_string([26])
  raise "expected 'aa', got '#{result}'" unless result == "aa"
end

run_test("formats index 27 as 'ab'") do
  result = Sashite::Cell::Formatter.indices_to_string([27])
  raise "expected 'ab', got '#{result}'" unless result == "ab"
end

run_test("formats index 51 as 'az'") do
  result = Sashite::Cell::Formatter.indices_to_string([51])
  raise "expected 'az', got '#{result}'" unless result == "az"
end

run_test("formats index 52 as 'ba'") do
  result = Sashite::Cell::Formatter.indices_to_string([52])
  raise "expected 'ba', got '#{result}'" unless result == "ba"
end

run_test("formats index 255 as 'iv'") do
  result = Sashite::Cell::Formatter.indices_to_string([255])
  raise "expected 'iv', got '#{result}'" unless result == "iv"
end

# ============================================================================
# 2D COORDINATES (LOWERCASE + INTEGER)
# ============================================================================

puts
puts "2D coordinates (lowercase + integer):"

run_test("formats [0, 0] as 'a1'") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 0])
  raise "expected 'a1', got '#{result}'" unless result == "a1"
end

run_test("formats [4, 3] as 'e4'") do
  result = Sashite::Cell::Formatter.indices_to_string([4, 3])
  raise "expected 'e4', got '#{result}'" unless result == "e4"
end

run_test("formats [7, 7] as 'h8'") do
  result = Sashite::Cell::Formatter.indices_to_string([7, 7])
  raise "expected 'h8', got '#{result}'" unless result == "h8"
end

run_test("formats [0, 255] as 'a256'") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 255])
  raise "expected 'a256', got '#{result}'" unless result == "a256"
end

run_test("formats [255, 255] as 'iv256'") do
  result = Sashite::Cell::Formatter.indices_to_string([255, 255])
  raise "expected 'iv256', got '#{result}'" unless result == "iv256"
end

run_test("formats [26, 9] as 'aa10'") do
  result = Sashite::Cell::Formatter.indices_to_string([26, 9])
  raise "expected 'aa10', got '#{result}'" unless result == "aa10"
end

# ============================================================================
# 3D COORDINATES (LOWERCASE + INTEGER + UPPERCASE)
# ============================================================================

puts
puts "3D coordinates (lowercase + integer + uppercase):"

run_test("formats [0, 0, 0] as 'a1A'") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 0, 0])
  raise "expected 'a1A', got '#{result}'" unless result == "a1A"
end

run_test("formats [4, 3, 1] as 'e4B'") do
  result = Sashite::Cell::Formatter.indices_to_string([4, 3, 1])
  raise "expected 'e4B', got '#{result}'" unless result == "e4B"
end

run_test("formats [2, 2, 2] as 'c3C'") do
  result = Sashite::Cell::Formatter.indices_to_string([2, 2, 2])
  raise "expected 'c3C', got '#{result}'" unless result == "c3C"
end

run_test("formats [0, 0, 25] as 'a1Z'") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 0, 25])
  raise "expected 'a1Z', got '#{result}'" unless result == "a1Z"
end

run_test("formats [0, 0, 26] as 'a1AA'") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 0, 26])
  raise "expected 'a1AA', got '#{result}'" unless result == "a1AA"
end

run_test("formats [0, 0, 255] as 'a1IV'") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 0, 255])
  raise "expected 'a1IV', got '#{result}'" unless result == "a1IV"
end

run_test("formats [255, 255, 255] as 'iv256IV'") do
  result = Sashite::Cell::Formatter.indices_to_string([255, 255, 255])
  raise "expected 'iv256IV', got '#{result}'" unless result == "iv256IV"
end

# ============================================================================
# OUTPUT PROPERTIES
# ============================================================================

puts
puts "Output properties:"

run_test("returns a frozen string") do
  result = Sashite::Cell::Formatter.indices_to_string([4, 3])
  raise "result should be frozen" unless result.frozen?
end

run_test("returns a new string each time") do
  result1 = Sashite::Cell::Formatter.indices_to_string([4, 3])
  result2 = Sashite::Cell::Formatter.indices_to_string([4, 3])
  raise "results should be equal" unless result1 == result2
  raise "results should not be same object" if result1.equal?(result2)
end

# ============================================================================
# BOUNDARY VALUES
# ============================================================================

puts
puts "Boundary values:"

run_test("formats minimum values [0]") do
  result = Sashite::Cell::Formatter.indices_to_string([0])
  raise "expected 'a', got '#{result}'" unless result == "a"
end

run_test("formats maximum 1D value [255]") do
  result = Sashite::Cell::Formatter.indices_to_string([255])
  raise "expected 'iv', got '#{result}'" unless result == "iv"
end

run_test("formats minimum 3D values [0, 0, 0]") do
  result = Sashite::Cell::Formatter.indices_to_string([0, 0, 0])
  raise "expected 'a1A', got '#{result}'" unless result == "a1A"
end

run_test("formats maximum 3D values [255, 255, 255]") do
  result = Sashite::Cell::Formatter.indices_to_string([255, 255, 255])
  raise "expected 'iv256IV', got '#{result}'" unless result == "iv256IV"
end

run_test("formats boundary value 25 (single letter)") do
  result = Sashite::Cell::Formatter.indices_to_string([25, 25, 25])
  raise "expected 'z26Z', got '#{result}'" unless result == "z26Z"
end

run_test("formats boundary value 26 (double letters)") do
  result = Sashite::Cell::Formatter.indices_to_string([26, 26, 26])
  raise "expected 'aa27AA', got '#{result}'" unless result == "aa27AA"
end

# ============================================================================
# EMPTY INPUT
# ============================================================================

puts
puts "Empty input:"

run_test("formats empty array as empty string") do
  result = Sashite::Cell::Formatter.indices_to_string([])
  raise "expected '', got '#{result}'" unless result == ""
end

puts
puts "All Formatter tests passed!"
puts

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/cell/parser"
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
puts "=== Parser Tests ==="
puts

# ============================================================================
# VALID 1D COORDINATES (LOWERCASE LETTERS)
# ============================================================================

puts "Valid 1D coordinates (lowercase letters):"

run_test("parses 'a' as [0]") do
  result = Sashite::Cell::Parser.parse_to_indices("a")
  raise "expected [0], got #{result.inspect}" unless result == [0]
end

run_test("parses 'e' as [4]") do
  result = Sashite::Cell::Parser.parse_to_indices("e")
  raise "expected [4], got #{result.inspect}" unless result == [4]
end

run_test("parses 'z' as [25]") do
  result = Sashite::Cell::Parser.parse_to_indices("z")
  raise "expected [25], got #{result.inspect}" unless result == [25]
end

run_test("parses 'aa' as [26]") do
  result = Sashite::Cell::Parser.parse_to_indices("aa")
  raise "expected [26], got #{result.inspect}" unless result == [26]
end

run_test("parses 'ab' as [27]") do
  result = Sashite::Cell::Parser.parse_to_indices("ab")
  raise "expected [27], got #{result.inspect}" unless result == [27]
end

run_test("parses 'az' as [51]") do
  result = Sashite::Cell::Parser.parse_to_indices("az")
  raise "expected [51], got #{result.inspect}" unless result == [51]
end

run_test("parses 'ba' as [52]") do
  result = Sashite::Cell::Parser.parse_to_indices("ba")
  raise "expected [52], got #{result.inspect}" unless result == [52]
end

run_test("parses 'iv' as [255]") do
  result = Sashite::Cell::Parser.parse_to_indices("iv")
  raise "expected [255], got #{result.inspect}" unless result == [255]
end

# ============================================================================
# VALID 2D COORDINATES (LOWERCASE + INTEGER)
# ============================================================================

puts
puts "Valid 2D coordinates (lowercase + integer):"

run_test("parses 'a1' as [0, 0]") do
  result = Sashite::Cell::Parser.parse_to_indices("a1")
  raise "expected [0, 0], got #{result.inspect}" unless result == [0, 0]
end

run_test("parses 'e4' as [4, 3]") do
  result = Sashite::Cell::Parser.parse_to_indices("e4")
  raise "expected [4, 3], got #{result.inspect}" unless result == [4, 3]
end

run_test("parses 'h8' as [7, 7]") do
  result = Sashite::Cell::Parser.parse_to_indices("h8")
  raise "expected [7, 7], got #{result.inspect}" unless result == [7, 7]
end

run_test("parses 'a256' as [0, 255]") do
  result = Sashite::Cell::Parser.parse_to_indices("a256")
  raise "expected [0, 255], got #{result.inspect}" unless result == [0, 255]
end

run_test("parses 'iv256' as [255, 255]") do
  result = Sashite::Cell::Parser.parse_to_indices("iv256")
  raise "expected [255, 255], got #{result.inspect}" unless result == [255, 255]
end

run_test("parses 'aa10' as [26, 9]") do
  result = Sashite::Cell::Parser.parse_to_indices("aa10")
  raise "expected [26, 9], got #{result.inspect}" unless result == [26, 9]
end

# ============================================================================
# VALID 3D COORDINATES (LOWERCASE + INTEGER + UPPERCASE)
# ============================================================================

puts
puts "Valid 3D coordinates (lowercase + integer + uppercase):"

run_test("parses 'a1A' as [0, 0, 0]") do
  result = Sashite::Cell::Parser.parse_to_indices("a1A")
  raise "expected [0, 0, 0], got #{result.inspect}" unless result == [0, 0, 0]
end

run_test("parses 'e4B' as [4, 3, 1]") do
  result = Sashite::Cell::Parser.parse_to_indices("e4B")
  raise "expected [4, 3, 1], got #{result.inspect}" unless result == [4, 3, 1]
end

run_test("parses 'c3C' as [2, 2, 2]") do
  result = Sashite::Cell::Parser.parse_to_indices("c3C")
  raise "expected [2, 2, 2], got #{result.inspect}" unless result == [2, 2, 2]
end

run_test("parses 'a1Z' as [0, 0, 25]") do
  result = Sashite::Cell::Parser.parse_to_indices("a1Z")
  raise "expected [0, 0, 25], got #{result.inspect}" unless result == [0, 0, 25]
end

run_test("parses 'a1AA' as [0, 0, 26]") do
  result = Sashite::Cell::Parser.parse_to_indices("a1AA")
  raise "expected [0, 0, 26], got #{result.inspect}" unless result == [0, 0, 26]
end

run_test("parses 'a1IV' as [0, 0, 255]") do
  result = Sashite::Cell::Parser.parse_to_indices("a1IV")
  raise "expected [0, 0, 255], got #{result.inspect}" unless result == [0, 0, 255]
end

run_test("parses 'iv256IV' as [255, 255, 255]") do
  result = Sashite::Cell::Parser.parse_to_indices("iv256IV")
  raise "expected [255, 255, 255], got #{result.inspect}" unless result == [255, 255, 255]
end

# ============================================================================
# INVALID: EMPTY INPUT
# ============================================================================

puts
puts "Invalid: empty input:"

run_test("raises on empty string") do
  Sashite::Cell::Parser.parse_to_indices("")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("empty input")
end

# ============================================================================
# INVALID: INPUT TOO LONG
# ============================================================================

puts
puts "Invalid: input too long:"

run_test("raises on 8 characters") do
  Sashite::Cell::Parser.parse_to_indices("iv256IVa")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("input exceeds 7 characters")
end

run_test("raises on very long input") do
  Sashite::Cell::Parser.parse_to_indices("abcdefghijklmnop")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("input exceeds 7 characters")
end

# ============================================================================
# INVALID: MUST START WITH LOWERCASE
# ============================================================================

puts
puts "Invalid: must start with lowercase:"

run_test("raises on uppercase start") do
  Sashite::Cell::Parser.parse_to_indices("A")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("must start with lowercase letter")
end

run_test("raises on digit start") do
  Sashite::Cell::Parser.parse_to_indices("1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("must start with lowercase letter")
end

run_test("raises on space start") do
  Sashite::Cell::Parser.parse_to_indices(" a1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("must start with lowercase letter")
end

run_test("raises on special character start") do
  Sashite::Cell::Parser.parse_to_indices("@a1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("must start with lowercase letter")
end

# ============================================================================
# INVALID: UNEXPECTED CHARACTER
# ============================================================================

puts
puts "Invalid: unexpected character:"

run_test("raises on uppercase after lowercase (missing integer)") do
  Sashite::Cell::Parser.parse_to_indices("aA")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("unexpected character")
end

run_test("raises on special character in middle") do
  Sashite::Cell::Parser.parse_to_indices("a@1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("unexpected character")
end

run_test("raises on space in middle") do
  Sashite::Cell::Parser.parse_to_indices("a 1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("unexpected character")
end

# ============================================================================
# INVALID: LEADING ZERO
# ============================================================================

puts
puts "Invalid: leading zero:"

run_test("raises on '0' as integer") do
  Sashite::Cell::Parser.parse_to_indices("a0")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("leading zero")
end

run_test("raises on '01' (leading zero)") do
  Sashite::Cell::Parser.parse_to_indices("a01")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("leading zero")
end

run_test("raises on '007'") do
  Sashite::Cell::Parser.parse_to_indices("a007")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("leading zero")
end

# ============================================================================
# INVALID: EXCEEDS 3 DIMENSIONS
# ============================================================================

puts
puts "Invalid: exceeds 3 dimensions:"

run_test("raises on 4D coordinate pattern") do
  Sashite::Cell::Parser.parse_to_indices("a1Aa")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("exceeds 3 dimensions")
end

# ============================================================================
# INVALID: INDEX OUT OF RANGE
# ============================================================================

puts
puts "Invalid: index out of range:"

run_test("raises on integer 257 (index 256)") do
  Sashite::Cell::Parser.parse_to_indices("a257")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on integer 999 (index 998)") do
  Sashite::Cell::Parser.parse_to_indices("a999")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on lowercase 'iw' (index 256)") do
  Sashite::Cell::Parser.parse_to_indices("iw")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on uppercase 'IW' (index 256)") do
  Sashite::Cell::Parser.parse_to_indices("a1IW")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

# ============================================================================
# SECURITY: MALICIOUS INPUTS
# ============================================================================

puts
puts "Security: malicious inputs:"

run_test("rejects null byte injection") do
  Sashite::Cell::Parser.parse_to_indices("a\x00")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects newline injection") do
  Sashite::Cell::Parser.parse_to_indices("a\n1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects carriage return injection") do
  Sashite::Cell::Parser.parse_to_indices("a\r1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects tab injection") do
  Sashite::Cell::Parser.parse_to_indices("a\t1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects unicode letter lookalikes (Cyrillic 'а')") do
  # Cyrillic 'а' (U+0430) looks like Latin 'a'
  Sashite::Cell::Parser.parse_to_indices("\u0430")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects full-width characters") do
  # Full-width 'a' (U+FF41)
  Sashite::Cell::Parser.parse_to_indices("\uFF41")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects combining characters") do
  Sashite::Cell::Parser.parse_to_indices("a\u0301")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("rejects zero-width characters") do
  Sashite::Cell::Parser.parse_to_indices("a\u200B1")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument
  # Expected
end

run_test("handles maximum valid input without overflow") do
  result = Sashite::Cell::Parser.parse_to_indices("iv256IV")
  raise "expected [255, 255, 255], got #{result.inspect}" unless result == [255, 255, 255]
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

puts
puts "Round-trip (parse → format → parse):"

run_test("round-trips 'e4'") do
  indices = Sashite::Cell::Parser.parse_to_indices("e4")
  formatted = Sashite::Cell::Formatter.indices_to_string(indices)
  reparsed = Sashite::Cell::Parser.parse_to_indices(formatted)
  raise "round-trip failed" unless reparsed == indices
end

run_test("round-trips 'iv256IV'") do
  indices = Sashite::Cell::Parser.parse_to_indices("iv256IV")
  formatted = Sashite::Cell::Formatter.indices_to_string(indices)
  reparsed = Sashite::Cell::Parser.parse_to_indices(formatted)
  raise "round-trip failed" unless reparsed == indices
end

run_test("round-trips 'aa27AA'") do
  indices = Sashite::Cell::Parser.parse_to_indices("aa27AA")
  formatted = Sashite::Cell::Formatter.indices_to_string(indices)
  reparsed = Sashite::Cell::Parser.parse_to_indices(formatted)
  raise "round-trip failed" unless reparsed == indices
end

puts
puts "All Parser tests passed!"
puts

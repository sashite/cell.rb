#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/cell/coordinate"

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
puts "=== Coordinate Tests ==="
puts

# ============================================================================
# CONSTRUCTOR TESTS
# ============================================================================

puts "Constructor:"

run_test("creates 1D coordinate") do
  coord = Sashite::Cell::Coordinate.new(0)
  raise "dimensions should be 1" unless coord.dimensions == 1
  raise "indices should be [0]" unless coord.indices == [0]
end

run_test("creates 2D coordinate") do
  coord = Sashite::Cell::Coordinate.new(4, 3)
  raise "dimensions should be 2" unless coord.dimensions == 2
  raise "indices should be [4, 3]" unless coord.indices == [4, 3]
end

run_test("creates 3D coordinate") do
  coord = Sashite::Cell::Coordinate.new(0, 0, 0)
  raise "dimensions should be 3" unless coord.dimensions == 3
  raise "indices should be [0, 0, 0]" unless coord.indices == [0, 0, 0]
end

run_test("accepts index 0") do
  coord = Sashite::Cell::Coordinate.new(0)
  raise "indices should be [0]" unless coord.indices == [0]
end

run_test("accepts index 255") do
  coord = Sashite::Cell::Coordinate.new(255)
  raise "indices should be [255]" unless coord.indices == [255]
end

run_test("raises on no indices") do
  Sashite::Cell::Coordinate.new
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("at least one index required")
end

run_test("raises on more than 3 indices") do
  Sashite::Cell::Coordinate.new(0, 0, 0, 0)
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("exceeds 3 dimensions")
end

run_test("raises on negative index") do
  Sashite::Cell::Coordinate.new(-1)
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on index greater than 255") do
  Sashite::Cell::Coordinate.new(256)
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on non-integer index") do
  Sashite::Cell::Coordinate.new(1.5)
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on string index") do
  Sashite::Cell::Coordinate.new("a")
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

run_test("raises on nil index") do
  Sashite::Cell::Coordinate.new(nil)
  raise "should have raised"
rescue Sashite::Cell::Errors::Argument => e
  raise "wrong message" unless e.message.include?("index exceeds 255")
end

# ============================================================================
# DIMENSIONS TESTS
# ============================================================================

puts
puts "Dimensions:"

run_test("returns 1 for 1D coordinate") do
  raise "wrong dimensions" unless Sashite::Cell::Coordinate.new(5).dimensions == 1
end

run_test("returns 2 for 2D coordinate") do
  raise "wrong dimensions" unless Sashite::Cell::Coordinate.new(4, 3).dimensions == 2
end

run_test("returns 3 for 3D coordinate") do
  raise "wrong dimensions" unless Sashite::Cell::Coordinate.new(0, 0, 0).dimensions == 3
end

# ============================================================================
# INDICES TESTS
# ============================================================================

puts
puts "Indices:"

run_test("returns frozen array") do
  coord = Sashite::Cell::Coordinate.new(4, 3)
  raise "indices should be [4, 3]" unless coord.indices == [4, 3]
  raise "indices should be frozen" unless coord.indices.frozen?
end

run_test("returns same reference on multiple calls") do
  coord = Sashite::Cell::Coordinate.new(4, 3)
  raise "should return same object" unless coord.indices.equal?(coord.indices)
end

# ============================================================================
# TO_S TESTS
# ============================================================================

puts
puts "to_s (1D coordinates - lowercase letters):"

run_test("encodes index 0 as 'a'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0).to_s == "a"
end

run_test("encodes index 4 as 'e'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(4).to_s == "e"
end

run_test("encodes index 25 as 'z'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(25).to_s == "z"
end

run_test("encodes index 26 as 'aa'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(26).to_s == "aa"
end

run_test("encodes index 27 as 'ab'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(27).to_s == "ab"
end

run_test("encodes index 51 as 'az'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(51).to_s == "az"
end

run_test("encodes index 52 as 'ba'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(52).to_s == "ba"
end

run_test("encodes index 255 as 'iv'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(255).to_s == "iv"
end

puts
puts "to_s (2D coordinates - lowercase + integer):"

run_test("encodes (0, 0) as 'a1'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0, 0).to_s == "a1"
end

run_test("encodes (4, 3) as 'e4' (chess e4)") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(4, 3).to_s == "e4"
end

run_test("encodes (7, 7) as 'h8' (chess h8)") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(7, 7).to_s == "h8"
end

run_test("encodes (0, 255) as 'a256'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0, 255).to_s == "a256"
end

run_test("encodes (255, 255) as 'iv256'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(255, 255).to_s == "iv256"
end

puts
puts "to_s (3D coordinates - lowercase + integer + uppercase):"

run_test("encodes (0, 0, 0) as 'a1A'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0, 0, 0).to_s == "a1A"
end

run_test("encodes (4, 3, 1) as 'e4B'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(4, 3, 1).to_s == "e4B"
end

run_test("encodes (2, 2, 2) as 'c3C'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(2, 2, 2).to_s == "c3C"
end

run_test("encodes (0, 0, 25) as 'a1Z'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0, 0, 25).to_s == "a1Z"
end

run_test("encodes (0, 0, 26) as 'a1AA'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0, 0, 26).to_s == "a1AA"
end

run_test("encodes (0, 0, 255) as 'a1IV'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(0, 0, 255).to_s == "a1IV"
end

run_test("encodes (255, 255, 255) as 'iv256IV'") do
  raise "wrong encoding" unless Sashite::Cell::Coordinate.new(255, 255, 255).to_s == "iv256IV"
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

puts
puts "Equality:"

run_test("== returns true for equal coordinates") do
  a = Sashite::Cell::Coordinate.new(4, 3)
  b = Sashite::Cell::Coordinate.new(4, 3)
  raise "should be equal" unless a == b
end

run_test("== returns false for different coordinates") do
  a = Sashite::Cell::Coordinate.new(4, 3)
  b = Sashite::Cell::Coordinate.new(3, 4)
  raise "should not be equal" if a == b
end

run_test("== returns false for different dimensions") do
  a = Sashite::Cell::Coordinate.new(4, 3)
  b = Sashite::Cell::Coordinate.new(4, 3, 0)
  raise "should not be equal" if a == b
end

run_test("== returns false for non-Coordinate") do
  a = Sashite::Cell::Coordinate.new(4, 3)
  raise "should not be equal to array" if a == [4, 3]
  raise "should not be equal to string" if a == "e4"
end

run_test("eql? is aliased to ==") do
  a = Sashite::Cell::Coordinate.new(4, 3)
  b = Sashite::Cell::Coordinate.new(4, 3)
  raise "eql? should work" unless a.eql?(b)
end

# ============================================================================
# HASH TESTS
# ============================================================================

puts
puts "Hash:"

run_test("equal coordinates have same hash") do
  a = Sashite::Cell::Coordinate.new(4, 3)
  b = Sashite::Cell::Coordinate.new(4, 3)
  raise "hash should be equal" unless a.hash == b.hash
end

run_test("can be used as Hash key") do
  coord = Sashite::Cell::Coordinate.new(4, 3)
  hash = { coord => "value" }
  lookup = Sashite::Cell::Coordinate.new(4, 3)
  raise "hash lookup should work" unless hash[lookup] == "value"
end

# ============================================================================
# INSPECT TESTS
# ============================================================================

puts
puts "Inspect:"

run_test("returns readable representation") do
  coord = Sashite::Cell::Coordinate.new(4, 3)
  result = coord.inspect
  raise "should include class name" unless result.include?("Sashite::Cell::Coordinate")
  raise "should include string representation" unless result.include?("e4")
end

puts
puts "All Coordinate tests passed!"
puts

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/cell/errors"

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
puts "=== Errors Tests ==="
puts

# ============================================================================
# ERRORS::ARGUMENT INHERITANCE TESTS
# ============================================================================

puts "Errors::Argument inheritance:"

run_test("is a subclass of ArgumentError") do
  raise "should inherit from ArgumentError" unless Sashite::Cell::Errors::Argument < ArgumentError
end

run_test("instance is an ArgumentError") do
  error = Sashite::Cell::Errors::Argument.new("test message")
  raise "should be an ArgumentError" unless error.is_a?(ArgumentError)
end

run_test("instance is an Errors::Argument") do
  error = Sashite::Cell::Errors::Argument.new("test message")
  raise "should be an Errors::Argument" unless error.is_a?(Sashite::Cell::Errors::Argument)
end

# ============================================================================
# ERRORS::ARGUMENT PROPERTIES TESTS
# ============================================================================

puts
puts "Errors::Argument properties:"

run_test("has correct message") do
  error = Sashite::Cell::Errors::Argument.new("test message")
  raise "wrong message" unless error.message == "test message"
end

run_test("has backtrace when raised") do
  begin
    raise Sashite::Cell::Errors::Argument, "test"
  rescue Sashite::Cell::Errors::Argument => e
    raise "should have backtrace" if e.backtrace.nil? || e.backtrace.empty?
  end
end

# ============================================================================
# ERRORS::ARGUMENT CATCH BEHAVIOR TESTS
# ============================================================================

puts
puts "Errors::Argument catch behavior:"

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Cell::Errors::Argument, "test"
  rescue ArgumentError
    caught = true
  end
  raise "should be caught as ArgumentError" unless caught
end

run_test("can be caught specifically as Errors::Argument") do
  caught = false
  begin
    raise Sashite::Cell::Errors::Argument, "test"
  rescue Sashite::Cell::Errors::Argument
    caught = true
  end
  raise "should be caught as Errors::Argument" unless caught
end

run_test("can distinguish Errors::Argument from other ArgumentError") do
  is_cell_error = false
  begin
    raise Sashite::Cell::Errors::Argument, "test"
  rescue Sashite::Cell::Errors::Argument
    is_cell_error = true
  rescue ArgumentError
    is_cell_error = false
  end
  raise "should be identified as Errors::Argument" unless is_cell_error

  is_not_cell_error = true
  begin
    raise ArgumentError, "test"
  rescue Sashite::Cell::Errors::Argument
    is_not_cell_error = false
  rescue ArgumentError
    is_not_cell_error = true
  end
  raise "should not be identified as Errors::Argument" unless is_not_cell_error
end

# ============================================================================
# ERRORS::ARGUMENT::MESSAGES TESTS
# ============================================================================

puts
puts "Errors::Argument::Messages constants:"

run_test("EMPTY_INPUT is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::EMPTY_INPUT
  raise "wrong value" unless value == "empty input"
end

run_test("INPUT_TOO_LONG is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::INPUT_TOO_LONG
  raise "wrong value" unless value == "input exceeds 7 characters"
end

run_test("INVALID_START is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::INVALID_START
  raise "wrong value" unless value == "must start with lowercase letter"
end

run_test("UNEXPECTED_CHARACTER is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::UNEXPECTED_CHARACTER
  raise "wrong value" unless value == "unexpected character"
end

run_test("LEADING_ZERO is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::LEADING_ZERO
  raise "wrong value" unless value == "leading zero"
end

run_test("TOO_MANY_DIMENSIONS is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::TOO_MANY_DIMENSIONS
  raise "wrong value" unless value == "exceeds 3 dimensions"
end

run_test("INDEX_OUT_OF_RANGE is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::INDEX_OUT_OF_RANGE
  raise "wrong value" unless value == "index exceeds 255"
end

run_test("NO_INDICES is defined correctly") do
  value = Sashite::Cell::Errors::Argument::Messages::NO_INDICES
  raise "wrong value" unless value == "at least one index required"
end

# ============================================================================
# ERRORS::ARGUMENT::MESSAGES USAGE TESTS
# ============================================================================

puts
puts "Errors::Argument::Messages usage:"

run_test("messages can be used to raise errors") do
  begin
    raise Sashite::Cell::Errors::Argument, Sashite::Cell::Errors::Argument::Messages::EMPTY_INPUT
  rescue Sashite::Cell::Errors::Argument => e
    raise "wrong message" unless e.message == "empty input"
  end
end

run_test("messages are frozen strings") do
  message = Sashite::Cell::Errors::Argument::Messages::EMPTY_INPUT
  raise "message should be frozen" unless message.frozen?
end

puts
puts "All Errors tests passed!"
puts

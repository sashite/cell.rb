# cell.rb

[![Version](https://img.shields.io/github/v/tag/sashite/cell.rb?label=Version&logo=github)](https://github.com/sashite/cell.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/cell.rb/main)
[![CI](https://github.com/sashite/cell.rb/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/sashite/cell.rb/actions)
[![License](https://img.shields.io/github/license/sashite/cell.rb)](https://github.com/sashite/cell.rb/blob/main/LICENSE)

> **CELL** (Coordinate Encoding for Layered Locations) implementation for Ruby.

## Overview

This library implements the [CELL Specification v1.0.0](https://sashite.dev/specs/cell/1.0.0/).

### Implementation Constraints

| Constraint | Value | Rationale |
|------------|-------|-----------|
| Max dimensions | 3 | Sufficient for 1D, 2D, 3D boards |
| Max index value | 255 | Fits in 8-bit integer, covers 256×256×256 boards |
| Max string length | 7 | `"iv256IV"` (max for all dimensions at 255) |

These constraints enable bounded memory usage and safe parsing.

## Installation

```ruby
# In your Gemfile
gem "sashite-cell"
```

Or install manually:

```sh
gem install sashite-cell
```

## Usage

### Parsing (String → Coordinate)

Convert a CELL string into a `Coordinate` object.

```ruby
require "sashite/cell"

# Standard parsing (returns Coordinate or raises)
coord = Sashite::Cell.parse("e4")
coord.indices    # => [4, 3]
coord.dimensions # => 2

# 3D coordinate
coord = Sashite::Cell.parse("a1A")
coord.indices # => [0, 0, 0]

# Invalid input raises ArgumentError
Sashite::Cell.parse("a0") # => raises ArgumentError
```

### Formatting (Coordinate → String)

Convert a `Coordinate` back to a CELL string.

```ruby
# From Coordinate object
coord = Sashite::Cell::Coordinate.new(4, 3)
coord.to_s # => "e4"

# Direct formatting (convenience)
Sashite::Cell.format(2, 2, 2) # => "c3C"
```

### Validation

```ruby
# Boolean check
Sashite::Cell.valid?("e4") # => true

# Detailed error
Sashite::Cell.validate("a0") # => raises ArgumentError, "leading zero"
```

### Accessing Coordinate Data

```ruby
coord = Sashite::Cell.parse("e4")

# Get dimensions count
coord.dimensions # => 2

# Get indices as array
coord.indices # => [4, 3]

# Access individual index
coord.indices[0] # => 4
coord.indices[1] # => 3
```

## API Reference

### Types

```ruby
# Coordinate represents a parsed CELL coordinate with up to 3 dimensions.
class Sashite::Cell::Coordinate
  # Creates a Coordinate from 1 to 3 indices.
  # Raises ArgumentError if no indices provided or more than 3.
  #
  # @param indices [Array<Integer>] 0-indexed coordinate values (0-255)
  # @return [Coordinate]
  def initialize(*indices)

  # Returns the number of dimensions (1, 2, or 3).
  #
  # @return [Integer]
  def dimensions

  # Returns the coordinate indices as a frozen array.
  #
  # @return [Array<Integer>]
  def indices

  # Returns the CELL string representation.
  #
  # @return [String]
  def to_s
end
```

### Constants

```ruby
Sashite::Cell::Coordinate::MAX_DIMENSIONS = 3
Sashite::Cell::Coordinate::MAX_INDEX_VALUE = 255
Sashite::Cell::Coordinate::MAX_STRING_LENGTH = 7
```

### Parsing

```ruby
# Parses a CELL string into a Coordinate.
# Raises ArgumentError if the string is not valid.
#
# @param string [String] CELL coordinate string
# @return [Coordinate]
# @raise [ArgumentError] if invalid
def Sashite::Cell.parse(string)
```

### Formatting

```ruby
# Formats indices into a CELL string.
# Convenience method equivalent to Coordinate.new(*indices).to_s.
#
# @param indices [Array<Integer>] 0-indexed coordinate values
# @return [String]
def Sashite::Cell.format(*indices)
```

### Validation

```ruby
# Validates a CELL string.
# Raises ArgumentError with descriptive message if invalid.
#
# @param string [String] CELL coordinate string
# @return [nil]
# @raise [ArgumentError] if invalid
def Sashite::Cell.validate(string)

# Reports whether string is a valid CELL coordinate.
#
# @param string [String] CELL coordinate string
# @return [Boolean]
def Sashite::Cell.valid?(string)
```

### Errors

All parsing and validation errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"empty input"` | String length is 0 |
| `"input exceeds 7 characters"` | String too long |
| `"must start with lowercase letter"` | Invalid first character |
| `"unexpected character"` | Character violates the cyclic sequence |
| `"leading zero"` | Numeric part starts with '0' |
| `"exceeds 3 dimensions"` | More than 3 dimensions |
| `"index exceeds 255"` | Decoded value out of range |

## Design Principles

- **Bounded values**: Index validation prevents overflow
- **Object-oriented**: `Coordinate` class enables methods and encapsulation
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, `ArgumentError` for invalid input
- **Immutable coordinates**: Frozen indices array prevents mutation
- **No dependencies**: Pure Ruby standard library only

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [CELL Specification](https://sashite.dev/specs/cell/1.0.0/) — Official specification
- [CELL Examples](https://sashite.dev/specs/cell/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).

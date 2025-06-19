# Cell.rb

[![Version](https://img.shields.io/github/v/tag/sashite/cell.rb?label=Version&logo=github)](https://github.com/sashite/cell.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/cell.rb/main)
![Ruby](https://github.com/sashite/cell.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/cell.rb?label=License&logo=github)](https://github.com/sashite/cell.rb/raw/main/LICENSE.md)

> **CELL** (Cell Encoding Location Label) support for the Ruby language.

## What is CELL?

CELL (Cell Encoding Location Label) is a standardized format for representing coordinates on multi-dimensional game boards using a cyclical ASCII character system. CELL supports unlimited dimensional coordinate systems through the systematic repetition of three distinct character sets.

This gem implements the [CELL Specification v1.0.0](https://sashite.dev/documents/cell/1.0.0/), providing a Ruby interface for working with multi-dimensional game coordinates through a clean, functional API.

## Installation

```ruby
# In your Gemfile
gem "sashite-cell"
```

Or install manually:

```sh
gem install sashite-cell
```

## CELL Format

CELL uses a cyclical three-character-set system that repeats indefinitely based on dimensional position:

**Dimension (n % 3 = 1)**: Latin Lowercase Letters
- `a`, `b`, `c`, ..., `z`, `aa`, `ab`, ..., `zz`, `aaa`, ...

**Dimension (n % 3 = 2)**: Arabic Numerals
- `1`, `2`, `3`, ..., `25`, `26`, ...

**Dimension (n % 3 = 0)**: Latin Uppercase Letters
- `A`, `B`, `C`, ..., `Z`, `AA`, `AB`, ..., `ZZ`, `AAA`, ...

## Basic Usage

### Validation

The primary functionality is validating CELL coordinates:

```ruby
require "sashite/cell"

# Check if a string represents a valid CELL coordinate
Sashite::Cell.valid?("a1")     # => true (2D coordinate)
Sashite::Cell.valid?("a1A")    # => true (3D coordinate)
Sashite::Cell.valid?("e4")     # => true (2D coordinate)
Sashite::Cell.valid?("h8Hh8")  # => true (5D coordinate)
Sashite::Cell.valid?("*")      # => false (not a CELL coordinate)
Sashite::Cell.valid?("a0")     # => false (invalid numeral)
Sashite::Cell.valid?("")       # => false (empty string)

# Alias for convenience
Cell = Sashite::Cell
Cell.valid?("a1") # => true
```

### Dimensional Analysis

```ruby
# Get the number of dimensions in a coordinate
Sashite::Cell.dimensions("a1")     # => 2
Sashite::Cell.dimensions("a1A")    # => 3
Sashite::Cell.dimensions("h8Hh8")  # => 5
Sashite::Cell.dimensions("foobar") # => 1

# Parse coordinate into dimensional components
Sashite::Cell.parse("a1A")
# => ["a", "1", "A"]

Sashite::Cell.parse("h8Hh8")
# => ["h", "8", "H", "h", "8"]

Sashite::Cell.parse("foobar")
# => ["foobar"]
```

### Coordinate Conversion

```ruby
# Convert coordinates to arrays of integers (0-indexed)
Sashite::Cell.to_indices("a1")
# => [0, 0]

Sashite::Cell.to_indices("e4")
# => [4, 3]

Sashite::Cell.to_indices("a1A")
# => [0, 0, 0]

# Convert arrays of integers back to CELL coordinates
Sashite::Cell.from_indices(0, 0)
# => "a1"

Sashite::Cell.from_indices(4, 3)
# => "e4"

Sashite::Cell.from_indices(0, 0, 0)
# => "a1A"
```

## Usage Examples

### Chess Board (8x8)

```ruby
# Standard chess notation mapping
chess_squares = %w[a1 b1 c1 d1 e1 f1 g1 h1
                   a2 b2 c2 d2 e2 f2 g2 h2
                   a3 b3 c3 d3 e3 f3 g3 h3
                   a4 b4 c4 d4 e4 f4 g4 h4
                   a5 b5 c5 d5 e5 f5 g5 h5
                   a6 b6 c6 d6 e6 f6 g6 h6
                   a7 b7 c7 d7 e7 f7 g7 h7
                   a8 b8 c8 d8 e8 f8 g8 h8]

chess_squares.all? { |square| Sashite::Cell.valid?(square) }
# => true
```

### Shogi Board (9x9)

```ruby
# Japanese shogi uses 9x9 board
shogi_position = "5e" # 5th file, e rank
Sashite::Cell.valid?(shogi_position) # => true
Sashite::Cell.dimensions(shogi_position) # => 2
Sashite::Cell.to_indices(shogi_position) # => [4, 4]
```

### 3D Tic-Tac-Toe (3x3x3)

```ruby
# Three-dimensional game coordinates
positions_3d = %w[a1A b2B c3C a2B b3C c1A]
positions_3d.all? { |pos| Sashite::Cell.valid?(pos) && Sashite::Cell.dimensions(pos) == 3 }
# => true
```

### Multi-dimensional Coordinates

```ruby
# Higher dimensional coordinates
coord_4d = "a1Aa"
coord_5d = "b2Bb2"

Sashite::Cell.dimensions(coord_4d) # => 4
Sashite::Cell.dimensions(coord_5d) # => 5

# Parse into components
Sashite::Cell.parse(coord_4d) # => ["a", "1", "A", "a"]
Sashite::Cell.parse(coord_5d) # => ["b", "2", "B", "b", "2"]
```

## API Reference

### Module Methods

#### Validation
- `Sashite::Cell.valid?(string)` - Check if string represents a valid CELL coordinate

#### Analysis
- `Sashite::Cell.dimensions(string)` - Get number of dimensions
- `Sashite::Cell.parse(string)` - Parse coordinate into dimensional components array

#### Conversion
- `Sashite::Cell.to_indices(string)` - Convert CELL coordinate to 0-indexed integer array
- `Sashite::Cell.from_indices(*indices)` - Convert splat indices to CELL coordinate

#### Utilities
- `Sashite::Cell.regex` - Get the validation regular expression

### Constants

- `Sashite::Cell::REGEX` - Regular expression for CELL validation: `/\A(?:[a-z]+|[1-9]\d*|[A-Z]+)+\z/`

## Properties of CELL

* **Multi-dimensional**: Supports unlimited dimensional coordinate systems
* **Cyclical**: Uses systematic three-character-set repetition
* **ASCII-based**: Pure ASCII characters for universal compatibility
* **Unambiguous**: Each coordinate maps to exactly one location
* **Scalable**: Extends naturally from 1D to unlimited dimensions
* **Functional**: Provides a clean, stateless API for coordinate operations

## Character Set Details

### Latin Lowercase (Dimensions 1, 4, 7, ...)
Single letters: `a` through `z` (positions 0-25)
Double letters: `aa` through `zz` (positions 26-701)
Triple letters: `aaa` through `zzz` (positions 702-18277)
And so on...

### Arabic Numerals (Dimensions 2, 5, 8, ...)
Standard decimal notation: `1`, `2`, `3`, ... (1-indexed)
No leading zeros, unlimited range

### Latin Uppercase (Dimensions 3, 6, 9, ...)
Single letters: `A` through `Z` (positions 0-25)
Double letters: `AA` through `ZZ` (positions 26-701)
Triple letters: `AAA` through `ZZZ` (positions 702-18277)
And so on...

## Integration with DROP

CELL complements the DROP specification for complete location coverage:

```ruby
# Combined location validation
def valid_game_location?(location)
  Sashite::Cell.valid?(location) || Sashite::Drop.reserve?(location)
end

valid_game_location?("a1")  # => true (board position)
valid_game_location?("*")   # => true (reserve position)
valid_game_location?("$")   # => false (invalid)
```

## Examples in Different Games

### Chess

```ruby
# Standard algebraic notation positions
start_position = "e2"
end_position = "e4"

Sashite::Cell.valid?(start_position) # => true
Sashite::Cell.valid?(end_position)   # => true
```

### Go (19x19)

```ruby
# Go board positions
corner = "a1"       # Corner position
edge = "j1"         # Edge position
tengen = "j10"      # Center point (tengen) on 19x19 board

[corner, edge, tengen].all? { |pos| Sashite::Cell.valid?(pos) }
# => true
```

### Abstract Strategy Games

```ruby
# Multi-dimensional abstract games
hypercube_4d = "a1Aa"
tesseract_pos = "h8Hh8"

# Validate high-dimensional coordinates
Sashite::Cell.valid?(hypercube_4d) # => true
Sashite::Cell.dimensions(tesseract_pos) # => 5
```

## Documentation

- [Official CELL Specification](https://sashite.dev/documents/cell/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/cell.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-cell) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.

# Cell.rb

[![Version](https://img.shields.io/github/v/tag/sashite/cell.rb?label=Version&logo=github)](https://github.com/sashite/cell.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/cell.rb/main)
![Ruby](https://github.com/sashite/cell.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/cell.rb?label=License&logo=github)](https://github.com/sashite/cell.rb/raw/main/LICENSE.md)

> **CELL** (Coordinate Expression Location Label) support for the Ruby language.

## What is CELL?

CELL (Coordinate Expression Location Label) defines a consistent and rule-agnostic format for representing locations in abstract strategy board games. CELL provides a standardized way to identify positions on game boards and pieces held in hand/reserve, establishing a common foundation for location reference across the Sashité notation ecosystem.

This gem implements the [CELL Specification v1.0.0](https://sashite.dev/documents/cell/1.0.0/), providing a Ruby interface for working with game locations through a clean and simple API that serves as a foundational building block for other Sashité specifications.

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

A CELL location is represented by a single string following one of two patterns:

### Board Coordinates

Any non-empty string containing only alphanumeric characters (`a-z`, `A-Z`, `0-9`):

```
e4        # Chess notation
5c        # Shōgi notation
A3a       # 3D coordinate
center    # Custom coordinate
```

### Hand/Reserve Location

The reserved character `*` represents pieces held off-board:
```
*         # Hand/reserve location
```

## Basic Usage

### Creating Location Objects

The primary interface is the `Sashite::Cell::Location` class, which represents a game location in CELL format:

```ruby
require "sashite/cell"

# Parse CELL strings into location objects
board_pos = Sashite::Cell::Location.parse("e4")
# => #<Sashite::Cell::Location:0x... @coordinate="e4">

hand_pos = Sashite::Cell::Location.parse("*")
# => #<Sashite::Cell::Location:0x... @coordinate="*">

# Create directly with constructor
location = Sashite::Cell::Location.new("e4")
hand = Sashite::Cell::Location.new("*")

# Convenience method
location = Sashite::Cell.location("e4")
```

### Converting to CELL String

Convert a location object back to its CELL string representation:

```ruby
location = Sashite::Cell::Location.parse("e4")
location.to_s
# => "e4"

hand = Sashite::Cell::Location.parse("*")
hand.to_s
# => "*"
```

### Checking Location Types

Distinguish between board coordinates and hand/reserve locations:

```ruby
board_loc = Sashite::Cell::Location.parse("e4")
hand_loc = Sashite::Cell::Location.parse("*")

board_loc.board?     # => true
board_loc.hand?      # => false

hand_loc.board?      # => false
hand_loc.hand?       # => true
```

## Game-Specific Examples

### Chess

```ruby
# Standard chess coordinates
locations = %w[a1 e4 h8].map { |coord| Sashite::Cell::Location.parse(coord) }

# Check if valid chess square
def valid_chess_square?(location)
  return false unless location.board?

  coord = location.to_s
  coord.length == 2 &&
    coord[0].between?("a", "h") &&
    coord[1].between?("1", "8")
end

valid_chess_square?(Sashite::Cell::Location.parse("e4"))  # => true
valid_chess_square?(Sashite::Cell::Location.parse("z9"))  # => false
```

### Shōgi

```ruby
# Shōgi board coordinates and hand
board_positions = %w[9a 5e 1i].map { |coord| Sashite::Cell::Location.parse(coord) }
hand_position = Sashite::Cell::Location.parse("*")

# Group by location type
positions = board_positions + [hand_position]
grouped = positions.group_by(&:hand?)
# => {false => [board positions], true => [hand position]}
```

### Go

```ruby
# Go coordinates (traditional notation)
go_positions = %w[A1 T19 K10].map { |coord| Sashite::Cell::Location.parse(coord) }

# Custom validation for Go board
def valid_go_position?(location, board_size = 19)
  return false unless location.board?

  coord = location.to_s
  return false unless [2, 3].include?(coord.length)

  letter = coord[0]
  number = coord[1..].to_i

  letter.between?("A", ("A".ord + board_size - 1).chr) &&
    number.between?(1, board_size)
end
```

### Custom Coordinate Systems

```ruby
# 3D chess coordinates
location_3d = Sashite::Cell::Location.parse("A3a")

# Named locations
center = Sashite::Cell::Location.parse("center")
corner = Sashite::Cell::Location.parse("NE")

# Hexagonal coordinates
hex_coord = Sashite::Cell::Location.parse("Q3R7")
```

## Advanced Usage

### Working with Collections

```ruby
# Mix of board and hand locations
locations = [
  Sashite::Cell::Location.parse("e4"),
  Sashite::Cell::Location.parse("d5"),
  Sashite::Cell::Location.parse("*"),
  Sashite::Cell::Location.parse("a1")
]

# Separate board from hand locations
board_locations = locations.select(&:board?)
hand_locations = locations.select(&:hand?)

# Convert collection to strings
coordinates = locations.map(&:to_s)
# => ["e4", "d5", "*", "a1"]
```

### Game State Representation

```ruby
# Represent piece positions
piece_locations = {
  "white_king"      => Sashite::Cell::Location.parse("e1"),
  "black_king"      => Sashite::Cell::Location.parse("e8"),
  "white_rook"      => Sashite::Cell::Location.parse("a1"),
  "captured_pieces" => Sashite::Cell::Location.parse("*")
}

# Find pieces on specific ranks/files
def pieces_on_file(locations, file)
  locations.select do |piece, location|
    location.board? && location.to_s.start_with?(file)
  end
end

e_file_pieces = pieces_on_file(piece_locations, "e")
```

### Validation and Error Handling

```ruby
# Check validity before parsing
Sashite::Cell.valid?("e4")      # => true
Sashite::Cell.valid?("*")       # => true
Sashite::Cell.valid?("")        # => false
Sashite::Cell.valid?("e-4")     # => false
Sashite::Cell.valid?("@")       # => false

# Safe parsing
def safe_parse(coord_string)
  return nil unless Sashite::Cell.valid?(coord_string)

  Sashite::Cell::Location.parse(coord_string)
rescue ArgumentError
  nil
end

# Invalid coordinates raise ArgumentError
begin
  Sashite::Cell::Location.parse("")
rescue ArgumentError => e
  puts "Invalid coordinate: #{e.message}"
end
```

### Integration with Other Notations

```ruby
# CELL serves as foundation for move notation
class SimpleMove
  def initialize(from, to)
    @from = Sashite::Cell::Location.parse(from)
    @to = Sashite::Cell::Location.parse(to)
  end

  def from_board?
    @from.board?
  end

  def to_board?
    @to.board?
  end

  def drop_move?
    @from.hand? && @to.board?
  end

  def capture_move?
    @from.board? && @to.board?
  end

  def to_s
    "#{@from}→#{@to}"
  end
end

# Usage
move = SimpleMove.new("e4", "e5")    # Normal move
drop = SimpleMove.new("*", "e4")     # Drop from hand
```

## API Reference

### Module Methods

- `Sashite::Cell.valid?(cell_string)` - Check if a string is valid CELL notation
- `Sashite::Cell.location(coordinate)` - Convenience method to create locations

### Sashite::Cell::Location Class Methods

- `Sashite::Cell::Location.parse(cell_string)` - Parse a CELL string into a location object
- `Sashite::Cell::Location.new(coordinate)` - Create a new location instance

### Instance Methods

#### Type Checking
- `#board?` - Check if location represents a board coordinate
- `#hand?` - Check if location represents hand/reserve

#### Conversion
- `#to_s` - Convert to CELL string representation
- `#inspect` - Detailed string representation for debugging

#### Comparison
- `#==` - Compare locations for equality
- `#eql?` - Strict equality comparison
- `#hash` - Hash value for use in collections

## Properties of CELL

* **Rule-agnostic**: CELL does not encode game states, movement rules, or game-specific conditions
* **Universal location identification**: Supports both board positions and hand/reserve areas
* **Canonical representation**: Equivalent locations yield identical strings
* **Arbitrary coordinate systems**: Flexible format supports any alphanumeric coordinate system
* **Foundational specification**: Serves as building block for other Sashité notations

## Constraints

* Board coordinates must contain only alphanumeric characters (`a-z`, `A-Z`, `0-9`)
* Board coordinates must be non-empty strings
* Hand/reserve locations must be exactly the character `*`
* No other characters or formats are permitted

## Use Cases

CELL is particularly useful in the following scenarios:

1. **Move notation systems**: As coordinate foundation for MIN, PMN, and GGN specifications
2. **Game engine development**: When implementing position tracking across different board layouts
3. **Board representation**: When storing piece positions in databases or memory structures
4. **Cross-game compatibility**: When building systems that work with multiple game types
5. **Position analysis**: When comparing locations across different coordinate systems
6. **User interface development**: When translating between display coordinates and logical positions

## Dependencies

This gem has no external dependencies beyond Ruby standard library.

## Specification

- [CELL Specification](https://sashite.dev/documents/cell/1.0.0/)

## Documentation

- [CELL Documentation](https://rubydoc.info/github/sashite/cell.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-cell) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.

#!/usr/bin/env ruby

class Tile
  INITIALS_DIRECTIONS = {
    "e" => :east,
    "se" => :southeast,
    "sw" => :southwest,
    "w" => :west,
    "nw" => :northwest,
    "ne" => :northeast,
  }

  def self.directions
    INITIALS_DIRECTIONS.values
  end

  attr_reader :side

  def initialize
    @side = :white
    @directions_tiles = {}
  end

  def flip
    @side = (@side == :white ? :black : :white)
  end

  def [](direction)
    @directions_tiles[direction]
  end

  def insert_new_tile?(direction)
    return nil if @directions_tiles[direction]

    new_tile = Tile.new
    self[direction] = new_tile

    map_to_counterclockwise_adjacent(new_tile, direction)
    map_to_clockwise_adjacent(new_tile, direction)

    new_tile
  end

  protected
  attr_reader :directions_tiles

  def []=(direction, other)
    self.directions_tiles[direction] = other
    other.directions_tiles[inverse_of(direction)] = self
  end

  private
  def map_to_counterclockwise_adjacent(other, direction)
    adjacent_direction = counterclockwise_from(direction)
    adjacent_to_other_direction = counterclockwise_from(inverse_of(adjacent_direction))
    return if other.directions_tiles[inverse_of(adjacent_to_other_direction)]

    adjacent_tile = @directions_tiles[adjacent_direction]
    return if adjacent_tile.nil?

    adjacent_tile[adjacent_to_other_direction] = other
  end

  def map_to_clockwise_adjacent(other, direction)
    adjacent_direction = clockwise_from(direction)
    adjacent_to_other_direction = clockwise_from(inverse_of(adjacent_direction))
    return if other.directions_tiles[inverse_of(adjacent_to_other_direction)]

    adjacent_tile = @directions_tiles[adjacent_direction]
    return if adjacent_tile.nil?

    adjacent_tile[adjacent_to_other_direction] = other
  end

  def inverse_of(direction)
    Tile.directions[Tile.directions.index(direction) - 3]
  end

  def counterclockwise_from(direction)
    DIRECTIONS_ADJACENTS[direction].first
  end

  def clockwise_from(direction)
    DIRECTIONS_ADJACENTS[direction].last
  end

  DIRECTIONS_ADJACENTS = {
    east: [:northeast, :southeast],
    southeast: [:east, :southwest],
    southwest: [:southeast, :west],
    west: [:southwest, :northwest],
    northwest: [:west, :northeast],
    northeast: [:northwest, :east],
  }
end

class Floor
  @@tiles = []

  def initialize
    @reference_tile = Tile.new
    @@tiles << @reference_tile

    @outer_tiles = [@reference_tile]
  end

  def flip_tile_from_path(path)
    current_tile = @reference_tile

    until path.empty?
      match = path.match(/\A(e|se|sw|w|nw|ne)/)
      direction = Tile::INITIALS_DIRECTIONS[match.captures.first]

      expand if current_tile[direction].nil?
      current_tile = current_tile[direction]

      path = match.post_match
    end

    current_tile.flip
  end

  def expand
    new_outer_tiles = []

    @outer_tiles.each do |outer_tile|
      Tile.directions.each do |direction|
        new_outer_tiles << outer_tile.insert_new_tile?(direction)
      end
    end

    @outer_tiles = new_outer_tiles.compact
    @@tiles += @outer_tiles
  end

  def black_tile_count
    @@tiles.count { |tile| tile.side == :black }
  end
end

floor = Floor.new

File.read("data_tile_paths.txt").split(/\n/).each do |line|
  floor.flip_tile_from_path(line)
end

puts floor.black_tile_count

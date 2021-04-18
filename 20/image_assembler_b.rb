#!/usr/bin/env ruby

class Tilemap
  def initialize(id_tiles)
    @id_tiles = id_tiles
    assemble
  end

  def tile_matrix
    @tilemap.map do |tileline|
      tileline.map { |id| tile(id) }
    end
  end

  private
  def assemble
    first_id = @id_tiles.keys.first
    @tilemap = [[first_id]]

    place_matching_tiles(first_id)
    @id_tiles.values.each(&:strip_border)
  end

  def place_matching_tiles(id)
    tile(id).borders.each do |direction, border|
      next if border_matched?(id, direction)

      matched_id, _ = @id_tiles.except(id).find do |_, tile|
        tile.matchable_borders.any?(border)
      end
      next if matched_id.nil?

      orient_matched_tile(matched_id, border, direction)
      place_matched_tile(id, matched_id, direction)
      place_matching_tiles(matched_id)
    end
  end

  def orient_matched_tile(id, border, direction)
    tile(id).flip if tile(id).border_direction(border.reverse).nil?
    until tile(id).border_direction(border.reverse) == DIRECTION_PAIRS[direction]
      tile(id).rotate
    end
  end

  DIRECTION_PAIRS = {
    top: :bottom,
    bottom: :top,
    left: :right,
    right: :left,
  }

  def place_matched_tile(id, matched_id, direction)
    x, y = adjacent_coords(id, direction)

    case
    when x == -1
      x = 0
      extend_tilemap(:left)
    when x == x_length
      extend_tilemap(:right)
    when y == -1
      y = 0
      extend_tilemap(:top)
    when y == y_length
      extend_tilemap(:bottom)
    end

    @tilemap[y][x] = matched_id
  end

  def border_matched?(id, direction)
    x, y = adjacent_coords(id, direction)

    return false unless (0...x_length).include?(x) && (0...y_length).include?(y)
    !@tilemap[y][x].nil?
  end

  def adjacent_coords(id, direction)
    coords = [nil, nil]
    coords[1] = (0...y_length).find do |y|
      coords[0] = (0...x_length).find do |x|
        @tilemap[y][x] == id
      end
    end

    case direction
    when :top
      coords[1] -= 1
    when :right
      coords[0] += 1
    when :bottom
      coords[1] += 1
    when :left
      coords[0] -= 1
    end

    coords
  end

  def extend_tilemap(direction)
    case direction
    when :top
      @tilemap.prepend(Array.new(x_length))
    when :right
      @tilemap.each { |line| line.append(nil) }
    when :bottom
      @tilemap.append(Array.new(x_length))
    when :left
      @tilemap.each { |line| line.prepend(nil) }
    end
  end

  def tile(id)
    @id_tiles[id]
  end

  def x_length
    @tilemap.first.length
  end

  def y_length
    @tilemap.length
  end
end

class Tile
  def initialize(matrix)
    @matrix = matrix
  end

  def [](i)
    @matrix[i]
  end

  def borders
    {
      top: @matrix.first.dup,
      right: @matrix.map(&:last),
      bottom: @matrix.last.reverse,
      left: @matrix.map(&:first).reverse,
    }
  end

  def border_direction(border)
    borders.key(border)
  end

  def matchable_borders
    borders.values + borders.values.map(&:reverse)
  end

  def rotate
    @matrix = @matrix.transpose.map(&:reverse)
  end

  def flip
    @matrix = @matrix.map(&:reverse)
  end

  def strip_border
    @matrix.shift
    @matrix.pop

    @matrix.each do |line|
      line.shift
      line.pop
    end
  end

  def x_length
    @matrix.first.length
  end

  def y_length
    @matrix.length
  end
end

class Bitmap < Tile
  def initialize(tile_matrix)
    @tile_matrix = tile_matrix
    @matrix = []

    build_matrix
  end

  def count_choppy_water
    total_hash_count = @matrix.flatten.count('#')
    gourdy_hash_count = find_gourdies * GOURDY.flatten.count('#')

    total_hash_count - gourdy_hash_count
  end

  def find_gourdies
    2.times do
      4.times do
        count = gourdy_count
        return count if count > 0

        rotate
      end

      flip
    end
  end

  private
  def build_matrix
    tile_height = @tile_matrix.flatten.first.y_length
    height = @tile_matrix.length * tile_height

    height.times do |i|
      tile_matrix_i = i / tile_height
      tile_line_i = i % tile_height

      matrix_line = @tile_matrix[tile_matrix_i].map do |tile_line|
        tile_line[tile_line_i]
      end.flatten

      @matrix << matrix_line
    end
  end

  GOURDY = [
    "                  # ".chars,
    "#    ##    ##    ###".chars,
    " #  #  #  #  #  #   ".chars,
  ]

  def gourdy_x_length
    GOURDY.first.length
  end

  def gourdy_y_length
    GOURDY.length
  end

  def gourdy_sized_submatrix(x, y)
    gourdy_y_length.times.map do |dY|
      gourdy_x_length.times.map do |dX|
        @matrix[y+dY][x+dX]
      end
    end
  end

  def gourdy_count
    max_init_x = x_length - gourdy_x_length
    max_init_y = y_length - gourdy_y_length

    gourdies = 0
    max_init_y.times do |y|
      max_init_x.times do |x|
        submatrix = gourdy_sized_submatrix(x, y)
        gourdies += 1 if matches_gourdy?(submatrix)
      end
    end

    gourdies
  end

  def matches_gourdy?(matrix)
    gourdy_y_length.times do |y|
      gourdy_x_length.times do |x|
        next if GOURDY[y][x] == " "
        return false unless matrix[y][x] == '#'
      end
    end

    true
  end
end

if __FILE__ == $0
  data = File.read(ARGV[0]).split(/\n\n/)

  id_tiles = data.map do |entry|
    raw_id_matrix = entry.split(/\n/)

    id = raw_id_matrix.first.match(/\ATile (\d{4}):\z/).captures.first
    matrix = raw_id_matrix.drop(1).map(&:chars)
    [id, Tile.new(matrix)]
  end.to_h

  tilemap = Tilemap.new(id_tiles)
  bitmap = Bitmap.new(tilemap.tile_matrix)
  puts bitmap.count_choppy_water
end


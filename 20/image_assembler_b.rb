#!/usr/bin/env ruby

class Matrix
  def initialize(matrix)
    @matrix = matrix
  end

  def [](i)
    @matrix[i]
  end

  def x_length
    @matrix.first.length
  end

  def y_length
    @matrix.length
  end

  def rotate
    @matrix = @matrix.reverse.transpose
  end

  def flip
    @matrix = @matrix.reverse
  end
end

class Tile < Matrix
  def borders
    @borders ||= {
      top: @matrix.first.dup,
      right: @matrix.map(&:last),
      bottom: @matrix.last.reverse,
      left: @matrix.map(&:first).reverse,
    }
  end

  def rotate
    super
    @borders = nil
  end

  def flip
    super
    @borders = nil
  end

  def border_direction(border)
    borders.key(border)
  end

  def matchable_borders
    borders.values + borders.values.map(&:reverse)
  end

  def strip_border
    @matrix.shift
    @matrix.pop

    @matrix.each do |line|
      line.shift
      line.pop
    end
  end
end

class Tilemap < Matrix
  def initialize(tiles)
    assemble(tiles.dup)
  end

  private
  def assemble(unplaced_tiles)
    first_tile = unplaced_tiles.shift
    @matrix = [[first_tile]]

    tile_queue = [first_tile]
    until tile_queue.empty?
      tile = tile_queue.shift
      direction_tiles = find_unplaced_adjacent_tiles(tile, unplaced_tiles)

      direction_tiles.each do |direction, adjacent_tile|
        orient_adjacent_tile(tile, adjacent_tile, direction)
        place_adjacent_tile(tile, adjacent_tile, direction)

        tile_queue << unplaced_tiles.delete(adjacent_tile)
      end
    end

    @matrix.flatten.each(&:strip_border)
  end

  def find_unplaced_adjacent_tiles(tile, unplaced_tiles)
    tile.borders.reduce({}) do |memo, (direction, border)|
      next memo if border_matched?(tile, direction)

      adjacent_tile = unplaced_tiles.find do |matchable_tile|
        matchable_tile.matchable_borders.any?(border)
      end
      next memo unless adjacent_tile

      memo[direction] = adjacent_tile
      memo
    end
  end

  def orient_adjacent_tile(reference_tile, adjacent_tile, direction)
    target_border = reference_tile.borders[direction].reverse
    target_direction = DIRECTION_PAIRS[direction]

    adjacent_tile.flip unless adjacent_tile.borders.values.include?(target_border)
    until adjacent_tile.border_direction(target_border) == target_direction
      adjacent_tile.rotate
    end
  end

  DIRECTION_PAIRS = {
    top: :bottom,
    bottom: :top,
    left: :right,
    right: :left,
  }

  def place_adjacent_tile(reference_tile, adjacent_tile, direction)
    x, y = adjacent_coords(reference_tile, direction)

    unless (0...x_length).include?(x) && (0...y_length).include?(y)
      extend_matrix(direction)
      x, y = [0, x].max, [0, y].max
    end

    @matrix[y][x] = adjacent_tile
  end

  def border_matched?(tile, direction)
    x, y = adjacent_coords(tile, direction)

    return false unless (0...x_length).include?(x) && (0...y_length).include?(y)
    @matrix[y][x]
  end

  def adjacent_coords(reference_tile, direction)
    coords = [nil, nil]
    coords[1] = (0...y_length).find do |y|
      coords[0] = (0...x_length).find do |x|
        @matrix[y][x] == reference_tile
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

  def extend_matrix(direction)
    case direction
    when :top
      @matrix.prepend(Array.new(x_length))
    when :right
      @matrix.each { |line| line.append(nil) }
    when :bottom
      @matrix.append(Array.new(x_length))
    when :left
      @matrix.each { |line| line.prepend(nil) }
    end
  end
end

class Bitmap < Matrix
  def initialize(tilemap)
    @tilemap = tilemap
    build_matrix
  end

  def num_pounds
    @matrix.flatten.count(:"#")
  end

  private
  def build_matrix
    tile_y_length = @tilemap[0][0].y_length
    matrix_y_length = @tilemap.y_length * tile_y_length

    @matrix = matrix_y_length.times.map do |i|
      tilemap_i = i / tile_y_length
      tileline_i = i % tile_y_length

      @tilemap[tilemap_i].map do |tileline|
        tileline[tileline_i]
      end.flatten
    end
  end
end

class MonsterHunter
  def initialize(bitmap)
    @bitmap = bitmap
  end

  def num_choppy_water
    total_pound_count = @bitmap.num_pounds
    gourdy_pound_count = num_gourdies * GOURDY.flatten.count(:"#")

    total_pound_count - gourdy_pound_count
  end

  private
  def num_gourdies
    2.times do
      4.times do
        num = num_gourdies_at_current_orientation
        return num if num > 0

        @bitmap.rotate
      end

      @bitmap.flip
    end
  end

  def num_gourdies_at_current_orientation
    max_init_x = @bitmap.x_length - gourdy_x_length
    max_init_y = @bitmap.y_length - gourdy_y_length

    max_init_y.times.sum do |y|
      max_init_x.times.count do |x|
        submatrix = gourdy_sized_submatrix(x, y)
        matches_gourdy?(submatrix)
      end
    end
  end

  GOURDY = [
    "                  # ".chars.map(&:to_sym),
    "#    ##    ##    ###".chars.map(&:to_sym),
    " #  #  #  #  #  #   ".chars.map(&:to_sym),
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
        @bitmap[y+dY][x+dX]
      end
    end
  end

  def matches_gourdy?(matrix)
    gourdy_y_length.times do |y|
      gourdy_x_length.times do |x|
        next if GOURDY[y][x] == :" "
        return false unless matrix[y][x] == :"#"
      end
    end

    true
  end
end

if __FILE__ == $0
  data = File.read(ARGV[0]).split(/\n\n/)

  tiles = data.map do |entry|
    raw_matrix = entry.split(/\n/)

    matrix = raw_matrix.drop(1).map { |line| line.chars.map(&:to_sym) }
    Tile.new(matrix)
  end

  tilemap = Tilemap.new(tiles)
  bitmap = Bitmap.new(tilemap)
  monster_hunter = MonsterHunter.new(bitmap)
  puts monster_hunter.num_choppy_water
end

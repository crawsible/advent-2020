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
  def initialize(id_tiles)
    @id_tiles = id_tiles
    assemble
  end

  def [](i)
    super(i).map { |id| tile(id) }
  end

  private
  def assemble
    first_id = @id_tiles.keys.first
    @matrix = [[first_id]]

    place_matching_tiles(first_id)
    @id_tiles.values.each(&:strip_border)
  end

  def place_matching_tiles(id)
    tile(id).borders.each do |direction, border|
      next if border_matched?(id, direction)

      matched_id, _ = @id_tiles.except(id).find do |_, tile|
        tile.matchable_borders.any?(border)
      end
      next unless matched_id

      orient_matched_tile(matched_id, border, direction)
      place_matched_tile(id, matched_id, direction)
      place_matching_tiles(matched_id)
    end
  end

  def orient_matched_tile(id, border, direction)
    tile(id).flip unless tile(id).border_direction(border.reverse)
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

    unless (0...x_length).include?(x) && (0...y_length).include?(y)
      extend_matrix(direction)
      x, y = [0, x].max, [0, y].max
    end

    @matrix[y][x] = matched_id
  end

  def border_matched?(id, direction)
    x, y = adjacent_coords(id, direction)

    return false unless (0...x_length).include?(x) && (0...y_length).include?(y)
    @matrix[y][x]
  end

  def adjacent_coords(id, direction)
    coords = [nil, nil]
    coords[1] = (0...y_length).find do |y|
      coords[0] = (0...x_length).find do |x|
        @matrix[y][x] == id
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

  def tile(id)
    @id_tiles[id]
  end
end

class Bitmap < Matrix
  def initialize(tilemap)
    @tilemap = tilemap
    build_matrix
  end

  def count_choppy_water
    total_hash_count = @matrix.flatten.count('#')
    gourdy_hash_count = find_gourdies * GOURDY.flatten.count('#')

    total_hash_count - gourdy_hash_count
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
  bitmap = Bitmap.new(tilemap)
  puts bitmap.count_choppy_water
end


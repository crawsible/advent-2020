#!/usr/bin/env ruby

class Image
  def initialize(id_matrices)
    @id_tiles = id_matrices.map do |id, matrix|
      [id, Tile.new(matrix)]
    end.to_h
  end

  def construct_image
    first_id = @id_tiles.keys.first
    @tilemap = [[first_id]]

    place_matching_tiles(first_id)
  end

  def corner_ids
    [
      @tilemap.first.first,
      @tilemap.first.last,
      @tilemap.last.first,
      @tilemap.last.last,
    ]
  end

  private
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

  def borders
    {
      top: @matrix.first.dup,
      right: @matrix.map(&:last),
      bottom: @matrix.last.reverse,
      left: @matrix.map(&:first).reverse,
    }
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

  def border_direction(border)
    borders.key(border)
  end

end

if __FILE__ == $0
  data = File.read(ARGV[0]).split(/\n\n/)

  id_matrices = data.map do |entry|
    raw_id_matrix = entry.split(/\n/)

    id = raw_id_matrix.first.match(/\ATile (\d{4}):\z/).captures.first
    matrix = raw_id_matrix.drop(1).map(&:chars)
    [id, matrix]
  end.to_h

  image = Image.new(id_matrices)
  image.construct_image

  puts image.corner_ids.reduce(1) { |memo, id| memo * id.to_i }
end


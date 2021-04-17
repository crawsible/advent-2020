#!/usr/bin/env ruby

class Image
  def initialize(id_matrices)
    @id_tiles = id_matrices.map do |id, matrix|
      [id, Tile.new(matrix)]
    end.to_h
  end

  def corner_ids
    id_borders = @id_tiles.map { |id, tile| [id, tile.borders.values] }.to_h

    id_corners = id_borders.select do |id, borders|
      other_borders = id_borders.except(id).values.flatten(1)

      adjacent_count = borders.count do |border|
        other_borders.any? do |other_border|
          border == other_border || border == other_border.reverse
        end
      end

      adjacent_count == 2
    end

    id_corners.keys
  end
end

class Tile
  def initialize(matrix)
    @matrix = matrix
  end

  def borders
    side_borders = {}

    side_borders[:top] = @matrix.first.dup
    side_borders[:right] = @matrix.map(&:last)
    side_borders[:bottom] = @matrix.last.dup
    side_borders[:left] = @matrix.map(&:first)

    side_borders
  end

  def rotate!
    @matrix = @matrix.transpose.map(&:reverse)
  end

  private
  def x_length
    @matrix.first.length
  end

  def y_length
    @matrix.length
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

  puts image.corner_ids.reduce(1) { |memo, id| memo * id.to_i }
end


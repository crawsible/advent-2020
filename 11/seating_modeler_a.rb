#!/usr/bin/env ruby

class SeatLayout
  Coord = Struct.new(:x, :y)

  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def print
    puts @matrix.map(&:join)
  end

  def ==(other)
    return false unless @matrix.length == other.matrix.length && @matrix[0].length == other.matrix[0].length

    (0...@matrix.length).each do |y|
      (0...@matrix[0].length).each do |x|
        return false unless @matrix[y][x] == other.matrix[y][x]
      end
    end

    true
  end

  def next_round
    new_matrix = []

    (0...@matrix.length).each do |y|
      new_row = []

      (0...@matrix[0].length).each do |x|
        coord = Coord.new(x, y)

        case get_value(coord)
        when 'L'
          new_row << (get_adjacent_cell_values(coord).include?('#') ? 'L' : '#')
        when '#'
          new_row << (get_adjacent_cell_values(coord).count('#') >= 4 ? 'L' : '#')
        when '.'
          new_row << '.'
        end
      end

      new_matrix << new_row
    end

    return SeatLayout.new(new_matrix)
  end

  def occupied_seat_count
    @matrix.flatten.count('#')
  end

  private
  def get_adjacent_cell_values(coord)
    adjacent_cell_values = []

    minX, minY = [coord.x - 1, 0].max, [coord.y - 1, 0].max
    maxX, maxY = [coord.x + 1, @matrix[0].length - 1].min, [coord.y + 1, @matrix.length - 1].min

    (minY..maxY).each do |y|
      (minX..maxX).each do |x|
        new_coord = Coord.new(x, y)
        next if new_coord == coord

        adjacent_cell_values << get_value(new_coord)
      end
    end

    adjacent_cell_values
  end

  def get_value(coord)
    @matrix[coord.y][coord.x]
  end
end

matrix = File.read("data_seat_layout.txt").split(/\n/).map(&:chars)
layout = SeatLayout.new(matrix)

loop do
  old_layout = layout
  layout = layout.next_round
  break if old_layout == layout
end

puts layout.occupied_seat_count

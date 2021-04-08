#!/usr/bin/env ruby

class SeatLayout
  attr_reader :height, :width

  def initialize(matrix)
    @matrix = matrix
    @height, @width = @matrix.length, @matrix.first.length
  end

  def ==(other)
    return false unless @height == other.height && @width == other.width

    (0...@height).each do |row|
      (0...@width).each do |col|
        return false unless self[row][col] == other[row][col]
      end
    end

    true
  end

  def steady_state_layout
    new_layout = next_round
    return self == new_layout ? new_layout : new_layout.steady_state_layout
  end

  def occupied_seat_count
    @matrix.flatten.count('#')
  end

  protected
  def [](row)
    return @matrix[row]
  end

  private
  def next_round
    new_matrix = []

    (0...@height).each do |row|
      new_row = []

      (0...@width).each do |col|
        cell = self[row][col]
        case cell
        when 'L'
          new_row << (get_visible_values(row, col).include?('#') ? 'L' : '#')
        when '#'
          new_row << (get_visible_values(row, col).count('#') >= 5 ? 'L' : '#')
        when '.'
          new_row << '.'
        end
      end

      new_matrix << new_row
    end

    return SeatLayout.new(new_matrix)
  end

  def get_visible_values(row, col)
    visible_values = []

    directions = []
    (-1..1).each do |d_row|
      (-1..1).each do |d_col|
        next if [d_row, d_col] == [0, 0]
        visible_values << find_chair(row, col, d_row, d_col)
      end
    end

    visible_values.compact
  end

  def find_chair(row, col, d_row, d_col)
    newRow = row + d_row
    newCol = col + d_col

    return nil if !(0...@height).include?(newRow)
    return nil if !(0...@width).include?(newCol)

    cell = self[newRow][newCol]
    return ['L', '#'].include?(cell) ? cell : find_chair(newRow, newCol, d_row, d_col)
  end
end

matrix = File.read("data_seat_layout.txt").split(/\n/).map(&:chars)
layout = SeatLayout.new(matrix)
steady_layout = layout.steady_state_layout

puts steady_layout.occupied_seat_count

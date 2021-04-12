#!/usr/bin/env ruby

class Dimension
  def initialize(space)
    @space = space
  end

  def round
    expand_space
    next_space = Array.new(z_length) { Array.new(y_length) { Array.new(x_length) } }

    (0...x_length).each do |x|
      (0...y_length).each do |y|
        (0...z_length).each do |z|
          next_point = nil
          case space[z][y][x]
          when '#'
            next_point = (2..3).cover?(neighbors(x: x, y: y, z: z).count('#')) ? '#' : '.'
          when '.'
            next_point = neighbors(x: x, y: y, z: z).count('#') == 3 ? '#' : '.'
          end

          next_space[z][y][x] = next_point
        end
      end
    end

    @space = next_space
  end

  def active_count
    space.flatten.count('#')
  end

  private
  attr_reader :space

  def neighbors(x:, y:, z:)
    neighbors = []
    (x-1..x+1).each do |nX|
      (y-1..y+1).each do |nY|
        (z-1..z+1).each do |nZ|
          next if x == nX && y == nY && z == nZ
          next if !(0...x_length).cover?(nX) || !(0...y_length).cover?(nY) || !(0...z_length).cover?(nZ)

          neighbors << space[nZ][nY][nX]
        end
      end
    end

    neighbors
  end

  def x_length
    space.first.first.length
  end

  def y_length
    space.first.length
  end

  def z_length
    space.length
  end

  def expand_space
    space.flatten(1).each do |line|
      line.prepend(inactive_point)
      line.append(inactive_point)
    end

    space.each do |plane|
      plane.prepend(inactive_line)
      plane.append(inactive_line)
    end

    space.prepend(inactive_plane)
    space.append(inactive_plane)
  end

  def inactive_point
    '.'
  end

  def inactive_line
    Array.new(x_length, inactive_point)
  end

  def inactive_plane
    Array.new(y_length, inactive_line)
  end
end

initial_space = [File.read('data_initial_plane.txt').split(/\n/).map(&:chars)]

dimension = Dimension.new(initial_space)
6.times { dimension.round }
puts dimension.active_count

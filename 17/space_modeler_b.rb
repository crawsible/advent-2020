#!/usr/bin/env ruby

class Dimension
  def initialize(hyperspace)
    @hyperspace = hyperspace
  end

  def round
    expand_hyperspace
    next_hyperspace = Array.new(w_length) { Array.new(z_length) { Array.new(y_length) { Array.new(x_length) } } }

    (0...x_length).each do |x|
      (0...y_length).each do |y|
        (0...z_length).each do |z|
          (0...w_length).each do |w|
            next_point = nil
            case hyperspace[w][z][y][x]
            when '#'
              next_point = (2..3).cover?(neighbors(x: x, y: y, z: z, w: w).count('#')) ? '#' : '.'
            when '.'
              next_point = neighbors(x: x, y: y, z: z, w: w).count('#') == 3 ? '#' : '.'
            end

            next_hyperspace[w][z][y][x] = next_point
          end
        end
      end
    end

    @hyperspace = next_hyperspace
  end

  def active_count
    hyperspace.flatten.count('#')
  end

  private
  attr_reader :hyperspace

  def neighbors(x:, y:, z:, w:)
    neighbors = []
    (x-1..x+1).each do |nX|
      (y-1..y+1).each do |nY|
        (z-1..z+1).each do |nZ|
          (w-1..w+1).each do |nW|
            next if x == nX && y == nY && z == nZ && w == nW
            next if !(0...x_length).cover?(nX) || !(0...y_length).cover?(nY) || !(0...z_length).cover?(nZ) || !(0...w_length).cover?(nW)

            neighbors << hyperspace[nW][nZ][nY][nX]
          end
        end
      end
    end

    neighbors
  end

  def x_length
    hyperspace.first.first.first.length
  end

  def y_length
    hyperspace.first.first.length
  end

  def z_length
    hyperspace.first.length
  end

  def w_length
    hyperspace.length
  end

  def expand_hyperspace
    hyperspace.flatten(2).each do |line|
      line.prepend(inactive_point)
      line.append(inactive_point)
    end
    hyperspace.flatten(1).each do |plane|
      plane.prepend(inactive_line)
      plane.append(inactive_line)
    end

    hyperspace.each do |space|
      space.prepend(inactive_plane)
      space.append(inactive_plane)
    end

    hyperspace.prepend(inactive_space)
    hyperspace.append(inactive_space)
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

  def inactive_space
    Array.new(z_length, inactive_plane)
  end
end

initial_hyperspace = [[File.read('data_initial_plane.txt').split(/\n/).map(&:chars)]]

dimension = Dimension.new(initial_hyperspace)
6.times { dimension.round }
puts dimension.active_count

#!/usr/bin/env ruby

class Forest
  def initialize(matrix)
    @matrix = matrix
    @width = matrix[0].length
  end

  def trees_for_route(right, down)
    x = 0
    y = 0

    tree_count = 0
    while y < @matrix.length
      tree_count += 1 if @matrix[y][x] == '#'

      x = (x + right) % @width
      y += down
    end

    tree_count
  end
end

tree_matrix = []
File.open("tree_layout.txt").each do |line|
  tree_matrix << line.chomp
end
forest = Forest.new(tree_matrix)

product = forest.trees_for_route(1, 1)
product *= forest.trees_for_route(3, 1)
product *= forest.trees_for_route(5, 1)
product *= forest.trees_for_route(7, 1)
product *= forest.trees_for_route(1, 2)

puts product

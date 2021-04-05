#!/usr/bin/env ruby

x = 0
tree_count = 0

File.open("tree_layout.txt").each do |line|
  row = line.chomp
  tree_count += 1 if row[x] == '#'
  x = (x + 3) % row.length
end

puts tree_count

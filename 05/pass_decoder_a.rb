#!/usr/bin/env ruby

max_id = 0

File.open("data_passes.txt").each do |line|
  row_bin = line[0, 7].chars.reverse
  column_bin = line[7, 3].chars.reverse

  row = 0
  row_bin.each_with_index do |bit, i|
    next if bit == "F"
    row += 2 ** i
  end

  column = 0
  column_bin.each_with_index do |bit, i|
    next if bit == "L"
    column += 2 ** i
  end

  max_id = [max_id, (row * 8) + column].max
end

puts max_id

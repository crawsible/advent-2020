#!/usr/bin/env ruby

seat_ids = []

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

  seat_ids << (row * 8) + column
end

remaining_seats = (seat_ids.min..seat_ids.max).to_a - seat_ids
puts remaining_seats.first

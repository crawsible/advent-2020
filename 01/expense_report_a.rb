#!/usr/bin/env ruby

items = []
matching_pair = []

File.open("report_items.txt").each do |line|
  new_item = line.to_i

  items.each do |item|
    if new_item + item == 2020
      matching_pair << item
      matching_pair << new_item

      break
    end
  end

  break if matching_pair.count == 2
  items << new_item
end

puts "#{matching_pair[0] * matching_pair[1]}"

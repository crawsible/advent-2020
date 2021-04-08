#!/usr/bin/env ruby

items = []
matching_triplet = []

File.open("report_items.txt").each do |line|
  new_item = line.to_i

  items.each_with_index do |item1, i|
    items.drop(i+1).each do |item2|
      if new_item + item1 + item2 == 2020
        matching_triplet << item1
        matching_triplet << item2
        matching_triplet << new_item

        break
      end

      break if !matching_triplet.empty?
    end
  end

  break if !matching_triplet.empty?
  items << new_item
end

puts "#{matching_triplet[0] * matching_triplet[1] * matching_triplet[2]}"

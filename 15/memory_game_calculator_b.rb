#!/usr/bin/env ruby

starting_numbers = File.read('data_starting_numbers.txt').split(',').map(&:to_i)


number_last_indices = {}
last_number = starting_numbers.first
current_number = nil

(1...30000000).each do |i|
  if starting_numbers.length > i
    current_number = starting_numbers[i]
  elsif number_last_indices.has_key?(last_number)
    current_number = (i - 1) - number_last_indices[last_number]
  else
    current_number = 0
  end

  number_last_indices[last_number] = i - 1
  last_number = current_number
end

puts current_number

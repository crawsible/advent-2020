#!/usr/bin/env ruby

numbers = File.read('data_starting_numbers.txt').split(',').map(&:to_i).reverse

until numbers.length == 2020
  if numbers.drop(1).include?(numbers.first)
    numbers.prepend(numbers.drop(1).index(numbers.first) + 1)
  else
    numbers.prepend(0)
  end
end

p numbers.reverse[0, 100]
puts numbers.first

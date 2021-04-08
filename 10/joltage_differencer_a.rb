#!/usr/bin/env ruby

adapters = File.read("data_joltage_adapters.txt").split(/\n/).map(&:to_i)

adapters << 0
adapters << adapters.max + 3
adapters.sort!

difference_counts = Hash.new(0)
(1...adapters.count).each do |i|
  difference = adapters[i] - adapters[i-1]
  difference_counts[difference] += 1
end

puts difference_counts[1] * difference_counts[3]

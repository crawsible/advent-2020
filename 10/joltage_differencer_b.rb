#!/usr/bin/env ruby

adapters = File.read("data_joltage_adapters.txt").split(/\n/).map(&:to_i)

adapters << 0
adapters << adapters.max + 3
adapters.sort!

path_counts = Hash.new(0)
path_counts[0] = 1
(1...adapters.count).each do |i|
  adapter = adapters[i]
  adapters.take(i).last(3).each do |prev|
    next if prev < adapter - 3
    path_counts[adapter] += path_counts[prev]
  end
end

puts path_counts[adapters.max]

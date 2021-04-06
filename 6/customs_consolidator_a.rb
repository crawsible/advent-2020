#!/usr/bin/env ruby

data = File.read("data_customs_groups.txt")

groups = []
data.split(/\n\n/).each do |group|
  groups << group.split()
end

yes_count = 0
groups.each do |group|
  yes_count += group.map(&:chars).flatten.uniq.count
end

puts yes_count

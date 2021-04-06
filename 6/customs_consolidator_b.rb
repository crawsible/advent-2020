#!/usr/bin/env ruby

data = File.read("data_customs_groups.txt")

groups = []
data.split(/\n\n/).each do |group|
  groups << group.split()
end

yes_count = 0
groups.each do |group|
  group[0].chars.each do |char|
    yes_count += 1 if group.drop(1).all? { |person| person.include?(char) }
  end
end

puts yes_count

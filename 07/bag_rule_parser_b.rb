#!/usr/bin/env ruby

class Bag
  attr_accessor :inner_bag_counts

  def initialize
    @inner_bag_counts = {}
  end

  def add_inner_bag(bag_name, count)
    inner_bag_counts[Bag.find_or_create(bag_name)] = count
  end

  def contained_bags
    sum = 0
    inner_bag_counts.each do |inner_bag, count|
      sum += (inner_bag.contained_bags + 1) * count
    end

    sum
  end

  @@name_bags = {}
  def self.find_or_create(name)
    @@name_bags[name] ||= Bag.new()
  end
end


File.open("data_bag_rules.txt").each do |line|
  matchData = line.chomp.match(/\A(.+) contain (.+)\.\z/)

  outer_bag_name = matchData[1].match(/\A(\w+ \w+) bags\z/)[1]
  outer_bag = Bag.find_or_create(outer_bag_name)

  next if matchData[2] == "no other bags"
  matchData[2].split(", ").each do |entry|
    subMatchData = entry.match(/\A(\d+) (\w+ \w+) bags?\z/)
    outer_bag.add_inner_bag(subMatchData[2], subMatchData[1].to_i)
  end
end

puts Bag.find_or_create("shiny gold").contained_bags

#!/usr/bin/env ruby

def find_containers(bag, bag_containers, all_containers = [])
  bag_containers[bag].each do |container|
    next if all_containers.include?(container)

    all_containers << container
    find_containers(container, bag_containers, all_containers)
  end

  all_containers
end

bag_containers = Hash.new { [] }
File.open("data_bag_rules.txt").each do |line|
  matchData = line.chomp.match(/\A(.+) contain (.+)\.\z/)
  next if matchData[2] == "no other bags"

  container = matchData[1].match(/\A(\w+ \w+) bags\z/)[1]

  matchData[2].split(", ").each do |entry|
    bag = entry.match(/\A\d+ (\w+ \w+) bags?\z/)[1]
    bag_containers[bag] += [container]
  end
end

puts find_containers("shiny gold", bag_containers).count

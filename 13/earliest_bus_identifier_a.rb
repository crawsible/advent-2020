#!/usr/bin/env ruby

data = File.read("data_bus_notes.txt").split(/\n/)

ideal_departure = data[0].to_i

departure_buses = Hash.new([])
data[1].split(",").filter { |el| el != "x" }.map(&:to_i).each do |id|
  departure = 0
  while departure < ideal_departure
    departure += id
  end

  departure_buses[departure] += [id]
end

earliest_departure = departure_buses.keys.min
earliest_bus = departure_buses[earliest_departure].first

puts earliest_bus * (earliest_departure - ideal_departure)

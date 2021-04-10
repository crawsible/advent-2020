#!/usr/bin/env ruby

data = File.read("data_bus_notes.txt").split(/\n/)

t = 0
repetition_period = 0

data[1].split(",").each_with_index do |id, i|
  next if id == "x"
  id = id.to_i

  addl_minutes = i
  until (t + addl_minutes) % id == 0
    t += repetition_period
  end

  repetition_period = repetition_period.zero? ? id : repetition_period.lcm(id)
end

puts t

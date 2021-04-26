#!/usr/bin/env ruby

DIVISOR = 20201227

def transform_subject_number(loop_size, subject_number)
  value = 1
  loop_size.times do
    value = iterate_transformation(value, subject_number)
  end

  value
end

def iterate_transformation(value, subject_number)
  return value * subject_number % DIVISOR
end

def identify_loop_size
  loop_size = 1

  key = iterate_transformation(1, 7)
  until key == 20175123
    key = iterate_transformation(key, 7)
    loop_size += 1
  end

  loop_size
end

puts transform_subject_number(identify_loop_size, 1526110)

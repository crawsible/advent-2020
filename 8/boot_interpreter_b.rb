#!/usr/bin/env ruby

def test_bootcode(bootcode)
  acc = 0
  i = 0

  completed_instructions = []
  while true
    completed_instructions << i
    operation, argument = bootcode[i]

    case operation
    when "acc"
      acc += argument.to_i
      i += 1
    when "jmp"
      i += argument.to_i
    when "nop"
      i += 1
    end

    return [false, acc] if completed_instructions.include?(i)
    return [true, acc] if i >= bootcode.length
  end
end

initial_bootcode = File.read("data_boot_code.txt").split(/\n/).map do |line|
  line.match(/\A(acc|jmp|nop) (.+)\z/)[1, 2]
end

acc = 0
(0...initial_bootcode.length).each do |i|
  bootcode_copy = initial_bootcode.clone
  case bootcode_copy[i][0]
  when "acc"
    next
  when "jmp"
    bootcode_copy[i] = ["nop", bootcode_copy[i][1]]
  when "nop"
    bootcode_copy[i] = ["jmp", bootcode_copy[i][1]]
  end

  completed, acc = test_bootcode(bootcode_copy)
  break if completed
end

puts acc

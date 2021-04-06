#!/usr/bin/env ruby

acc = 0
i = 0

boot_code = File.read("data_boot_code.txt").split(/\n/)

completed_instructions = []

until completed_instructions.include?(i)
  completed_instructions << i
  operation, argument = boot_code[i].match(/\A(acc|jmp|nop) (.+)\z/)[1, 2]

  case operation
  when "acc"
    acc += argument.to_i
    i += 1
  when "jmp"
    i += argument.to_i
  when "nop"
    i += 1
  end
end

puts acc

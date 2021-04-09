#!/usr/bin/env ruby

class Ship
  @@clockwise_order = ["E", "S", "W", "N"]

  attr_reader :location

  def initialize
    @location = [0, 0]
    @heading_index = 0
  end

  def execute_all(instructions)
    instructions.each { |instruction| execute(instruction) }
  end

  def execute(instruction)
    case instruction.action
    when /[LR]/
      rotate(instruction.action, instruction.value)
    when /[ESWN]/
      move(instruction.action, instruction.value)
    when "F"
      move(heading, instruction.value)
    end
  end

  private
  def heading
    @@clockwise_order[@heading_index]
  end

  def rotate(direction, value)
    value = -value if direction == "L"
    @heading_index = (@heading_index + (value / 90)) % 4
  end

  def move(direction, value)
    coord_index = "EW".include?(direction) ? 0 : 1
    value = -value if "SW".include?(direction)

    @location[coord_index] += value
  end
end

Instruction = Struct.new(:action, :value)

instructions = File.read("data_navigation_instructions.txt").split(/\n/).map do |line|
  Instruction.new(line[0], line[1...line.length].to_i)
end

ship = Ship.new
ship.execute_all(instructions)
puts ship.location.reduce(0) { |sum, n| sum + n.abs }

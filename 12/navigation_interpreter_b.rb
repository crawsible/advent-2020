#!/usr/bin/env ruby

class Ship
  attr_reader :location

  def initialize
    @location = [0, 0]
    @waypoint = [10, 1]
  end

  def execute_all(instructions)
    instructions.each { |instruction| execute(instruction) }
  end

  def execute(instruction)
    case instruction.action
    when /[LR]/
      waypoint_rotate(instruction.action, instruction.value)
    when /[ESWN]/
      waypoint_move(instruction.action, instruction.value)
    when "F"
      move(instruction.value)
    end
  end

  private
  def waypoint_rotate(direction, value)
    quarter_rotations = value / 90
    quarter_rotations = -quarter_rotations % 4 if direction == "L"

    quarter_rotations.times do
      @waypoint = [@waypoint[1], -@waypoint[0]]
    end
  end

  def waypoint_move(direction, value)
    coord_index = "EW".include?(direction) ? 0 : 1
    value = -value if "SW".include?(direction)

    @waypoint[coord_index] += value
  end

  def move(value)
    value.times do
      @location[0] += @waypoint[0]
      @location[1] += @waypoint[1]
    end
  end
end

Instruction = Struct.new(:action, :value)

instructions = File.read("data_navigation_instructions.txt").split(/\n/).map do |line|
  Instruction.new(line[0], line[1...line.length].to_i)
end

ship = Ship.new
ship.execute_all(instructions)
puts ship.location.reduce(0) { |sum, n| sum + n.abs }

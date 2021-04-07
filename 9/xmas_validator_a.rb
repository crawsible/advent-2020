#!/usr/bin/env ruby

class XmasValidator
  def initialize
    @stream = []
  end

  def input(value)
    return false if !valid_next_number?(value)
    add_to_stream(value)
  end

  private
  def valid_next_number?(value)
    return true if @stream.length < 25

    @stream.each_with_index do |num1, i|
      next if num1 > value

      @stream.drop(i + 1).each do |num2|
        return true if num1 + num2 == value
      end
    end

    false
  end

  def add_to_stream(value)
    @stream << value
    @stream = @stream.last(25)
  end
end

validator = XmasValidator.new()
invalid_number = nil

File.open("data_xmas_stream.txt").each do |line|
  num = line.to_i
  if !validator.input(num)
    puts num
    break
  end
end

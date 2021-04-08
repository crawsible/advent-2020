#!/usr/bin/env ruby

class XmasBreaker
  def initialize(data)
    @data = data
  end

  def encryption_weakness
    target = first_invalid_number
    find_contiguous_sum(target)
  end

  private
  def first_invalid_number
    (25...@data.length).each do |i|
      num = @data[i]
      return num if !valid_number?(num, @data[i-25...i])
    end
  end

  def valid_number?(num, precedents)
    precedents.each_with_index do |pre1, i|
      precedents.drop(i+1).each do |pre2|
        return true if pre1 + pre2 == num
      end
    end

    false
  end

  def find_contiguous_sum(value)
    (0...@data.length).each do |i|
      contiguous_numbers = []
      sum = 0

      @data.drop(i).each do |num|
        contiguous_numbers << num
        sum += num
        break if sum > value
        return contiguous_numbers.min + contiguous_numbers.max if sum == value
      end
    end
  end
end

data = File.read("data_xmas_stream.txt").split(/\n/).map(&:to_i)

breaker = XmasBreaker.new(data)
puts breaker.encryption_weakness




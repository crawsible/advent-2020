#!/usr/bin/env ruby

class BitmaskArray
  attr_accessor :mask

  def initialize
    @mem = {}
    @mask = "X" * 36
  end

  def []=(address, value)
    floating_address = apply_mask(to_binary(address))
    resolve_floating_bits(floating_address).each do |address|
      @mem[address] = value
    end
  end

  def sum
    @mem.values.sum
  end

  private
  def apply_mask(binary)
    @mask.chars.each_with_index.reduce("") do |new_binary, (mask_bit, i)|
      new_binary + (mask_bit == "0" ? binary[i] : mask_bit)
    end
  end

  def resolve_floating_bits(binary)
    queue = [binary]

    while queue.first.include?("X")
      floating = queue.shift
      i = floating.index("X")

      resolve0, resolve1 = floating.dup, floating.dup
      resolve0[i], resolve1[i] = "0", "1"

      queue << resolve0
      queue << resolve1
    end

    queue
  end

  def to_binary(int)
    36.times.reduce("") do |binary, i|
      bit = int / (2 ** i) % 2
      bit.to_s + binary
    end
  end

  def to_int(binary)
    binary.chars.map(&:to_i).reverse.each_with_index.reduce(0) do |int, (bit, i)|
      2 ** i * bit + int
    end
  end
end

bitmask_array = BitmaskArray.new

File.open("data_init_program.txt").each do |line|
  case line
  when /\Amem/
    i, value = line.match(/\Amem\[(\d+)\] = (\d+)/).captures
    bitmask_array[i.to_i] = value.to_i
  when /\Amask/
    mask = line.match(/\Amask = ([01X]+)/).captures.first
    bitmask_array.mask = mask
  end
end

puts bitmask_array.sum

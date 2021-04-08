#!/usr/bin/env ruby

class Passport
  @@field_keys = [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]

  def initialize(entry)
    @present_fields = []

    entry.split.each do |field|
      @present_fields << field.match(/(\w{3}):\S+/)[1].to_sym
    end
  end

  def valid?
    (@@field_keys - @present_fields).empty?
  end
end

data = File.read("data_passports.txt")

passports = []
data.split(/\n\n/).each do |entry|
  passports << Passport.new(entry)
end

puts passports.count(&:valid?)

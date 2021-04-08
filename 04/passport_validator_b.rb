#!/usr/bin/env ruby

class Passport
  @@field_keys = [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]

  def initialize(entry)
    @fields = {}

    entry.split.each do |field|
      matchData = field.match(/(\w{3}):(\S+)/)
      @fields[matchData[1].to_sym] = matchData[2]
    end
  end

  def valid?
    return false if !(@@field_keys - @fields.keys).empty?
    valid_byr? && valid_iyr? && valid_eyr? && valid_hgt? && valid_hcl? && valid_ecl? && valid_pid?
  end

  def valid_byr?
    self.class.year_in_range?(@fields[:byr], 1920, 2002)
  end

  def valid_iyr?
    self.class.year_in_range?(@fields[:iyr], 2010, 2020)
  end

  def valid_eyr?
    self.class.year_in_range?(@fields[:eyr], 2020, 2030)
  end

  def valid_hgt?
    matchData = @fields[:hgt].match(/\A(\d{2,3})(cm|in)\z/)
    return false if matchData.nil?

    height = matchData[1].to_i
    min = (matchData[2] == "cm" ? 150 : 59)
    max = (matchData[2] == "cm" ? 193 : 76)
    height >= min && height <= max
  end

  def valid_hcl?
    return false if @fields[:hcl].match(/\A#[0-9a-f]{6}\z/).nil?
    true
  end


  def valid_ecl?
    ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].include?(@fields[:ecl])
  end

  def valid_pid?
    return false if @fields[:pid].match(/\A\d{9}\z/).nil?
    true
  end

  def self.year_in_range?(str, earliest, latest)
    return false if str.match(/\A(\d{4})\z/).nil?
    year = str.to_i

    year >= earliest && year <= latest
  end

end

data = File.read("data_passports.txt")

passports = []
data.split(/\n\n/).each do |entry|
  passports << Passport.new(entry)
end

puts passports.count(&:valid?)

#!/usr/bin/env ruby

class Rule
  def initialize(min, max, letter)
    @min = min
    @max = max
    @letter = letter
  end

  def pass?(password)
    occurrences = password.count(@letter)
    @min <= occurrences && occurrences <= @max ? true : false
  end
end

num_compliant_passwords = 0

File.open("password_db.txt").each do |line|
  entry = line.match(/(\d+)-(\d+) (\w): (\w+)/)
  rule = Rule.new(entry[1].to_i, entry[2].to_i, entry[3])
  password = entry[4]

  num_compliant_passwords += 1 if rule.pass?(password)
end

puts num_compliant_passwords

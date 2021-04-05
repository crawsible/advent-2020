#!/usr/bin/env ruby

class Rule
  def initialize(i, j, letter)
    @i = i - 1
    @j = j - 1
    @letter = letter
  end

  def pass?(password)
    occurrences = (password[@i] + password[@j]).count(@letter)
    occurrences == 1 ? true : false
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

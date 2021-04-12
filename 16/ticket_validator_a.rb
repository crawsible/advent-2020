#!/usr/bin/env ruby

class TicketValidator
  def initialize(field_rules)
    @field_rules = field_rules
  end

  def find_invalid_values(tickets)
    invalid_values = []

    tickets.flatten.each do |value|
      next if valid_ranges.any? { |range| range.cover?(value) }
      invalid_values << value
    end

    invalid_values
  end

  private
  def valid_ranges
    @field_rules.values.flatten
  end
end

data = File.read('data_ticket_notes.txt').split(/\n\n/)

field_rule_matcher = /\A(.+): (\d+)-(\d+) or (\d+)-(\d+)\z/
field_rules = data[0].split(/\n/).reduce({}) do |memo, line|
  field, min0, max0, min1, max1 = line.match(field_rule_matcher).captures
  memo[field] = [(min0.to_i..max0.to_i), (min1.to_i..max1.to_i)]
  memo
end

validator = TicketValidator.new(field_rules)

tickets = data[2].split(/\n/).drop(1).map { |line| line.split(',').map(&:to_i) }
puts validator.find_invalid_values(tickets).sum

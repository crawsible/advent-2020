#!/usr/bin/env ruby

class TicketValidator
  def initialize(field_ranges)
    @field_ranges = field_ranges
    @field_indices = {}
  end

  def valid?(ticket)
    ticket.each do |value|
      next if valid_ranges.any? { |range| range.cover?(value) }
      return false
    end

    true
  end

  def map_fields_to_indices(tickets)
    field_valid_indices = @field_ranges.keys.reduce({}) do |memo, field|
      memo[field] = valid_indices_for_field(tickets, field)
      memo
    end

    until field_valid_indices.empty?
      field, valid_indices = field_valid_indices.find { |_, indices| indices.one? }
      matching_index = valid_indices.first

      @field_indices[field] = matching_index
      field_valid_indices.delete(field)
      field_valid_indices.values.each { |indices| indices.delete(matching_index) }
    end
  end

  def departure_values(ticket)
    departure_indices = @field_indices.select do |field, i|
      field.include?("departure")
    end.map(&:last)

    departure_values = departure_indices.map { |i| ticket[i] }
  end

  private
  def valid_ranges
    @field_ranges.values.flatten
  end

  def valid_indices_for_field(tickets, field)
    range0, range1 = @field_ranges[field]

    (0...tickets.first.length).select do |i|
      tickets.all? do |ticket|
        range0.cover?(ticket[i]) || range1.cover?(ticket[i])
      end
    end
  end
end

data = File.read('data_ticket_notes.txt').split(/\n\n/)

field_rule_matcher = /\A(.+): (\d+)-(\d+) or (\d+)-(\d+)\z/
field_ranges = data[0].split(/\n/).reduce({}) do |memo, line|
  field, min0, max0, min1, max1 = line.match(field_rule_matcher).captures
  memo[field] = [(min0.to_i..max0.to_i), (min1.to_i..max1.to_i)]
  memo
end

validator = TicketValidator.new(field_ranges)

nearby_tickets = data[2].split(/\n/).drop(1).map { |line| line.split(',').map(&:to_i) }
valid_tickets = nearby_tickets.select { |ticket| validator.valid?(ticket) }
validator.map_fields_to_indices(valid_tickets)

my_ticket = data[1].split(/\n/)[1].split(',').map(&:to_i)
departure_values = validator.departure_values(my_ticket)

puts departure_values.reduce { |memo, value| memo * value }

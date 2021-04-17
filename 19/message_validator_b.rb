#!/usr/bin/env ruby

class Validator
  def initialize(rules)
    @rules = rules
  end

  def resolve_rules
    @rules.each do |id, _|
      resolve_id(id)
    end
  end

  def matches_zero?(message)
    fortytwo = @rules["42"]
    thirtyone = @rules["31"]
    return false unless message.match(/\A(#{fortytwo})+(#{thirtyone})+\z/)

    fortytwo_matches = message.match(/\A(?:#{fortytwo})+/)
    fortytwo_count = fortytwo_matches[0].scan(/#{fortytwo}/).count

    thirtyone_matches = fortytwo_matches.post_match.match(/\A(#{thirtyone})+\z/)
    thirtyone_count = thirtyone_matches[0].scan(/#{thirtyone}/).count

    fortytwo_count > thirtyone_count
  end

  # THIS SHOULD WORK BUT DOES NOT >:(
  #def matches_zero?(message)
    #eight_rule = "(#{@rules["42"]})+"
    #eleven_rule = "(?<eleven>(#{@rules["42"]})\\g<eleven>*(#{@rules["31"]}))"

    #!message.match(/\A(#{eight_rule})(#{eleven_rule})\z/).nil?
  #end

  private
  def resolve_id(id)
    return @rules[id] if rule_resolved?(@rules[id])
    @rules[id] = resolve_rule(@rules[id]).delete(' ')
  end

  def rule_resolved?(rule)
    rule.match(/(\d|")/).nil?
  end

  def resolve_rule(rule)
    rule = rule.strip
    return rule if rule_resolved?(rule)

    case rule
    when /\|/
      left, right = rule.match(/(.+) \| (.+)/).captures
      "(#{resolve_rule(left)}|#{resolve_rule(right)})"
    when /\d+/
      parse_references(rule)
    when /"/
      rule.match(/"([ab])"/).captures.first
    end
  end

  def parse_references(rule)
    resolved_rule = ""
    rule.split.each do |reference|
      @rules[reference] = resolve_id(reference)
      resolved_rule += @rules[reference]
    end

    resolved_rule
  end
end

data = File.read('./data_rules_and_messages.txt').split(/\n\n/)

rules = data[0].split(/\n/).map do |line|
  id, rule = line.match(/(\d+): (.+)/).captures
end.to_h

validator = Validator.new(rules)
validator.resolve_rules

count = data[1].split(/\n/).count do |message|
  validator.matches_zero?(message)
end

puts count

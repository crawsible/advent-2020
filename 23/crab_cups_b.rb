#!/usr/bin/env ruby

Cup = Struct.new(:label, :previous_cup, :next_cup)

class CupTable
  def initialize(labels)
    construct_table(labels)
  end

  def cup_for_label(label)
    @table[label]
  end

  def remove_cup(cup)
    previous_cup = cup.previous_cup
    next_cup = cup.next_cup

    cup.previous_cup = nil
    previous_cup.next_cup = next_cup

    cup.next_cup = nil
    next_cup.previous_cup = previous_cup

    @table.delete(cup.label)
  end

  def insert_cup_after_target(placing_cup, target_cup)
    next_cup = target_cup.next_cup

    placing_cup.previous_cup = target_cup
    target_cup.next_cup = placing_cup

    placing_cup.next_cup = next_cup
    next_cup.previous_cup = placing_cup

    @table[placing_cup.label] = placing_cup
  end

  private
  def construct_table(labels)
    @table = {}

    first_cup = Cup.new(labels.first)
    @table[first_cup.label] = first_cup

    previous_cup = first_cup
    labels[1...].each do |label|
      cup = Cup.new(label)
      @table[label] = cup

      cup.previous_cup = previous_cup
      previous_cup.next_cup = cup

      previous_cup = cup
    end

    previous_cup.next_cup = first_cup
    first_cup.previous_cup = previous_cup
  end
end

class Game
  def initialize(cup_table, current_cup)
    @cup_table = cup_table
    @current_cup = current_cup
  end

  def play_round
    picked_up_cups = remove_next_three_cups
    place_cups_at_destination(picked_up_cups)

    @current_cup = current_cup.next_cup
  end

  private

  attr_reader :cup_table, :current_cup

  def destination_cup
    destination_label = current_cup.label - 1

    until cup_table.cup_for_label(destination_label)
      if destination_label < 1
        destination_label = 1_000_000
      else
        destination_label -= 1
      end
    end

    cup_table.cup_for_label(destination_label)
  end

  def remove_next_three_cups
    3.times.map do
      cup_table.remove_cup(current_cup.next_cup)
    end
  end

  def place_cups_at_destination(placing_cups)
    target_cup = destination_cup

    placing_cups.each do |placing_cup|
      cup_table.insert_cup_after_target(placing_cup, target_cup)
      target_cup = placing_cup
    end
  end
end

if __FILE__ == $0
  labels = "315679824".chars.map(&:to_i)
  labels += (10..1_000_000).to_a

  cup_table = CupTable.new(labels)
  current_cup = cup_table.cup_for_label(labels.first)
  game = Game.new(cup_table, current_cup)

  10_000_000.times { |i|
    game.play_round
  }

  one_cup = cup_table.cup_for_label(1)
  factor_cup1 = one_cup.next_cup
  factor_cup2 = factor_cup1.next_cup

  puts factor_cup1.label * factor_cup2.label
end

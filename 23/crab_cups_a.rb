#!/usr/bin/env ruby

class Game
  def initialize(cups)
    @cups = cups
    @current_cup = cups.first
  end

  def play_round
    picked_up_cups = remove_next_three_cups
    place_cups_at_destination(picked_up_cups)
    @current_cup = cups[next_index]
  end

  def cups_clockwise_from_one
    until cups.first == 1
      cups << cups.shift
    end

    cups.drop(1).map(&:to_s).join
  end

  private
  attr_reader :cups, :current_cup

  def current_index
    cups.find_index(current_cup)
  end

  def next_index
    (cups.find_index(current_cup) + 1) % cups.length
  end

  def destination_index
    destination_cup = current_cup - 1

    until cups.include?(destination_cup)
      if destination_cup < cups.min
        destination_cup = cups.max
      else
        destination_cup -= 1
      end
    end

    cups.find_index(destination_cup)
  end

  def remove_next_three_cups
    3.times.map do
      cups.delete_at(next_index)
    end
  end

  def place_cups_at_destination(cups_to_place)
    cups.insert(destination_index + 1, *cups_to_place)
  end
end

if __FILE__ == $0
  cups = "315679824".chars.map(&:to_i)
  game = Game.new(cups)
  100.times { game.play_round }

  puts game.cups_clockwise_from_one
end

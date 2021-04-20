#!/usr/bin/env ruby

class Deck < Array
  def draw
    shift
  end

  def add(*cards)
    push(*cards)
  end

  def score
    reverse.map.with_index { |value, i| value * (i+1) }.sum
  end
end

class Game
  def initialize(deck1, deck2)
    @deck1, @deck2 = deck1, deck2
  end

  def play
    until over?
      play_round
    end
  end

  def play_round
    card1, card2 = @deck1.draw, @deck2.draw

    case
    when card1 > card2
      @deck1.add(card1, card2)
    when card2 > card1
      @deck2.add(card2, card1)
    end
  end

  def over?
    @deck1.empty? || @deck2.empty?
  end

  def score
    [@deck1.score, @deck2.score].max
  end
end

if __FILE__ == $0
  decks = File.read('data_decks.txt').split(/\n\n/).map do |raw_deck|
    Deck.new(raw_deck.split("\n").drop(1).map(&:to_i))
  end

  game = Game.new(*decks)
  game.play
  puts game.score
end

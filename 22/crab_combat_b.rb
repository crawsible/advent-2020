#!/usr/bin/env ruby

class Deck < Array
  def draw
    shift
  end

  def add(*cards)
    push(*cards)
  end

  def copy_top(amount)
    Deck.new(take(amount))
  end

  def score
    reverse.map.with_index { |value, i| value * (i+1) }.sum
  end
end

class Game
  def initialize(deck1, deck2)
    @deck1, @deck2 = deck1, deck2
    @previous_deck_states = {}
  end

  def play
    until winner
      play_round
      update_previous_deck_states
    end
  end

  def winner
    return @winner if @winner

    case
    when @deck1.empty?
      :p2
    when @deck2.empty?
      :p1
    else
      nil
    end
  end

  def score
    case winner
    when :p1
      @deck1.score
    when :p2
      @deck2.score
    end
  end

  private
  def play_round
    card1, card2 = @deck1.draw, @deck2.draw

    case round_winner(card1, card2)
    when :p1
      @deck1.add(card1, card2)
    when :p2
      @deck2.add(card2, card1)
    end
  end

  def round_winner(card1, card2)
    if card1 <= @deck1.length && card2 <= @deck2.length
      subgame = Game.new(@deck1.copy_top(card1), @deck2.copy_top(card2))
      subgame.play
      return subgame.winner
    end

    card1 > card2 ? :p1 : :p2
  end

  def update_previous_deck_states
    if @previous_deck_states[[@deck1, @deck2].hash]
      @winner = :p1
    else
      @previous_deck_states[[@deck1, @deck2].hash] = true
    end
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

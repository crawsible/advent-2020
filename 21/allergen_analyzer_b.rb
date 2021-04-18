#!/usr/bin/env ruby

Food = Struct.new(:ingredients, :allergens)

class AllergenAnalyzer
  def initialize(foods)
    @foods = foods
    @allergen_ingredients = {}

    deduce_allergenic_ingredients
  end

  def dangerous_ingredients
    @allergen_ingredients.sort_by { |a, _| a }.map(&:last).map(&:first).join(',')
  end

  private
  def deduce_allergenic_ingredients
    allergen_ingredient_lists.each do |allergen, ingredient_lists|
      @allergen_ingredients[allergen] = identify_potential_ingredients(ingredient_lists)
    end

    resolved_allergens = []
    loop do
      allergen, matched_ingredient = @allergen_ingredients.except(*resolved_allergens).find do |_, ingredients|
        ingredients.one?
      end
      break unless allergen

      resolved_allergens << allergen
      @allergen_ingredients.except(*resolved_allergens).each do |_, ingredients|
        ingredients.delete(matched_ingredient.first)
      end
    end
  end

  def allergen_ingredient_lists
    @foods.reduce(Hash.new([])) do |memo, food|
      food.allergens.each do |allergen|
        memo[allergen] += [food.ingredients]
      end

      memo
    end
  end

  def identify_potential_ingredients(ingredient_lists)
    ingredients = ingredient_lists.flatten.uniq

    ingredients.select do |ingredient|
      ingredient_lists.all? { |list| list.include?(ingredient) }
    end
  end

  def all_ingredients
    @foods.map(&:ingredients).flatten.uniq
  end

  def potentially_allergenic_ingredients
    @allergen_ingredients.values.flatten.uniq
  end

  def nonallergenic_ingredients
    all_ingredients - potentially_allergenic_ingredients
  end
end


foods = File.read('./data_foods.txt').split(/\n/).map do |line|
  ingredients_line, allergens_line = /\A([a-z ]+) \(contains ([a-z, ]+)\)\z/.match(line).captures
  Food.new(ingredients_line.split, allergens_line.split(', '))
end

analyzer = AllergenAnalyzer.new(foods)
puts analyzer.dangerous_ingredients
